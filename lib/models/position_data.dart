import 'package:ctrader_example_app/l10n/localization_helper.dart';
import 'package:ctrader_example_app/l10n/localizations.dart';
import 'package:ctrader_example_app/logger.dart';
import 'package:ctrader_example_app/models/order_pos_data_base.dart';
import 'package:ctrader_example_app/models/symbol_data.dart';
import 'package:ctrader_example_app/models/trader_data.dart';
import 'package:ctrader_example_app/popups/popup.dart';
import 'package:ctrader_example_app/popups/popup_manager.dart';
import 'package:ctrader_example_app/remote/proto.dart';
import 'package:ctrader_example_app/states/app_state.dart';
import 'package:ctrader_example_app/states/simultaneous_trading_state.dart';
import 'package:ctrader_example_app/states/user_state.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class PositionData extends OrderPosDataBase {
  PositionData.parseResponse(TraderData trader, ProtoOAPosition position) : super(trader, position.positionId, position.tradeData.symbolId) {
    update(position);
  }

  int usedMargin = 0;
  int grossPnl = 0;
  int netPnl = 0;

  @override
  int? get currentRate => isBuy ? symbol?.bid : symbol?.ask;

  @override
  int? get trailingStopDistance => trailingStopLoss ? GetIt.I<UserState>().trailingStopValues.valueOfPosition(trader.id, id) : null;

  @override
  int? calculateTakeProfitExtremeRate() {
    final SymbolData? symbol = this.symbol;
    if (symbol == null) return null;

    final int? currentRate = this.currentRate;
    if (currentRate == null) return null;

    return currentRate + (isBuy ? 1 : -1) * symbol.takeProfitDisatance;
  }

  @override
  int? calculateStopLossExtremeRate() {
    final SymbolData? symbol = this.symbol;
    if (symbol == null) return null;

    final int? currentRate = this.currentRate;
    if (currentRate == null) return null;

    return currentRate + (isBuy ? -1 : 1) * symbol.stopLossDistance;
  }

  String get formattedPnl => trader.formattedMoney(cents: netPnl);
  String get formattedPnlWithCurrency => trader.formattedMoneyWithCurrency(cents: netPnl);

  bool updatePnl(int grossPnl, int netPnl) {
    if (grossPnl != this.grossPnl || netPnl != this.netPnl) {
      this.grossPnl = grossPnl;
      this.netPnl = netPnl;

      return true;
    }

    return false;
  }

  void _fillData(ProtoOAPosition data) {
    isBuy = data.tradeData.tradeSide == ProtoOATradeSide.buy;
    rate = SymbolData.systemRateFromHumanic(data.price);
    volume = data.tradeData.volume;
    usedMargin = data.usedMargin ?? usedMargin;
    measurementUnits = data.tradeData.measurementUnits ?? measurementUnits;
    garanteedStopLoss = data.guaranteedStopLoss == true;

    if (data.takeProfit != null) {
      takeProfit = SymbolData.systemRateFromHumanic(data.takeProfit!);
    } else {
      takeProfit = null;
    }

    if (data.trailingStopLoss == true && data.stopLoss != null && data.stopLoss != 0) {
      trailingStopLoss = true;
      stopLoss = SymbolData.systemRateFromHumanic(data.stopLoss!);
    } else {
      trailingStopLoss = false;
      stopLoss = data.stopLoss != null ? SymbolData.systemRateFromHumanic(data.stopLoss!) : null;
    }

    opened = DateTime.fromMillisecondsSinceEpoch(data.tradeData.openTimestamp ?? 0);
    updateTimestamp(data.utcLastUpdateTimestamp);
  }

  Future<void> _closeSimultaneousPosition(BuildContext context) async {
    final SimultaneousTrdaingState simultaneousState = GetIt.I<SimultaneousTrdaingState>();
    final Map<int, int> pairs = simultaneousState.getPairedPositions(trader.id, id);

    final PopupResult result = await GetIt.I<PopupManager>().askToApplySimultaneousChanges(AppLocalizations.of(context)!, true, pairs.keys);
    if (result.agree && result.payload['all'] == true) {
      final List<int> traders = pairs.keys.toList();
      for (final int accId in traders) {
        try {
          final TraderData trader = GetIt.I<UserState>().trader(accId)!;
          final PositionData position = trader.positionsManager.activityBy(id: pairs[accId])!;

          final bool closed = await _closeSinglePosition(context, trader, position.id, position.volume);
          if (closed) simultaneousState.removePositionFromPair(trader.id, position.id);
        } catch (err) {
          Logger.error('Error occurred at position cancelation', err);
        }
      }
    } else if (result.agree) {
      simultaneousState.removePositionFromPair(trader.id, id);
      await _closeSinglePosition(context, trader, id, volume);
    }
  }

  Future<bool> _closeSinglePosition(BuildContext context, TraderData trader, int id, int volume) async {
    try {
      ProtoMessage resp = await trader.remoteApi.sendClosePosition(trader.id, id, volume);

      if (resp is ProtoOAExecutionEvent && resp.executionType == ProtoOAExecutionType.orderAccepted) {
        resp = await trader.remoteApi.waitForResponse(resp.cmdId!);
        if (resp is ProtoOAExecutionEvent) {
          if (resp.executionType == ProtoOAExecutionType.orderFilled || resp.executionType == ProtoOAExecutionType.orderPartialFill) {
            return true;
          } else {
            GetIt.I<PopupManager>().showPositionExecutionRejected(AppLocalizations.of(context)!, resp);
          }
        } else {
          Logger.log(() => 'unhandled ${resp.runtimeType} for position($id) closing for trader(${trader.id})');
          GetIt.I<PopupManager>().showSomeErrorOccurred(AppLocalizations.of(context)!);
        }
      } else if (resp is ProtoOAOrderErrorEvent) {
        Logger.error('Server error at position cancelation: ${resp.errorCode}#${resp.description}');
        final AppLocalizations l10n = AppLocalizations.of(context)!;
        GetIt.I<PopupManager>().showError(l10n, l10n.getServerErrorDescription(resp.errorCode) ?? resp.description ?? resp.errorCode);
      }
    } on ProtoOAErrorRes catch (err) {
      Logger.log(() => 'Server error at position cancelation: ${err.errorCode}#${err.description}');
      final AppLocalizations l10n = AppLocalizations.of(context)!;
      GetIt.I<PopupManager>().showError(l10n, l10n.getServerErrorDescription(err.errorCode) ?? err.description ?? err.errorCode);
    } catch (err) {
      Logger.error('error occurred at closing position($id) for trader(${trader.id})', err);
      GetIt.I<PopupManager>().showSomeErrorOccurred(AppLocalizations.of(context)!);
    }

    return false;
  }

  Future<bool> _editSimultaneousPositions(
    BuildContext context,
    TraderData trader, {
    int? stopLoss,
    int? takeProfit,
    int? tralingStop,
  }) async {
    final SimultaneousTrdaingState simultaneousState = GetIt.I<SimultaneousTrdaingState>();
    final Map<int, int> pairedPositions = simultaneousState.getPairedPositions(trader.id, id);

    final PopupResult result = await GetIt.I<PopupManager>().askToApplySimultaneousChanges(AppLocalizations.of(context)!, true, pairedPositions.keys);
    if (result.agree && result.payload['all'] != true) {
      simultaneousState.removePositionFromPair(trader.id, id);
      return _editSinglePosition(
        context,
        trader,
        id,
        stopLoss: stopLoss,
        takeProfit: takeProfit,
        trailingStop: tralingStop,
      );
    } else if (result.agree) {
      bool updatedCurrentPosition = false;
      for (final int accId in pairedPositions.keys.toList()) {
        try {
          final int positionId = pairedPositions[accId]!;
          final TraderData trader = GetIt.I<UserState>().trader(accId)!;
          final bool closed = await _editSinglePosition(
            context,
            trader,
            positionId,
            stopLoss: stopLoss,
            takeProfit: takeProfit,
            trailingStop: tralingStop,
          );

          if (closed && positionId == id && this.trader.id == trader.id) updatedCurrentPosition = true;
        } catch (e) {
          Logger.error('Error occurred at position editing', e);
        }
      }
      return updatedCurrentPosition;
    }

    return false;
  }

  Future<bool> _editSinglePosition(
    BuildContext context,
    TraderData trader,
    int positionId, {
    int? stopLoss,
    int? takeProfit,
    int? trailingStop,
  }) async {
    try {
      final ProtoMessage resp = await trader.remoteApi.sendEditPosition(
        trader.id,
        positionId,
        takeProfit: takeProfit != null ? SymbolData.humanicRateFromSystem(takeProfit) : null,
        trailingStop: trailingStop != null,
        stopLoss: trailingStop != null
            ? SymbolData.humanicRateFromSystem(rate + trailingStop * (isBuy ? -1 : 1))
            : (stopLoss != null ? SymbolData.humanicRateFromSystem(stopLoss) : null),
      );

      if (resp is ProtoOAExecutionEvent) {
        if (resp.order?.orderType == ProtoOAOrderType.stopLossTakeProfit) {
          if (resp.executionType == ProtoOAExecutionType.orderAccepted ||
              resp.executionType == ProtoOAExecutionType.orderReplaced ||
              resp.executionType == ProtoOAExecutionType.orderCancelled) {
            if (trailingStop != null) {
              GetIt.I<UserState>().trailingStopValues.updateForPosition(trader.id, resp.position!.positionId, trailingStop);
            } else {
              GetIt.I<UserState>().trailingStopValues.clearFromPosition(trader.id, resp.position!.positionId);
            }
            GetIt.I<PopupManager>().showPositionUpdated(AppLocalizations.of(context)!, resp, symbolDetails: symbol?.details);
            return true;
          } else {
            Logger.log(() => 'editiong position($positionId) for trader(${trader.id}) finished with type(${resp.executionType})');
            GetIt.I<PopupManager>().showSomeErrorOccurred(AppLocalizations.of(context)!);
          }
        } else if (resp.executionType == ProtoOAExecutionType.orderRejected || resp.executionType == ProtoOAExecutionType.orderCancelled) {
          GetIt.I<PopupManager>().showOrderExecutionFaild(AppLocalizations.of(context)!, resp.order!.orderId);
        } else if (resp.errorCode != null) {
          Logger.log(() => 'error(${resp.errorCode}) occurred at edition position($positionId) for trader(${trader.id})');
          final AppLocalizations l10n = AppLocalizations.of(context)!;
          GetIt.I<PopupManager>().showError(l10n, l10n.getServerErrorDescription(resp.errorCode!) ?? resp.errorCode!);
        } else {
          Logger.error('unhandled state of response of editiong position($positionId) for trader(${trader.id}) '
              'with executionType(${resp.executionType.name}) and orderType(${resp.order!.orderType.name})');
        }
      } else if (resp is ProtoOAOrderErrorEvent) {
        Logger.log(() => 'error(${resp.errorCode}#${resp.description}) for editing poisition($positionId) for trader(${trader.id})');
        GetIt.I<PopupManager>().showNewOrderError(AppLocalizations.of(context)!, resp);
      } else {
        Logger.error('unhandled state of response of editiong position($positionId) for trader(${trader.id}) '
            'with response(${resp.runtimeType})');
        GetIt.I<PopupManager>().showSomeErrorOccurred(AppLocalizations.of(context)!);
      }
    } on ProtoOAErrorRes catch (e) {
      Logger.log(() => 'Server error at position editing: #${e.errorCode}: ${e.description}');
      final AppLocalizations l10n = AppLocalizations.of(context)!;
      GetIt.I<PopupManager>().showError(l10n, l10n.getServerErrorDescription(e.errorCode) ?? e.description ?? e.errorCode);
    } catch (e) {
      Logger.error('unhandled error at position editing', e);
      GetIt.I<PopupManager>().showSomeErrorOccurred(AppLocalizations.of(context)!);
    }

    return false;
  }

  @override
  void update(dynamic data) {
    final ProtoOAPosition? oaPosition = data as ProtoOAPosition?;
    if (oaPosition == null) return;
    if (oaPosition.utcLastUpdateTimestamp != null && isUpdatedAfter(oaPosition.utcLastUpdateTimestamp!)) return;

    _fillData(oaPosition);
  }

  Future<void> closePosition(BuildContext context) async {
    final PopupResult result = await GetIt.I<PopupManager>().askToClosePosition(AppLocalizations.of(context)!, id);
    if (!result.agree) return;

    if (GetIt.I<SimultaneousTrdaingState>().isPositionPaired(trader.id, id)) {
      _closeSimultaneousPosition(context);
    } else {
      GetIt.I<AppState>().setUIBlocked(true);
      await _closeSinglePosition(context, trader, id, volume);
      GetIt.I<AppState>().setUIBlocked(false);
    }
  }

  Future<bool> editPosition(BuildContext context, {int? stopLoss, int? takeProfit, int? trailingStop}) async {
    final int? currentRate = this.currentRate;
    if (trailingStop != null && currentRate == null) return false;

    if (GetIt.I<SimultaneousTrdaingState>().isPositionPaired(trader.id, id)) {
      return _editSimultaneousPositions(
        context,
        trader,
        stopLoss: stopLoss,
        takeProfit: takeProfit,
        tralingStop: trailingStop,
      );
    } else {
      GetIt.I<AppState>().setUIBlocked(true);
      final bool result = await _editSinglePosition(
        context,
        trader,
        id,
        stopLoss: stopLoss,
        takeProfit: takeProfit,
        trailingStop: trailingStop,
      );
      GetIt.I<AppState>().setUIBlocked(false);

      return result;
    }
  }
}
