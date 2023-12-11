import 'package:ctrader_example_app/l10n/localization_helper.dart';
import 'package:ctrader_example_app/l10n/localizations.dart';
import 'package:ctrader_example_app/logger.dart';
import 'package:ctrader_example_app/models/order_pos_data_base.dart';
import 'package:ctrader_example_app/models/symbol_data.dart';
import 'package:ctrader_example_app/models/trader_data.dart';
import 'package:ctrader_example_app/popups/popup.dart';
import 'package:ctrader_example_app/popups/popup_manager.dart';
import 'package:ctrader_example_app/remote/proto.dart' as proto;
import 'package:ctrader_example_app/remote/remote_api_manager.dart';
import 'package:ctrader_example_app/states/app_state.dart';
import 'package:ctrader_example_app/states/simultaneous_trading_state.dart';
import 'package:ctrader_example_app/states/user_state.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class OrderData extends OrderPosDataBase {
  OrderData.parseResponse(TraderData trader, proto.ProtoOAOrder order)
      : timeInForce =
            order.timeInForce ?? (order.expirationTimestamp == null ? proto.ProtoOATimeInForce.goodTillCancel : proto.ProtoOATimeInForce.goodTillDate),
        super(trader, order.orderId, order.tradeData.symbolId) {
    isBuy = order.tradeData.tradeSide == proto.ProtoOATradeSide.buy;
    opened = DateTime.fromMillisecondsSinceEpoch(order.tradeData.openTimestamp ?? 0);
    measurementUnits = order.tradeData.measurementUnits ?? measurementUnits;

    _fillDataBy(order);
  }

  proto.ProtoOATimeInForce timeInForce;
  DateTime? expireAt;
  bool isLimit = false;
  int executedVolume = 0;

  @override
  int? get currentRate => isBuy ? symbol?.ask : symbol?.bid;

  @override
  int? get trailingStopDistance => trailingStopLoss ? GetIt.I<UserState>().trailingStopValues.valueOfOrder(trader.id, id) : null;

  int? get volumeLeft => volume - executedVolume;

  @override
  int? calculateTakeProfitExtremeRate() {
    final SymbolData? symbol = this.symbol;
    if (symbol == null) return null;

    return rate + (isBuy ? 1 : -1) * symbol.takeProfitDisatance;
  }

  @override
  int? calculateStopLossExtremeRate() {
    final SymbolData? symbol = this.symbol;
    if (symbol == null) return null;

    final int? currentRate = this.currentRate;
    if (currentRate == null) return null;

    return rate + (isBuy ? -1 : 1) * symbol.stopLossDistance;
  }

  @override
  String get formattedVolume {
    return symbol?.details?.formattedVolume(system: volumeLeft) ?? SymbolData.formattedVolumeDefault(system: volumeLeft);
  }

  void _fillDataBy(proto.ProtoOAOrder order) {
    volume = order.tradeData.volume;
    executedVolume = order.executedVolume ?? executedVolume;
    rate = SymbolData.systemRateFromHumanic(order.limitPrice ?? order.stopPrice ?? 0);
    garanteedStopLoss = order.tradeData.guaranteedStopLoss == true;
    isLimit = order.orderType == proto.ProtoOAOrderType.limit;

    if (order.relativeTakeProfit != null) {
      takeProfit = rate + (isBuy ? 1 : -1) * order.relativeTakeProfit!;
    } else {
      takeProfit = null;
    }

    if (order.trailingStopLoss == true && order.relativeStopLoss != null && order.relativeStopLoss! > 0) {
      trailingStopLoss = true;
      stopLoss = rate + (isBuy ? -1 : 1) * order.relativeStopLoss!;
    } else {
      trailingStopLoss = false;
      stopLoss = order.relativeStopLoss != null ? rate + (isBuy ? -1 : 1) * order.relativeStopLoss! : null;
    }

    updateTimestamp(order.utcLastUpdateTimestamp);

    if (order.expirationTimestamp != null && order.expirationTimestamp! > 0) {
      expireAt = DateTime.fromMillisecondsSinceEpoch(order.expirationTimestamp!);
    } else {
      expireAt = null;
    }
    timeInForce = order.timeInForce ?? (order.expirationTimestamp == null ? proto.ProtoOATimeInForce.goodTillCancel : proto.ProtoOATimeInForce.goodTillDate);
  }

  Future<bool> _cancelSimultaneousOrder(BuildContext context) async {
    final SimultaneousTrdaingState simultaneousState = GetIt.I<SimultaneousTrdaingState>();
    final Map<int, int> pairedOrders = simultaneousState.getPairedOrders(trader.id, id);

    final PopupResult result = await GetIt.I<PopupManager>().askToApplySimultaneousChanges(AppLocalizations.of(context)!, false, pairedOrders.keys);
    if (result.agree && result.payload['all'] == true) {
      GetIt.I<AppState>().setUIBlocked(true);

      final List<int> traderIds = pairedOrders.keys.toList();
      for (final int accId in traderIds) {
        try {
          final int orderId = pairedOrders[accId]!;
          final TraderData trader = GetIt.I<UserState>().trader(accId)!;
          final bool canceled = await _cancelSingleOrder(context, trader, orderId);
          if (canceled) simultaneousState.removeOrderFromPair(trader.id, orderId);
        } catch (err) {
          Logger.error('Error occurred at order closing process', err);
        }
      }

      GetIt.I<AppState>().setUIBlocked(false);
      return true;
    } else if (result.agree) {
      GetIt.I<AppState>().setUIBlocked(true);
      simultaneousState.removeOrderFromPair(trader.id, id);
      GetIt.I<AppState>().setUIBlocked(false);

      return _cancelSingleOrder(context, trader, id);
    }

    return false;
  }

  Future<bool> _cancelSingleOrder(BuildContext context, TraderData trader, int orderId) async {
    try {
      final proto.ProtoMessage resp = await trader.remoteApi.sendCancelOrder(trader.id, orderId);

      if (resp is proto.ProtoOAExecutionEvent) {
        if (resp.executionType == proto.ProtoOAExecutionType.orderCancelled) {
          return true;
        } else if (resp.executionType == proto.ProtoOAExecutionType.orderCancelRejected) {
          Logger.log(() => 'order($orderId) cancelation for trader(${trader.id}) was rejected');
          GetIt.I<PopupManager>().showPendingOrderRejected(AppLocalizations.of(context)!, resp, symbolDetails: symbol?.details);
        } else if (resp.errorCode != null) {
          Logger.log(() => 'error(${resp.errorCode}) occurred for order($orderId) cancelation for trader(${trader.id})');
          GetIt.I<PopupManager>().showSomeErrorOccurred(AppLocalizations.of(context)!);
        } else {
          Logger.error('unhandeled ProtoOAExecutionEvent type for order($orderId) for trader(${trader.id})');
          GetIt.I<PopupManager>().showSomeErrorOccurred(AppLocalizations.of(context)!);
        }
      } else if (resp is proto.ProtoOAOrderErrorEvent) {
        Logger.error('Server rejected order cancelation: #${resp.errorCode}: ${resp.description}');
        final AppLocalizations l10n = AppLocalizations.of(context)!;
        GetIt.I<PopupManager>().showError(l10n, l10n.getServerErrorDescription(resp.errorCode) ?? resp.description ?? resp.errorCode);
      } else {
        Logger.error('unhandeled cancel order response: ${resp.runtimeType}');
      }
    } on proto.ProtoOAErrorRes catch (err) {
      Logger.log(() => '${err.errorCode}#${err.description}');
      final AppLocalizations l10n = AppLocalizations.of(context)!;
      GetIt.I<PopupManager>().showError(l10n, l10n.getServerErrorDescription(err.errorCode) ?? err.description ?? err.errorCode);
    } catch (err) {
      Logger.error('Error occurred at order canceletion process', err);
      GetIt.I<PopupManager>().showSomeErrorOccurred(AppLocalizations.of(context)!);
    }

    return false;
  }

  Future<bool> _editSimultaneousOrder(
    BuildContext context,
    int rate,
    int volume, {
    int? stopLoss,
    int? takeProfit,
    int? trailingStop,
    int? expiresAtTs,
  }) async {
    final SimultaneousTrdaingState simultaneousState = GetIt.I<SimultaneousTrdaingState>();
    final Map<int, int> pairedOrders = simultaneousState.getPairedOrders(trader.id, id);

    final PopupResult result = await GetIt.I<PopupManager>().askToApplySimultaneousChanges(AppLocalizations.of(context)!, true, pairedOrders.keys);
    if (!result.agree) {
      return false;
    } else if (result.payload['all'] == false) {
      simultaneousState.removeOrderFromPair(trader.id, id);
      return _editSingleOrder(
        context,
        trader,
        id,
        rate,
        volume,
        stopLoss: stopLoss,
        takeProfit: takeProfit,
        trailingStop: trailingStop,
        expiresAtTs: expiresAtTs,
      );
    } else {
      bool updatedCurrent = false;
      for (final int accId in pairedOrders.keys) {
        try {
          final int id = pairedOrders[accId]!;
          final TraderData trader = GetIt.I<UserState>().trader(accId)!;
          final bool updated = await _editSingleOrder(
            context,
            trader,
            id,
            rate,
            volume,
            stopLoss: stopLoss,
            takeProfit: takeProfit,
            trailingStop: trailingStop,
            expiresAtTs: expiresAtTs,
          );
          if (updated && accId == this.trader.id && id == this.id) updatedCurrent = true;
        } catch (e) {
          Logger.error('some error occurred at updating order($id) for trader($accId): $e');
        }
      }
      return updatedCurrent;
    }
  }

  Future<bool> _editSingleOrder(
    BuildContext context,
    TraderData trader,
    int id,
    int rate,
    int volume, {
    int? stopLoss,
    int? takeProfit,
    int? trailingStop,
    int? expiresAtTs,
  }) async {
    try {
      int? relativeSl;
      if (trailingStop != null) {
        relativeSl = trailingStop;
      } else if (stopLoss != null) {
        relativeSl = (rate - stopLoss).abs();
      }

      final proto.ProtoMessage resp = await GetIt.I<RemoteAPIManager>().getAPI(demo: trader.demo).sendEditOrder(
            trader.id,
            id,
            volume,
            SymbolData.humanicRateFromSystem(rate),
            isLimit,
            expireAtTs: expiresAtTs,
            relativeTP: takeProfit != null ? (takeProfit - rate).abs() : null,
            trailingStop: trailingStop != null,
            relativeSL: relativeSl,
          );

      if (resp is proto.ProtoOAExecutionEvent && resp.executionType == proto.ProtoOAExecutionType.orderReplaced) {
        if (trailingStop != null) {
          GetIt.I<UserState>().trailingStopValues.updateForOrder(trader.id, id, trailingStop);
        } else {
          GetIt.I<UserState>().trailingStopValues.clearFromOrder(trader.id, id);
        }

        GetIt.I<PopupManager>().showPendingOrderUpdated(AppLocalizations.of(context)!, resp, symbolDetails: symbol?.details);

        return true;
      } else if (resp is proto.ProtoOAOrderErrorEvent) {
        Logger.log(() => 'Server error: #${resp.errorCode}: ${resp.description}');
        GetIt.I<PopupManager>().showNewOrderError(AppLocalizations.of(context)!, resp);
      } else {
        Logger.error('unhandled resp type of editing order($id) for trader(${trader.id})');
        GetIt.I<PopupManager>().showSomeErrorOccurred(AppLocalizations.of(context)!);
      }
    } on proto.ProtoOAErrorRes catch (err) {
      Logger.log(() => "can't update order({$id}) for trader(${trader.id}): ${err.errorCode}#${err.description}");
      final AppLocalizations l10n = AppLocalizations.of(context)!;
      GetIt.I<PopupManager>().showError(l10n, l10n.getServerErrorDescription(err.errorCode) ?? err.description ?? err.errorCode);
    } catch (err) {
      Logger.error("can't update order({$id}) for trader(${trader.id}): $err");
      GetIt.I<PopupManager>().showSomeErrorOccurred(AppLocalizations.of(context)!);
    }

    return false;
  }

  @override
  void update(dynamic data) {
    final proto.ProtoOAOrder? oaOrder = data as proto.ProtoOAOrder?;
    if (oaOrder == null) return;
    if (oaOrder.utcLastUpdateTimestamp != null && isUpdatedAfter(oaOrder.utcLastUpdateTimestamp!)) return;

    _fillDataBy(oaOrder);
  }

  Future<bool> cancelOrder(BuildContext context, {bool? force}) async {
    if (force != true) {
      final PopupResult result = await GetIt.I<PopupManager>().askToCancelOrder(AppLocalizations.of(context)!, id);
      if (!result.agree) return false;
    }

    if (force != true && GetIt.I<SimultaneousTrdaingState>().isOrderPaired(trader.id, id)) {
      return _cancelSimultaneousOrder(context);
    } else {
      GetIt.I<AppState>().setUIBlocked(true);
      final bool result = await _cancelSingleOrder(context, trader, id);
      GetIt.I<AppState>().setUIBlocked(false);

      return result;
    }
  }

  Future<bool> editOrder(
    BuildContext context,
    int rate,
    int volume, {
    int? stopLoss,
    int? takeProfit,
    int? trailingStop,
    int? expiresAtTs,
  }) {
    if (GetIt.I<SimultaneousTrdaingState>().isOrderPaired(trader.id, id)) {
      return _editSimultaneousOrder(
        context,
        rate,
        volume,
        stopLoss: stopLoss,
        takeProfit: takeProfit,
        trailingStop: trailingStop,
        expiresAtTs: expiresAtTs,
      );
    } else {
      return _editSingleOrder(
        context,
        trader,
        id,
        rate,
        volume,
        stopLoss: stopLoss,
        takeProfit: takeProfit,
        trailingStop: trailingStop,
        expiresAtTs: expiresAtTs,
      );
    }
  }
}
