import 'dart:async';
import 'dart:collection';
import 'dart:math' as math;

import 'package:ctrader_example_app/extensions.dart';
import 'package:ctrader_example_app/l10n/localizations.dart';
import 'package:ctrader_example_app/logger.dart';
import 'package:ctrader_example_app/main.dart';
import 'package:ctrader_example_app/models/symbol_data.dart';
import 'package:ctrader_example_app/models/trader_data.dart';
import 'package:ctrader_example_app/popups/popup.dart';
import 'package:ctrader_example_app/popups/popup_constants.dart' as popup_constants;
import 'package:ctrader_example_app/remote/proto.dart';
import 'package:ctrader_example_app/states/simultaneous_trading_state.dart';
import 'package:ctrader_example_app/states/user_state.dart';
import 'package:ctrader_example_app/widgets/button_primary.dart';
import 'package:ctrader_example_app/widgets/button_secondary.dart';
import 'package:ctrader_example_app/widgets/button_third.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class PopupManager extends ChangeNotifier {
  final Queue<Popup> _queue = Queue<Popup>();
  final Map<String, dynamic> currentPopupPayload = <String, dynamic>{};
  Popup? get currentPopup => _queue.isEmpty ? null : _queue.first;

  void _addToQueue(Popup popup) {
    _queue.addLast(popup);

    notifyListeners();
  }

  void removePopup(Popup popup) => _queue.remove(popup) ? notifyListeners() : null;

  Future<PopupResult> showPopup({
    String? title,
    String? message,
    String? checkbox,
    List<Widget>? content,
    List<Widget>? buttons,
    Axis? buttonsAxies,
  }) {
    final Completer<PopupResult> completer = Completer<PopupResult>();
    _addToQueue(Popup(
      completer: completer,
      payload: Map<String, dynamic>.identity(),
      title: title,
      message: message,
      checkbox: checkbox,
      content: content,
      buttons: buttons,
      buttonsAxis: buttonsAxies,
    ));

    notifyListeners();
    return completer.future;
  }

  Future<PopupResult> showError(AppLocalizations l10n, String error) {
    Logger.error('PopupManaer.showError\n${StackTrace.current.toString()}');

    return showPopup(title: l10n.errorOccurred, message: error);
  }

  Future<PopupResult> showSomeErrorOccurred(AppLocalizations l10n) {
    Logger.error('PopupManaer.showSomeErrorOccurred\n${StackTrace.current.toString()}');

    return showPopup(
      title: l10n.errorOccurred,
      message: l10n.someErrorOccurred,
    );
  }

  Future<PopupResult> showTraderSelection(AppLocalizations l10n, TraderData trader, bool hasMoreTraders) {
    String title = '';
    String message = '';

    if (trader.accessRights == ProtoOAAccessRights.noLogin) {
      title = l10n.noLoginAccessPopupTitle;
      message = l10n.noLoginAccessPopupBody;
    } else if (trader.accountType == ProtoOAAccountType.spreadBetting) {
      title = l10n.spreadBettingPopupTitle;
      message = l10n.spreadBettingPopupBody;
    } else if (trader.accessRights == ProtoOAAccessRights.noTrading) {
      title = l10n.limitedAccessPopupTitle;
      message = l10n.noTradingAccessPopupuBody;
    } else if (trader.accessRights == ProtoOAAccessRights.closeOnly) {
      title = l10n.limitedAccessPopupTitle;
      message = l10n.closeOnlyAccessPopupBody;
    } else {
      title = l10n.successLoginPopupTitle;
      message = l10n.successLoginPopupBody;
    }

    return showPopup(
      title: title,
      content: <Widget>[
        Text(message, style: popup_constants.textStyleBody),
        const SizedBox(height: 8),
        Row(children: <Widget>[
          Text(l10n.yourAccount, style: popup_constants.textStyleBody),
          const Spacer(),
          Text(trader.login.toString(), style: popup_constants.textStyleBodyBold),
        ]),
        Row(children: <Widget>[
          Text(l10n.yourBroker, style: popup_constants.textStyleBody),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              trader.name,
              style: popup_constants.textStyleBodyBold,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ]),
        if (hasMoreTraders)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(l10n.moreAccountAvailableInTab, style: popup_constants.textStyleBody),
          ),
      ],
      buttons: <Widget>[
        ButtonSecondary(
          label: l10n.cancel,
          flex: 1,
          height: popup_constants.singleButtonSize.height,
          onTap: () => currentPopup?.closeWithResult(false),
        ),
        const SizedBox(width: 8),
        ButtonPrimary(
          label: 'OK',
          flex: 1,
          height: popup_constants.singleButtonSize.height,
          onTap: () => currentPopup?.closeWithResult(true),
        ),
      ],
    );
  }

  Future<PopupResult>? handleNewPositionOpenedEvent(
    AppLocalizations l10n,
    ProtoOAExecutionEvent event, {
    bool sltpError = false,
    SymbolDetailsData? symbolDetails,
  }) {
    final ProtoOAOrder oaOrder = event.order!;
    final ProtoOAPosition? oaPosition = event.position;

    if (oaPosition == null) {
      Logger.error('position should be not null to continue of handling new position opened event');
      return null;
    }

    if (oaPosition.tradeData.volume == oaOrder.executedVolume && oaPosition.tradeData.tradeSide == oaOrder.tradeData.tradeSide) {
      return showPositionOpened(l10n, event, sltpError: sltpError, symbolDetails: symbolDetails);
    } else {
      return showPositionChanged(l10n, event, sltpError: sltpError, symbolDetails: symbolDetails);
    }
  }

  Future<PopupResult> showPositionOpened(
    AppLocalizations l10n,
    ProtoOAExecutionEvent event, {
    bool sltpError = false,
    SymbolDetailsData? symbolDetails,
  }) {
    final UserState userState = GetIt.I<UserState>();
    final TraderData? trader = userState.trader(event.ctidTraderAccountId);
    final SymbolData? symbol = trader?.tree.symbol(event.order!.tradeData.symbolId);
    final ProtoOAPosition oaPosition = event.position!;

    symbolDetails ??= symbol?.details;

    String? trailingStop;
    if (oaPosition.trailingStopLoss == true && oaPosition.stopLoss != null) {
      final int? trailingStopDistance = userState.trailingStopValues.valueOfPosition(trader?.id ?? -1, oaPosition.positionId);
      if (trailingStopDistance != null) {
        trailingStop = symbolDetails?.formattedPips(system: trailingStopDistance) ?? SymbolData.formattedRateDefault(system: trailingStopDistance);
      } else {
        trailingStop = symbolDetails?.formattedRate(humanic: oaPosition.stopLoss) ?? SymbolData.formattedRateDefault(humanic: oaPosition.stopLoss);
      }
    }

    return showPopup(
      title: l10n.positionWas('opened'),
      content: <Widget>[
        Text(
          l10n.buySellSymbolPositionWas(oaPosition.tradeData.tradeSide.name, symbol?.name ?? '', 'opened'),
          style: popup_constants.textStyleBody,
        ),
        if (trader?.id != userState.selectedTraderId)
          Row(children: <Widget>[
            Text('${l10n.broker}:', style: popup_constants.textStyleBody),
            const Spacer(),
            Text(trader?.name ?? '----', style: popup_constants.textStyleBodyBold),
          ]),
        if (trader?.id != userState.selectedTraderId)
          Row(children: <Widget>[
            Text('${l10n.account}:', style: popup_constants.textStyleBody),
            const Spacer(),
            Text(trader?.login.toString() ?? '----', style: popup_constants.textStyleBodyBold),
          ]),
        if (trader?.id != userState.selectedTraderId) const SizedBox(height: 16),
        Row(children: <Widget>[
          Text(l10n.positionId, style: popup_constants.textStyleBody),
          const Spacer(),
          Text(
            oaPosition.positionId.toString(),
            style: popup_constants.textStyleBodyBold,
          ),
        ]),
        Row(children: <Widget>[
          Text(l10n.amount, style: popup_constants.textStyleBody),
          const Spacer(),
          Text(
            symbolDetails?.formattedVolumeWithUnits(system: oaPosition.tradeData.volume) ??
                SymbolData.formattedVolumeDefault(system: oaPosition.tradeData.volume),
            style: popup_constants.textStyleBodyBold,
          ),
        ]),
        Row(children: <Widget>[
          Text(l10n.openingPrice, style: popup_constants.textStyleBody),
          const Spacer(),
          Text(
            symbolDetails?.formattedRate(humanic: oaPosition.price) ?? SymbolData.formattedRateDefault(humanic: oaPosition.price),
            style: popup_constants.textStyleBodyBold,
          ),
        ]),
        if (!sltpError)
          Row(children: <Widget>[
            Text(l10n.takeProfit, style: popup_constants.textStyleBody),
            const Spacer(),
            Text(
              oaPosition.takeProfit == null
                  ? l10n.no
                  : symbolDetails?.formattedRate(humanic: oaPosition.takeProfit) ?? SymbolData.formattedRateDefault(humanic: oaPosition.takeProfit),
              style: popup_constants.textStyleBodyBold,
            ),
          ]),
        if (!sltpError)
          Row(children: <Widget>[
            Text(trailingStop != null ? l10n.trailingStop : l10n.stopLoss, style: popup_constants.textStyleBody),
            const Spacer(),
            Text(
              trailingStop ??
                  (oaPosition.stopLoss != null
                      ? symbolDetails?.formattedRate(humanic: oaPosition.stopLoss) ?? SymbolData.formattedRateDefault(humanic: oaPosition.stopLoss)
                      : l10n.no),
              style: popup_constants.textStyleBodyBold,
            ),
          ]),
        if (sltpError) Text(l10n.eitherSLorTPRejected, style: popup_constants.textStyleBodyBold.copyWith(color: THEME.red)),
        Row(children: <Widget>[
          Text(l10n.opened, style: popup_constants.textStyleBody),
          const Spacer(),
          Text(
            DateTime.fromMillisecondsSinceEpoch(oaPosition.tradeData.openTimestamp ?? 0).formatted(),
            style: popup_constants.textStyleBodyBold,
          ),
        ]),
      ],
    );
  }

  Future<PopupResult> showPositionUpdated(AppLocalizations l10n, ProtoOAExecutionEvent event, {SymbolDetailsData? symbolDetails}) {
    final UserState userState = GetIt.I<UserState>();
    final TraderData? trader = userState.trader(event.ctidTraderAccountId);
    final SymbolData? symbol = trader?.tree.symbol(event.order?.tradeData.symbolId);
    final ProtoOAPosition oaPosition = event.position!;

    symbolDetails ??= symbol?.details;

    String? trailingStop;
    if (oaPosition.trailingStopLoss == true && oaPosition.stopLoss != null) {
      final int? trailingStopDist = userState.trailingStopValues.valueOfPosition(trader?.id ?? -1, oaPosition.positionId);
      if (trailingStopDist != null) {
        trailingStop = symbolDetails?.formattedPips(system: trailingStopDist) ?? SymbolData.formattedRateDefault(system: trailingStopDist);
      } else {
        trailingStop = symbolDetails?.formattedRate(humanic: oaPosition.stopLoss) ?? SymbolData.formattedRateDefault(humanic: oaPosition.stopLoss);
      }
    }

    return showPopup(
      title: l10n.positionWas('updated'),
      content: <Widget>[
        Text(
          l10n.buySellSymbolPositionWas(oaPosition.tradeData.tradeSide.name, symbol?.name ?? '', 'updated'),
          style: popup_constants.textStyleBody,
        ),
        if (trader?.id != userState.selectedTraderId)
          Row(children: <Widget>[
            Text('${l10n.broker}:', style: popup_constants.textStyleBody),
            const Spacer(),
            Text(trader?.name ?? '----', style: popup_constants.textStyleBodyBold),
          ]),
        if (trader?.id != userState.selectedTraderId)
          Row(children: <Widget>[
            Text('${l10n.account}:', style: popup_constants.textStyleBody),
            const Spacer(),
            Text(trader?.login.toString() ?? '----', style: popup_constants.textStyleBodyBold),
          ]),
        if (trader?.id != userState.selectedTraderId) const SizedBox(height: 16),
        Row(children: <Widget>[
          Text(l10n.positionId, style: popup_constants.textStyleBody),
          const Spacer(),
          Text(
            oaPosition.positionId.toString(),
            style: popup_constants.textStyleBodyBold,
          ),
        ]),
        Row(children: <Widget>[
          Text(l10n.amount, style: popup_constants.textStyleBody),
          const Spacer(),
          Text(
            symbolDetails?.formattedVolumeWithUnits(system: oaPosition.tradeData.volume) ??
                SymbolData.formattedVolumeDefault(system: oaPosition.tradeData.volume),
            style: popup_constants.textStyleBodyBold,
          ),
        ]),
        Row(children: <Widget>[
          Text(l10n.openingPrice, style: popup_constants.textStyleBody),
          const Spacer(),
          Text(
            symbolDetails?.formattedRate(humanic: oaPosition.price) ?? SymbolData.formattedRateDefault(humanic: oaPosition.price),
            style: popup_constants.textStyleBodyBold,
          ),
        ]),
        Row(children: <Widget>[
          Text(l10n.takeProfit, style: popup_constants.textStyleBody),
          const Spacer(),
          Text(
            oaPosition.takeProfit == null
                ? l10n.no
                : symbolDetails?.formattedRate(humanic: oaPosition.takeProfit) ?? SymbolData.formattedRateDefault(humanic: oaPosition.takeProfit),
            style: popup_constants.textStyleBodyBold,
          ),
        ]),
        Row(children: <Widget>[
          Text(trailingStop != null ? l10n.trailingStop : l10n.stopLoss, style: popup_constants.textStyleBody),
          const Spacer(),
          Text(
            trailingStop ??
                (oaPosition.stopLoss != null
                    ? (symbolDetails?.formattedRate(humanic: oaPosition.stopLoss) ?? SymbolData.formattedRateDefault(humanic: oaPosition.stopLoss))
                    : l10n.no),
            style: popup_constants.textStyleBodyBold,
          ),
        ]),
        Row(children: <Widget>[
          Text(l10n.opened, style: popup_constants.textStyleBody),
          const Spacer(),
          Text(
            DateTime.fromMillisecondsSinceEpoch(oaPosition.tradeData.openTimestamp ?? 0).formatted(),
            style: popup_constants.textStyleBodyBold,
          ),
        ]),
        Row(children: <Widget>[
          Text(l10n.updated, style: popup_constants.textStyleBody),
          const Spacer(),
          Text(
            DateTime.fromMillisecondsSinceEpoch(oaPosition.utcLastUpdateTimestamp ?? 0).formatted(),
            style: popup_constants.textStyleBodyBold,
          ),
        ]),
      ],
    );
  }

  Future<PopupResult> showPositionChanged(
    AppLocalizations l10n,
    ProtoOAExecutionEvent event, {
    bool sltpError = false,
    SymbolDetailsData? symbolDetails,
  }) {
    final UserState userState = GetIt.I<UserState>();
    final TraderData? trader = userState.trader(event.ctidTraderAccountId);
    final ProtoOAOrder order = event.order!;
    final SymbolData? symbol = trader?.tree.symbol(order.tradeData.symbolId);
    final ProtoOAPosition oaPosition = event.position!;
    final ProtoOADeal? deal = event.deal;
    final String action;
    double? pnl;
    String sl = l10n.no;
    String tradeSide = order.tradeData.tradeSide.name;

    if (oaPosition.tradeData.tradeSide != order.tradeData.tradeSide) {
      action = 'decreased';
      tradeSide = oaPosition.tradeData.tradeSide.name;
    } else if (oaPosition.tradeData.volume > order.tradeData.volume) {
      action = 'increased';
    } else {
      action = 'reversed';
      tradeSide = order.tradeData.tradeSide == ProtoOATradeSide.buy ? 'sell' : 'buy';
    }

    if (event.deal?.closePositionDetail != null) {
      final ProtoOAClosePositionDetail details = event.deal!.closePositionDetail!;
      pnl = (details.grossProfit + details.swap + details.commission).toDouble();
      pnl = trader?.toMoney(pnl.toInt()) ?? pnl / math.pow(10, oaPosition.moneyDigits ?? 0);
    }

    if (oaPosition.stopLoss != null) {
      if (oaPosition.trailingStopLoss == true) {
        final int? trailingStopDist = userState.trailingStopValues.valueOfPosition(trader?.id ?? -1, oaPosition.positionId);
        if (trailingStopDist != null) {
          sl = symbolDetails?.formattedPips(system: trailingStopDist) ?? SymbolData.formattedRateDefault(system: trailingStopDist);
        } else {
          sl = symbolDetails?.formattedRate(humanic: oaPosition.stopLoss) ?? SymbolData.formattedRateDefault(humanic: oaPosition.stopLoss);
        }
      } else {
        sl = symbolDetails?.formattedRate(humanic: oaPosition.stopLoss) ?? SymbolData.formattedRateDefault(humanic: oaPosition.stopLoss);
      }
    }

    return showPopup(
      title: l10n.positionAction(action),
      content: <Widget>[
        Text(
          l10n.buySellSymbolPositionWas(tradeSide, symbol?.name ?? '', action) +
              (action == 'reversed' ? ' ${l10n.nowYourPositinBuySellSymbol(oaPosition.tradeData.tradeSide.name, symbol?.name ?? '')}' : ''),
          style: popup_constants.textStyleBody,
        ),
        if (trader?.id != userState.selectedTraderId)
          Row(children: <Widget>[
            Text('${l10n.broker}:', style: popup_constants.textStyleBody),
            const Spacer(),
            Text(trader?.name ?? '----', style: popup_constants.textStyleBodyBold),
          ]),
        if (trader?.id != userState.selectedTraderId)
          Row(children: <Widget>[
            Text('${l10n.account}:', style: popup_constants.textStyleBody),
            const Spacer(),
            Text(trader?.login.toString() ?? '----', style: popup_constants.textStyleBodyBold),
          ]),
        if (trader?.id != userState.selectedTraderId) const SizedBox(height: 16),
        Row(children: <Widget>[
          Text(l10n.positionId, style: popup_constants.textStyleBody),
          const Spacer(),
          Text(oaPosition.positionId.toString(), style: popup_constants.textStyleBodyBold),
        ]),
        Row(children: <Widget>[
          Text(l10n.amount, style: popup_constants.textStyleBody),
          const Spacer(),
          Text(
            symbolDetails?.formattedVolumeWithUnits(system: oaPosition.tradeData.volume) ??
                SymbolData.formattedVolumeDefault(system: oaPosition.tradeData.volume),
            style: popup_constants.textStyleBodyBold,
          ),
        ]),
        Row(children: <Widget>[
          Text(l10n.filledAmount, style: popup_constants.textStyleBody),
          const Spacer(),
          Text(
            deal?.filledVolume == null
                ? l10n.no
                : symbolDetails?.formattedVolumeWithUnits(system: deal!.filledVolume) ?? SymbolData.formattedVolumeDefault(system: deal!.filledVolume),
            style: popup_constants.textStyleBodyBold,
          ),
        ]),
        if (pnl != null)
          Row(children: <Widget>[
            Text(l10n.realizedPnl, style: popup_constants.textStyleBody),
            const Spacer(),
            Text(
              trader?.formattedMoneyWithCurrency(money: pnl) ?? pnl.toComaSeparated(decimals: oaPosition.moneyDigits),
              style: popup_constants.textStyleBodyBold.copyWith(color: pnl == null || pnl < 0 ? THEME.red : THEME.green),
            ),
          ]),
        Row(children: <Widget>[
          Text(l10n.openingPrice, style: popup_constants.textStyleBody),
          const Spacer(),
          Text(
            symbolDetails?.formattedRate(humanic: oaPosition.price) ?? SymbolData.formattedRateDefault(humanic: oaPosition.price),
            style: popup_constants.textStyleBodyBold,
          ),
        ]),
        if (!sltpError)
          Row(children: <Widget>[
            Text(l10n.takeProfit, style: popup_constants.textStyleBody),
            const Spacer(),
            Text(
              oaPosition.takeProfit == null
                  ? l10n.no
                  : symbolDetails?.formattedRate(humanic: oaPosition.takeProfit) ?? SymbolData.formattedRateDefault(humanic: oaPosition.takeProfit),
              style: popup_constants.textStyleBodyBold,
            ),
          ]),
        if (!sltpError)
          Row(children: <Widget>[
            Text(
              oaPosition.trailingStopLoss == true ? l10n.trailingStop : l10n.stopLoss,
              style: popup_constants.textStyleBody,
            ),
            const Spacer(),
            Text(sl, style: popup_constants.textStyleBodyBold),
          ]),
        if (sltpError) Text(l10n.eitherSLorTPRejected, style: popup_constants.textStyleBodyBold.copyWith(color: THEME.red)),
        Row(children: <Widget>[
          Text(l10n.opened, style: popup_constants.textStyleBody),
          const Spacer(),
          Text(
            DateTime.fromMillisecondsSinceEpoch(oaPosition.tradeData.openTimestamp ?? 0).formatted(),
            style: popup_constants.textStyleBodyBold,
          ),
        ]),
      ],
    );
  }

  Future<PopupResult> showPositionClosed(AppLocalizations l10n, ProtoOAExecutionEvent event, {SymbolDetailsData? symbolDetails}) async {
    final UserState userState = GetIt.I<UserState>();
    final TraderData? trader = userState.trader(event.ctidTraderAccountId);
    final SymbolData? symbol = trader?.tree.symbol(event.order?.tradeData.symbolId);
    final ProtoOAPosition oaPosition = event.position!;
    final ProtoOADeal deal = event.deal!;
    final double openPrice = deal.closePositionDetail!.entryPrice;
    double? pnl;

    symbolDetails ??= symbol?.details;

    if (symbolDetails == null && symbol != null && GetIt.I<SimultaneousTrdaingState>().isAccountPaired(event.ctidTraderAccountId)) {
      final Iterable<int> accounts = GetIt.I<SimultaneousTrdaingState>().pariedAccounts;
      for (final int accountId in accounts) {
        final TraderData? account = userState.trader(accountId);
        final Iterable<SymbolData> papiredSymbols = account?.tree.findSymbolForSimultaneousTrading(name: symbol.name) ?? <SymbolData>[];

        for (final SymbolData s in papiredSymbols) {
          if (s.details != null) {
            symbolDetails = s.details;
            break;
          }
        }

        if (symbolDetails != null) break;
      }
    }

    if (symbolDetails != null && symbol != null) {
      try {
        symbolDetails = await symbol.getDetailsData();
      } catch (e) {
        Logger.error("Can't load symbol details for ${symbol.name}(${symbol.id})");
      }
    }

    if (deal.closePositionDetail != null) {
      pnl = (deal.closePositionDetail!.grossProfit + deal.closePositionDetail!.swap + deal.closePositionDetail!.commission).toDouble();
      pnl = trader?.toMoney(pnl.toInt()) ?? pnl / math.pow(10, deal.moneyDigits ?? 0);
    }

    return showPopup(
      title: l10n.positionWas('closed'),
      content: <Widget>[
        Text(
          l10n.buySellSymbolPositionWas('', symbol?.name ?? '', 'closed'),
          style: popup_constants.textStyleBody,
        ),
        if (trader?.id != userState.selectedTraderId)
          Row(children: <Widget>[
            Text('${l10n.broker}:', style: popup_constants.textStyleBody),
            const Spacer(),
            Text(trader?.name ?? '----', style: popup_constants.textStyleBodyBold),
          ]),
        if (trader?.id != userState.selectedTraderId)
          Row(children: <Widget>[
            Text('${l10n.account}:', style: popup_constants.textStyleBody),
            const Spacer(),
            Text(trader?.login.toString() ?? '----', style: popup_constants.textStyleBodyBold),
          ]),
        if (trader?.id != userState.selectedTraderId) const SizedBox(height: 16),
        Row(children: <Widget>[
          Text(l10n.positionId, style: popup_constants.textStyleBody),
          const Spacer(),
          Text(oaPosition.positionId.toString(), style: popup_constants.textStyleBodyBold),
        ]),
        Row(children: <Widget>[
          Text(l10n.amount, style: popup_constants.textStyleBody),
          const Spacer(),
          Text(
            symbolDetails?.formattedVolumeWithUnits(system: deal.filledVolume) ?? SymbolData.formattedVolumeDefault(system: deal.filledVolume),
            style: popup_constants.textStyleBodyBold,
          ),
        ]),
        Row(children: <Widget>[
          Text(l10n.realizedPnl, style: popup_constants.textStyleBody),
          const Spacer(),
          Text(
            pnl == null ? '----' : trader?.formattedMoneyWithCurrency(money: pnl) ?? pnl.toComaSeparated(decimals: oaPosition.moneyDigits),
            style: popup_constants.textStyleBodyBold.copyWith(color: pnl == null || pnl < 0 ? THEME.red : THEME.green),
          ),
        ]),
        Row(children: <Widget>[
          Text(l10n.openingPrice, style: popup_constants.textStyleBody),
          const Spacer(),
          Text(
            symbolDetails?.formattedRate(humanic: openPrice) ?? SymbolData.formattedRateDefault(humanic: openPrice),
            style: popup_constants.textStyleBodyBold,
          ),
        ]),
        Row(children: <Widget>[
          Text(l10n.opened, style: popup_constants.textStyleBody),
          const Spacer(),
          Text(
            DateTime.fromMillisecondsSinceEpoch(oaPosition.tradeData.openTimestamp ?? 0).formatted(),
            style: popup_constants.textStyleBodyBold,
          ),
        ]),
        Row(children: <Widget>[
          Text(l10n.closingPrice, style: popup_constants.textStyleBody),
          const Spacer(),
          Text(
            symbolDetails?.formattedRate(humanic: deal.executionPrice) ?? SymbolData.formattedRateDefault(humanic: deal.executionPrice),
            style: popup_constants.textStyleBodyBold,
          ),
        ]),
        Row(children: <Widget>[
          Text(l10n.closed, style: popup_constants.textStyleBody),
          const Spacer(),
          Text(
            DateTime.fromMillisecondsSinceEpoch(deal.executionTimestamp).formatted(),
            style: popup_constants.textStyleBodyBold,
          ),
        ]),
      ],
    );
  }

  Future<PopupResult> showPosionRejected(AppLocalizations l10n, ProtoOAExecutionEvent event) {
    final UserState userState = GetIt.I<UserState>();
    final TraderData? trader = userState.trader(event.ctidTraderAccountId);
    final ProtoOAOrder oaOrder = event.order!;
    final SymbolData? symbol = trader?.tree.symbol(event.order?.tradeData.symbolId);
    final bool isRejected = event.executionType == ProtoOAExecutionType.orderRejected;

    return showPopup(
      title: l10n.positionWas(isRejected ? 'rejected' : 'cancelled'),
      content: <Widget>[
        Text(
          l10n.buySellSymbolPositionWas(
            oaOrder.tradeData.tradeSide.name,
            symbol?.name ?? '',
            isRejected ? 'rejected' : 'cancelled',
          ),
          style: popup_constants.textStyleBody,
        ),
        if (trader?.id != userState.selectedTraderId)
          Row(children: <Widget>[
            Text('${l10n.broker}:', style: popup_constants.textStyleBody),
            const Spacer(),
            Text(trader?.name ?? '----', style: popup_constants.textStyleBodyBold),
          ]),
        if (trader?.id != userState.selectedTraderId)
          Row(children: <Widget>[
            Text('${l10n.account}:', style: popup_constants.textStyleBody),
            const Spacer(),
            Text(trader?.login.toString() ?? '----', style: popup_constants.textStyleBodyBold),
          ]),
        if (trader?.id != userState.selectedTraderId) const SizedBox(height: 16),
        Row(children: <Widget>[
          Text(l10n.orderId, style: popup_constants.textStyleBody),
          const Spacer(),
          Text(oaOrder.orderId.toString(), style: popup_constants.textStyleBodyBold),
        ]),
        Row(children: <Widget>[
          Text(l10n.amount, style: popup_constants.textStyleBody),
          const Spacer(),
          Text(
            symbol?.details?.formattedVolumeWithUnits(system: oaOrder.tradeData.volume) ?? SymbolData.formattedVolumeDefault(system: oaOrder.tradeData.volume),
            style: popup_constants.textStyleBodyBold,
          ),
        ]),
        Row(children: <Widget>[
          Text(isRejected ? l10n.rejected : l10n.cancelled, style: popup_constants.textStyleBody),
          const Spacer(),
          Text(
            DateTime.fromMillisecondsSinceEpoch(oaOrder.utcLastUpdateTimestamp ?? 0).formatted(),
            style: popup_constants.textStyleBodyBold,
          ),
        ]),
      ],
    );
  }

  Future<PopupResult> showPositionStopOut(AppLocalizations l10n, ProtoOAExecutionEvent event, {SymbolDetailsData? symbolDetails}) async {
    final ProtoOAOrder oaOrder = event.order!;
    final ProtoOAPosition oaPosition = event.position!;
    final ProtoOADeal oaDeal = event.deal!;
    final bool isPartial = oaPosition.tradeData.volume > 0;
    final ProtoOAClosePositionDetail? closeDetail = oaDeal.closePositionDetail;
    final UserState userState = GetIt.I<UserState>();
    final TraderData? trader = userState.trader(event.ctidTraderAccountId);
    final SymbolData? symbol = trader?.tree.symbol(oaOrder.tradeData.symbolId);
    double? pnl;

    symbolDetails ??= symbol?.details;

    if (symbolDetails == null && symbol != null && GetIt.I<SimultaneousTrdaingState>().isAccountPaired(event.ctidTraderAccountId)) {
      final Iterable<int> accounts = GetIt.I<SimultaneousTrdaingState>().pariedAccounts;
      for (final int accountId in accounts) {
        final TraderData? account = userState.trader(accountId);
        final Iterable<SymbolData> papiredSymbols = account?.tree.findSymbolForSimultaneousTrading(name: symbol.name) ?? <SymbolData>[];

        for (final SymbolData s in papiredSymbols) {
          if (s.details != null) {
            symbolDetails = s.details;
            break;
          }
        }

        if (symbolDetails != null) break;
      }
    }

    if (symbolDetails != null && symbol != null) {
      try {
        symbolDetails = await symbol.getDetailsData();
      } catch (e) {
        Logger.error("Can't load symbol details for ${symbol.name}(${symbol.id})");
      }
    }

    if (closeDetail != null) {
      pnl = (closeDetail.grossProfit + closeDetail.swap + closeDetail.commission).toDouble();
      pnl = trader?.toMoney(pnl.toInt()) ?? pnl / math.pow(10, oaPosition.moneyDigits ?? 0);
    }

    return showPopup(
      title: l10n.stopOutClosure,
      content: <Widget>[
        Text(
          l10n.buySellSymbolStopOut(oaOrder.tradeData.tradeSide.name, symbol?.name ?? '', isPartial.toString()),
          style: popup_constants.textStyleBody,
        ),
        if (trader?.id != userState.selectedTraderId)
          Row(children: <Widget>[
            Text('${l10n.broker}:', style: popup_constants.textStyleBody),
            const Spacer(),
            Text(trader?.name ?? '----', style: popup_constants.textStyleBodyBold),
          ]),
        if (trader?.id != userState.selectedTraderId)
          Row(children: <Widget>[
            Text('${l10n.account}:', style: popup_constants.textStyleBody),
            const Spacer(),
            Text(trader?.login.toString() ?? '----', style: popup_constants.textStyleBodyBold),
          ]),
        if (trader?.id != userState.selectedTraderId) const SizedBox(height: 16),
        Row(children: <Widget>[
          Text(l10n.positionId, style: popup_constants.textStyleBody),
          const Spacer(),
          Text(oaPosition.positionId.toString(), style: popup_constants.textStyleBodyBold),
        ]),
        if (isPartial)
          Row(children: <Widget>[
            Text(l10n.amount, style: popup_constants.textStyleBody),
            const Spacer(),
            Text(
              symbolDetails?.formattedVolumeWithUnits(system: oaPosition.tradeData.volume) ??
                  SymbolData.formattedVolumeDefault(system: oaPosition.tradeData.volume),
              style: popup_constants.textStyleBodyBold,
            ),
          ]),
        Row(children: <Widget>[
          Text(isPartial ? l10n.closedAmount : l10n.amount, style: popup_constants.textStyleBody),
          const Spacer(),
          Text(
            symbolDetails?.formattedVolumeWithUnits(system: oaDeal.filledVolume) ?? SymbolData.formattedVolumeDefault(system: oaDeal.filledVolume),
            style: popup_constants.textStyleBodyBold,
          ),
        ]),
        Row(children: <Widget>[
          Text(l10n.realizedPnl, style: popup_constants.textStyleBody),
          const Spacer(),
          Text(
            pnl == null ? '----' : trader?.formattedMoneyWithCurrency(money: pnl) ?? pnl.toComaSeparated(decimals: oaPosition.moneyDigits),
            style: popup_constants.textStyleBodyBold.copyWith(color: pnl == null || pnl < 0 ? THEME.red : THEME.green),
          ),
        ]),
        Row(children: <Widget>[
          Text(l10n.openingPrice, style: popup_constants.textStyleBody),
          const Spacer(),
          Text(
            closeDetail == null
                ? '----'
                : symbolDetails?.formattedRate(humanic: closeDetail.entryPrice) ?? SymbolData.formattedRateDefault(humanic: closeDetail.entryPrice),
            style: popup_constants.textStyleBodyBold,
          ),
        ]),
        Row(children: <Widget>[
          Text(l10n.opened, style: popup_constants.textStyleBody),
          const Spacer(),
          Text(
            DateTime.fromMillisecondsSinceEpoch(oaPosition.tradeData.openTimestamp ?? 0).formatted(),
            style: popup_constants.textStyleBodyBold,
          ),
        ]),
        Row(children: <Widget>[
          Text(l10n.closingPrice, style: popup_constants.textStyleBody),
          const Spacer(),
          Text(
            symbolDetails?.formattedRate(humanic: oaDeal.executionPrice) ?? SymbolData.formattedRateDefault(humanic: oaDeal.executionPrice),
            style: popup_constants.textStyleBodyBold,
          ),
        ]),
        Row(children: <Widget>[
          Text(l10n.closed, style: popup_constants.textStyleBody),
          const Spacer(),
          Text(
            DateTime.fromMillisecondsSinceEpoch(oaDeal.executionTimestamp).formatted(),
            style: popup_constants.textStyleBodyBold,
          ),
        ]),
      ],
    );
  }

  Future<PopupResult> showPositionExecutionRejected(AppLocalizations l10n, ProtoOAExecutionEvent event) {
    final ProtoOAOrder oaOrder = event.order!;
    final UserState userState = GetIt.I<UserState>();
    final TraderData? trader = userState.trader(event.ctidTraderAccountId);
    final SymbolData? symbol = trader?.tree.symbol(oaOrder.tradeData.symbolId);

    return showPopup(
      title: l10n.positionExecutionRejected,
      content: <Widget>[
        Text(
          l10n.buySellSymbolPositionCantExecute(oaOrder.tradeData.tradeSide.name, symbol?.name ?? ''),
          style: popup_constants.textStyleBody,
        ),
        if (trader?.id != userState.selectedTraderId)
          Row(children: <Widget>[
            Text('${l10n.broker}:', style: popup_constants.textStyleBody),
            const Spacer(),
            Text(trader?.name ?? '----', style: popup_constants.textStyleBodyBold),
          ]),
        if (trader?.id != userState.selectedTraderId)
          Row(children: <Widget>[
            Text('${l10n.account}:', style: popup_constants.textStyleBody),
            const Spacer(),
            Text(trader?.login.toString() ?? '----', style: popup_constants.textStyleBodyBold),
          ]),
        if (trader?.id != userState.selectedTraderId) const SizedBox(height: 16),
        Row(children: <Widget>[
          Text(l10n.orderId, style: popup_constants.textStyleBody),
          const Spacer(),
          Text(
            oaOrder.orderId.toString(),
            style: popup_constants.textStyleBodyBold,
          ),
        ]),
        Row(children: <Widget>[
          Text(l10n.positionId, style: popup_constants.textStyleBody),
          const Spacer(),
          Text(
            oaOrder.positionId?.toString() ?? '----',
            style: popup_constants.textStyleBodyBold,
          ),
        ]),
        Row(children: <Widget>[
          Text(l10n.amount, style: popup_constants.textStyleBody),
          const Spacer(),
          Text(
            symbol?.details?.formattedVolume(system: oaOrder.tradeData.volume) ?? SymbolData.formattedVolumeDefault(system: oaOrder.tradeData.volume),
            style: popup_constants.textStyleBodyBold,
          ),
        ]),
        Row(children: <Widget>[
          Text(l10n.rejected, style: popup_constants.textStyleBody),
          const Spacer(),
          Text(
            DateTime.fromMillisecondsSinceEpoch(oaOrder.utcLastUpdateTimestamp ?? 0).formatted(),
            style: popup_constants.textStyleBodyBold,
          ),
        ]),
      ],
    );
  }

  Future<PopupResult> showNewOrderError(AppLocalizations l10n, ProtoOAOrderErrorEvent event) {
    return showError(l10n, '${event.errorCode}.\n${event.description}');
  }

  Future<PopupResult> showOrderExecutionFaild(AppLocalizations l10n, int orderId) {
    return showPopup(title: l10n.orderExecutionFailed, message: l10n.orderFillError(orderId));
  }

  Future<PopupResult> showPendingOrderWasCreated(AppLocalizations l10n, ProtoOAExecutionEvent event, {SymbolDetailsData? symbolDetails}) {
    final UserState userState = GetIt.I<UserState>();
    final TraderData? trader = userState.trader(event.ctidTraderAccountId);
    final ProtoOAOrder oaOrder = event.order!;
    final SymbolData? symbol = trader?.tree.symbol(oaOrder.tradeData.symbolId);
    final double price = oaOrder.limitPrice ?? oaOrder.stopPrice!;
    double? takeProfit;
    double? stopLoss;

    symbolDetails ??= symbol?.details;

    if (oaOrder.relativeTakeProfit != null) {
      takeProfit = price + SymbolData.humanicRateFromSystem(oaOrder.relativeTakeProfit!) * (oaOrder.tradeData.tradeSide == ProtoOATradeSide.buy ? 1 : -1);
    }
    if (oaOrder.relativeStopLoss != null) {
      stopLoss = price - SymbolData.humanicRateFromSystem(oaOrder.relativeStopLoss!) * (oaOrder.tradeData.tradeSide == ProtoOATradeSide.buy ? 1 : -1);
    }

    String? trailingStop;
    if (stopLoss != null && oaOrder.trailingStopLoss == true) {
      final int? tradingStopDist = userState.trailingStopValues.valueOfOrder(trader?.id ?? -1, oaOrder.orderId);
      if (tradingStopDist != null) {
        trailingStop = symbolDetails?.formattedPips(system: tradingStopDist) ?? SymbolData.formattedRateDefault(system: tradingStopDist);
      } else {
        trailingStop = symbolDetails?.formattedRate(humanic: stopLoss) ?? SymbolData.formattedRateDefault(humanic: stopLoss);
      }
    }

    return showPopup(
      title: l10n.pendingOrderState('created'),
      content: <Widget>[
        Text(
          l10n.buySellSymbolOrderState(oaOrder.tradeData.tradeSide.name, symbol?.name ?? '', 'created'),
          style: popup_constants.textStyleBody,
        ),
        if (trader?.id != userState.selectedTraderId)
          Row(children: <Widget>[
            Text('${l10n.broker}:', style: popup_constants.textStyleBody),
            const Spacer(),
            Text(trader?.name ?? '----', style: popup_constants.textStyleBodyBold),
          ]),
        if (trader?.id != userState.selectedTraderId)
          Row(children: <Widget>[
            Text('${l10n.account}:', style: popup_constants.textStyleBody),
            const Spacer(),
            Text(trader?.login.toString() ?? '----', style: popup_constants.textStyleBodyBold),
          ]),
        if (trader?.id != userState.selectedTraderId) const SizedBox(height: 16),
        Row(children: <Widget>[
          Text(l10n.orderId, style: popup_constants.textStyleBody),
          const Spacer(),
          Text(oaOrder.orderId.toString(), style: popup_constants.textStyleBodyBold),
        ]),
        Row(children: <Widget>[
          Text(l10n.amount, style: popup_constants.textStyleBody),
          const Spacer(),
          Text(
            symbolDetails?.formattedVolumeWithUnits(system: oaOrder.tradeData.volume) ?? SymbolData.formattedVolumeDefault(system: oaOrder.tradeData.volume),
            style: popup_constants.textStyleBodyBold,
          ),
        ]),
        Row(children: <Widget>[
          Text(l10n.price, style: popup_constants.textStyleBody),
          const Spacer(),
          Text(
            symbolDetails?.formattedRate(humanic: price) ?? SymbolData.formattedRateDefault(humanic: price),
            style: popup_constants.textStyleBodyBold,
          ),
        ]),
        Row(children: <Widget>[
          Text(l10n.takeProfit, style: popup_constants.textStyleBody),
          const Spacer(),
          Text(
            takeProfit == null ? l10n.no : (symbolDetails?.formattedRate(humanic: takeProfit) ?? SymbolData.formattedRateDefault(humanic: takeProfit)),
            style: popup_constants.textStyleBodyBold,
          )
        ]),
        Row(children: <Widget>[
          Text(trailingStop != null ? l10n.trailingStop : l10n.stopLoss, style: popup_constants.textStyleBody),
          const Spacer(),
          Text(
            trailingStop ??
                (stopLoss != null ? (symbolDetails?.formattedRate(humanic: stopLoss) ?? SymbolData.formattedRateDefault(humanic: stopLoss)) : l10n.no),
            style: popup_constants.textStyleBodyBold,
          ),
        ]),
        Row(children: <Widget>[
          Text(l10n.created, style: popup_constants.textStyleBody),
          const Spacer(),
          Text(
            DateTime.fromMillisecondsSinceEpoch(oaOrder.tradeData.openTimestamp ?? 0).formatted(),
            style: popup_constants.textStyleBody,
          ),
        ]),
        Row(children: <Widget>[
          Text(l10n.goodTill, style: popup_constants.textStyleBody),
          const Spacer(),
          Text(
            oaOrder.timeInForce == ProtoOATimeInForce.goodTillCancel
                ? l10n.cancelled
                : DateTime.fromMillisecondsSinceEpoch(oaOrder.expirationTimestamp!).formatted(),
            style: popup_constants.textStyleBody,
          ),
        ]),
      ],
    );
  }

  Future<PopupResult> showPendingOrderWasCancelled(AppLocalizations l10n, ProtoOAExecutionEvent event, {SymbolDetailsData? symbolDetails}) {
    final UserState userState = GetIt.I<UserState>();
    final TraderData? trader = userState.trader(event.ctidTraderAccountId);
    final ProtoOAOrder oaOrder = event.order!;
    final SymbolData? symbol = trader?.tree.symbol(oaOrder.tradeData.symbolId);
    final double price = oaOrder.stopPrice ?? oaOrder.limitPrice!;
    final int volume = oaOrder.tradeData.volume - (oaOrder.executedVolume ?? 0);

    symbolDetails ??= symbol?.details;

    return showPopup(
      title: l10n.pendingOrderState('cancelled'),
      content: <Widget>[
        Text(
          l10n.buySellSymbolOrderState(
              oaOrder.tradeData.tradeSide.name, symbol?.name ?? '----', (oaOrder.executedVolume ?? 0) > 0 ? 'cancelledPartially' : 'cancelled'),
          style: popup_constants.textStyleBody,
        ),
        if (trader?.id != userState.selectedTraderId)
          Row(children: <Widget>[
            Text('${l10n.broker}:', style: popup_constants.textStyleBody),
            const Spacer(),
            Text(trader?.name ?? '----', style: popup_constants.textStyleBodyBold),
          ]),
        if (trader?.id != userState.selectedTraderId)
          Row(children: <Widget>[
            Text('${l10n.account}:', style: popup_constants.textStyleBody),
            const Spacer(),
            Text(trader?.login.toString() ?? '----', style: popup_constants.textStyleBodyBold),
          ]),
        if (trader?.id != userState.selectedTraderId) const SizedBox(height: 16),
        Row(children: <Widget>[
          Text(l10n.orderId, style: popup_constants.textStyleBody),
          const Spacer(),
          Text(oaOrder.orderId.toString(), style: popup_constants.textStyleBodyBold),
        ]),
        Row(children: <Widget>[
          Text(l10n.amount, style: popup_constants.textStyleBody),
          const Spacer(),
          Text(
            symbolDetails?.formattedVolumeWithUnits(system: volume) ?? SymbolData.formattedVolumeDefault(system: volume),
            style: popup_constants.textStyleBodyBold,
          ),
        ]),
        Row(children: <Widget>[
          Text(l10n.price, style: popup_constants.textStyleBody),
          const Spacer(),
          Text(
            symbolDetails?.formattedRate(humanic: price) ?? SymbolData.formattedRateDefault(humanic: price),
            style: popup_constants.textStyleBodyBold,
          ),
        ]),
        Row(children: <Widget>[
          Text(l10n.cancelled, style: popup_constants.textStyleBody),
          const Spacer(),
          Text(
            DateTime.fromMillisecondsSinceEpoch(oaOrder.utcLastUpdateTimestamp ?? 0).formatted(),
            style: popup_constants.textStyleBodyBold,
          ),
        ]),
      ],
    );
  }

  Future<PopupResult> showPendingOrderRejected(AppLocalizations l10n, ProtoOAExecutionEvent event, {SymbolDetailsData? symbolDetails}) {
    final UserState userState = GetIt.I<UserState>();
    final TraderData? trader = userState.trader(event.ctidTraderAccountId);
    final ProtoOAOrder oaOrder = event.order!;
    final SymbolData? symbol = trader?.tree.symbol(oaOrder.tradeData.symbolId);
    final double price = oaOrder.stopPrice ?? oaOrder.limitPrice!;

    symbolDetails ??= symbol?.details;

    return showPopup(
      title: l10n.pendingOrderState('rejected'),
      content: <Widget>[
        Text(
          l10n.buySellSymbolOrderState(oaOrder.tradeData.tradeSide.name, symbol?.name ?? '----', 'rejected'),
          style: popup_constants.textStyleBody,
        ),
        if (trader?.id != userState.selectedTraderId)
          Row(children: <Widget>[
            Text('${l10n.broker}:', style: popup_constants.textStyleBody),
            const Spacer(),
            Text(trader?.name ?? '----', style: popup_constants.textStyleBodyBold),
          ]),
        if (trader?.id != userState.selectedTraderId)
          Row(children: <Widget>[
            Text('${l10n.account}:', style: popup_constants.textStyleBody),
            const Spacer(),
            Text(trader?.login.toString() ?? '----', style: popup_constants.textStyleBodyBold),
          ]),
        if (trader?.id != userState.selectedTraderId) const SizedBox(height: 16),
        Row(children: <Widget>[
          Text(l10n.orderId, style: popup_constants.textStyleBody),
          const Spacer(),
          Text(oaOrder.orderId.toString(), style: popup_constants.textStyleBodyBold),
        ]),
        Row(children: <Widget>[
          Text(l10n.amount, style: popup_constants.textStyleBody),
          const Spacer(),
          Text(
            symbolDetails?.formattedVolumeWithUnits(system: oaOrder.tradeData.volume) ?? SymbolData.formattedVolumeDefault(system: oaOrder.tradeData.volume),
            style: popup_constants.textStyleBodyBold,
          ),
        ]),
        Row(children: <Widget>[
          Text(l10n.price, style: popup_constants.textStyleBody),
          const Spacer(),
          Text(
            symbolDetails?.formattedRate(humanic: price) ?? SymbolData.formattedRateDefault(humanic: price),
            style: popup_constants.textStyleBodyBold,
          ),
        ]),
        Row(children: <Widget>[
          Text(l10n.rejected, style: popup_constants.textStyleBody),
          const Spacer(),
          Text(
            DateTime.fromMillisecondsSinceEpoch(oaOrder.utcLastUpdateTimestamp ?? 0).formatted(),
            style: popup_constants.textStyleBodyBold,
          ),
        ]),
      ],
    );
  }

  Future<PopupResult> showPendingOrderExpired(AppLocalizations l10n, ProtoOAExecutionEvent event, {SymbolDetailsData? symbolDetails}) {
    final UserState userState = GetIt.I<UserState>();
    final TraderData? trader = userState.trader(event.ctidTraderAccountId);
    final ProtoOAOrder oaOrder = event.order!;
    final SymbolData? symbol = trader?.tree.symbol(oaOrder.tradeData.symbolId);

    symbolDetails ??= symbol?.details;

    return showPopup(
      title: l10n.pendingOrderState('expired'),
      content: <Widget>[
        Text(
          l10n.buySellSymbolOrderState(oaOrder.tradeData.tradeSide.name, symbol?.name ?? '', 'expired'),
          style: popup_constants.textStyleBody,
        ),
        if (trader?.id != userState.selectedTraderId)
          Row(children: <Widget>[
            Text('${l10n.broker}:', style: popup_constants.textStyleBody),
            const Spacer(),
            Text(trader?.name ?? '----', style: popup_constants.textStyleBodyBold),
          ]),
        if (trader?.id != userState.selectedTraderId)
          Row(children: <Widget>[
            Text('${l10n.account}:', style: popup_constants.textStyleBody),
            const Spacer(),
            Text(trader?.login.toString() ?? '----', style: popup_constants.textStyleBodyBold),
          ]),
        if (trader?.id != userState.selectedTraderId) const SizedBox(height: 16),
        Row(children: <Widget>[
          Text(l10n.orderId, style: popup_constants.textStyleBody),
          const Spacer(),
          Text(oaOrder.orderId.toString(), style: popup_constants.textStyleBodyBold),
        ]),
        Row(children: <Widget>[
          Text(l10n.amount, style: popup_constants.textStyleBody),
          const Spacer(),
          Text(
            symbolDetails?.formattedVolumeWithUnits(system: oaOrder.tradeData.volume) ?? SymbolData.formattedVolumeDefault(system: oaOrder.tradeData.volume),
            style: popup_constants.textStyleBodyBold,
          ),
        ]),
        Row(children: <Widget>[
          Text(l10n.price, style: popup_constants.textStyleBody),
          const Spacer(),
          Text(
            symbolDetails?.formattedRate(humanic: oaOrder.limitPrice ?? oaOrder.stopPrice) ??
                SymbolData.formattedVolumeDefault(humanic: oaOrder.stopPrice ?? oaOrder.limitPrice),
            style: popup_constants.textStyleBodyBold,
          ),
        ]),
        Row(children: <Widget>[
          Text(l10n.expired, style: popup_constants.textStyleBody),
          const Spacer(),
          Text(
            DateTime.fromMillisecondsSinceEpoch(oaOrder.utcLastUpdateTimestamp ?? 0).formatted(),
            style: popup_constants.textStyleBodyBold,
          ),
        ]),
      ],
    );
  }

  Future<PopupResult> showPendingOrderUpdated(AppLocalizations l10n, ProtoOAExecutionEvent event, {SymbolDetailsData? symbolDetails}) {
    final UserState userState = GetIt.I<UserState>();
    final TraderData? trader = userState.trader(event.ctidTraderAccountId);
    final ProtoOAOrder oaOrder = event.order!;
    final SymbolData? symbol = trader?.tree.symbol(oaOrder.tradeData.symbolId);
    final bool isBuy = oaOrder.tradeData.tradeSide == ProtoOATradeSide.buy;
    final double rate = oaOrder.limitPrice ?? oaOrder.stopPrice!;
    String takeProfit = l10n.no;
    String stopLoss = l10n.no;
    String? trailingStop;

    symbolDetails ??= symbol?.details;

    if (oaOrder.relativeTakeProfit != null) {
      final double tpRate = rate + SymbolData.humanicRateFromSystem(oaOrder.relativeTakeProfit!) * (isBuy ? 1 : -1);
      takeProfit = symbolDetails?.formattedRate(humanic: tpRate) ?? SymbolData.formattedRateDefault(humanic: tpRate);
    }

    if (oaOrder.trailingStopLoss == true && oaOrder.relativeStopLoss != null) {
      final int? tralingStopDist = userState.trailingStopValues.valueOfOrder(trader?.id ?? -1, oaOrder.orderId);
      if (tralingStopDist != null) {
        trailingStop = symbolDetails?.formattedPips(system: tralingStopDist) ?? SymbolData.formattedRateDefault(system: tralingStopDist);
      } else {
        final double slRate = rate + SymbolData.humanicRateFromSystem(oaOrder.relativeStopLoss!) * (isBuy ? -1 : 1);
        trailingStop = symbolDetails?.formattedRate(humanic: slRate) ?? SymbolData.formattedRateDefault(humanic: slRate);
      }
    } else if (oaOrder.relativeStopLoss != null) {
      final double slRate = rate + SymbolData.humanicRateFromSystem(oaOrder.relativeStopLoss!) * (isBuy ? -1 : 1);
      stopLoss = symbolDetails?.formattedRate(humanic: slRate) ?? SymbolData.formattedRateDefault(humanic: slRate);
    }

    return showPopup(
      title: l10n.pendingOrderState('updated'),
      content: <Widget>[
        Text(
          l10n.buySellSymbolOrderState(oaOrder.tradeData.tradeSide.name, symbol?.name ?? '', 'updated'),
          style: popup_constants.textStyleBody,
        ),
        if (trader != null && trader.id != userState.selectedTraderId)
          Row(children: <Widget>[
            Text('${l10n.broker}:', style: popup_constants.textStyleBody),
            const Spacer(),
            Text(trader.name, style: popup_constants.textStyleBodyBold),
          ]),
        if (trader != null && trader.id != userState.selectedTraderId)
          Row(children: <Widget>[
            Text('${l10n.account}:', style: popup_constants.textStyleBody),
            const Spacer(),
            Text(trader.login.toString(), style: popup_constants.textStyleBodyBold),
          ]),
        if (trader != null && trader.id != userState.selectedTraderId) const SizedBox(height: 16),
        Row(children: <Widget>[
          Text(l10n.orderId, style: popup_constants.textStyleBody),
          const Spacer(),
          Text(oaOrder.orderId.toString(), style: popup_constants.textStyleBodyBold),
        ]),
        Row(children: <Widget>[
          Text(l10n.amount, style: popup_constants.textStyleBody),
          const Spacer(),
          Text(
            symbolDetails?.formattedVolumeWithUnits(system: oaOrder.tradeData.volume) ?? SymbolData.formattedVolumeDefault(system: oaOrder.tradeData.volume),
            style: popup_constants.textStyleBodyBold,
          ),
        ]),
        Row(children: <Widget>[
          Text(l10n.price, style: popup_constants.textStyleBody),
          const Spacer(),
          Text(
            symbolDetails?.formattedRate(humanic: rate) ?? SymbolData.formattedRateDefault(humanic: rate),
            style: popup_constants.textStyleBodyBold,
          ),
        ]),
        Row(children: <Widget>[
          Text(l10n.takeProfit, style: popup_constants.textStyleBody),
          const Spacer(),
          Text(takeProfit, style: popup_constants.textStyleBodyBold),
        ]),
        Row(children: <Widget>[
          Text(trailingStop != null ? l10n.trailingStop : l10n.stopLoss, style: popup_constants.textStyleBody),
          const Spacer(),
          Text(trailingStop ?? stopLoss, style: popup_constants.textStyleBodyBold),
        ]),
        Row(children: <Widget>[
          Text(l10n.created, style: popup_constants.textStyleBody),
          const Spacer(),
          Text(
            DateTime.fromMillisecondsSinceEpoch(oaOrder.tradeData.openTimestamp ?? 0).formatted(),
            style: popup_constants.textStyleBodyBold,
          ),
        ]),
        Row(children: <Widget>[
          Text(l10n.updated, style: popup_constants.textStyleBody),
          const Spacer(),
          Text(
            DateTime.fromMillisecondsSinceEpoch(oaOrder.utcLastUpdateTimestamp ?? 0).formatted(),
            style: popup_constants.textStyleBodyBold,
          ),
        ]),
        Row(children: <Widget>[
          Text(l10n.goodTill, style: popup_constants.textStyleBody),
          const Spacer(),
          Text(
            oaOrder.expirationTimestamp != null ? DateTime.fromMillisecondsSinceEpoch(oaOrder.expirationTimestamp!).formatted() : l10n.cancelled,
            style: popup_constants.textStyleBodyBold,
          ),
        ]),
      ],
    );
  }

  Future<PopupResult> handlePendingOrderExecutedEvent(AppLocalizations l10n, ProtoOAExecutionEvent event, {SymbolDetailsData? symbolDetails}) {
    final ProtoOAOrder oaOrder = event.order!;
    final ProtoOAPosition oaPosition = event.position!;
    final ProtoOADeal oaDeal = event.deal!;

    if (oaPosition.tradeData.volume == 0) {
      if (event.executionType == ProtoOAExecutionType.orderFilled) {
        return showPendingOrderExecutedAsClosed(l10n, event, symbolDetails: symbolDetails);
      } else {
        return showPendingOrderExecutedAsTemporaryClosed(l10n, event, symbolDetails: symbolDetails);
      }
    } else if (oaPosition.tradeData.volume == oaDeal.filledVolume &&
        oaPosition.tradeData.tradeSide == oaOrder.tradeData.tradeSide &&
        oaDeal.filledVolume == oaOrder.executedVolume) {
      return showPendingOrderExecutedAsOpened(l10n, event, symbolDetails: symbolDetails);
    } else {
      return showPendingOrderExecutedAsChanged(l10n, event, symbolDetails: symbolDetails);
    }
  }

  Future<PopupResult> showPendingOrderExecutedAsOpened(AppLocalizations l10n, ProtoOAExecutionEvent event, {SymbolDetailsData? symbolDetails}) {
    final ProtoOAOrder oaOrder = event.order!;
    final ProtoOAPosition oaPosition = event.position!;
    final bool isPartial = event.executionType == ProtoOAExecutionType.orderPartialFill;
    final UserState userState = GetIt.I<UserState>();
    final TraderData? trader = userState.trader(event.ctidTraderAccountId);
    final SymbolData? symbol = trader?.tree.symbol(oaOrder.tradeData.symbolId);
    double? pnl;
    String sl = l10n.no;

    symbolDetails ??= symbol?.details;

    if (event.deal?.closePositionDetail != null) {
      final ProtoOAClosePositionDetail details = event.deal!.closePositionDetail!;
      pnl = (details.grossProfit + details.swap + details.commission).toDouble();
      pnl = trader?.toMoney(pnl.toInt()) ?? pnl / math.pow(10, oaPosition.moneyDigits ?? 0);
    }

    if (oaPosition.stopLoss != null && oaPosition.trailingStopLoss == true) {
      final int? trailingStopDist = userState.trailingStopValues.valueOfPosition(trader?.id ?? -1, oaPosition.positionId);
      if (trailingStopDist != null) {
        sl = symbolDetails?.formattedPips(system: trailingStopDist) ?? SymbolData.formattedRateDefault(system: trailingStopDist);
      } else {
        sl = symbolDetails?.formattedRate(humanic: oaPosition.stopLoss) ?? SymbolData.formattedRateDefault(humanic: oaPosition.stopLoss);
      }
    } else if (oaPosition.stopLoss != null) {
      sl = symbolDetails?.formattedRate(humanic: oaPosition.stopLoss) ?? SymbolData.formattedRateDefault(humanic: oaPosition.stopLoss);
    }

    return showPopup(
      title: l10n.pendingOrderState(isPartial ? 'executedPartially' : 'executed'),
      content: <Widget>[
        Text(
          l10n.buySellSymbolPositionWas(oaPosition.tradeData.tradeSide.name, symbol?.name ?? '', 'opened'),
          style: popup_constants.textStyleBody,
        ),
        if (trader?.id != userState.selectedTraderId)
          Row(children: <Widget>[
            Text('${l10n.broker}:', style: popup_constants.textStyleBody),
            const Spacer(),
            Text(trader?.name ?? '----', style: popup_constants.textStyleBodyBold),
          ]),
        if (trader?.id != userState.selectedTraderId)
          Row(children: <Widget>[
            Text('${l10n.account}:', style: popup_constants.textStyleBody),
            const Spacer(),
            Text(trader?.login.toString() ?? '----', style: popup_constants.textStyleBodyBold),
          ]),
        if (trader?.id != userState.selectedTraderId) const SizedBox(height: 16),
        Row(children: <Widget>[
          Text(l10n.positionId, style: popup_constants.textStyleBody),
          const Spacer(),
          Text(oaPosition.positionId.toString(), style: popup_constants.textStyleBodyBold),
        ]),
        Row(children: <Widget>[
          Text(l10n.orderId, style: popup_constants.textStyleBody),
          const Spacer(),
          Text(oaOrder.orderId.toString(), style: popup_constants.textStyleBodyBold),
        ]),
        if (isPartial)
          Row(children: <Widget>[
            Text(l10n.filledAmount, style: popup_constants.textStyleBody),
            const Spacer(),
            Text(
              symbolDetails?.formattedVolumeWithUnits(system: oaOrder.executedVolume) ?? SymbolData.formattedVolumeDefault(system: oaOrder.executedVolume),
              style: popup_constants.textStyleBodyBold,
            ),
          ]),
        Row(children: <Widget>[
          Text(l10n.amount, style: popup_constants.textStyleBody),
          const Spacer(),
          Text(
            symbolDetails?.formattedVolumeWithUnits(system: oaOrder.tradeData.volume) ?? SymbolData.formattedVolumeDefault(system: oaOrder.tradeData.volume),
            style: popup_constants.textStyleBodyBold,
          ),
        ]),
        if (pnl != null)
          Row(children: <Widget>[
            Text(l10n.realizedPnl, style: popup_constants.textStyleBody),
            const Spacer(),
            Text(
              trader?.formattedMoneyWithCurrency(money: pnl) ?? pnl.toComaSeparated(decimals: oaPosition.moneyDigits),
              style: popup_constants.textStyleBodyBold.copyWith(color: pnl == null || pnl < 0 ? THEME.red : THEME.green),
            ),
          ]),
        Row(children: <Widget>[
          Text(l10n.price, style: popup_constants.textStyleBody),
          const Spacer(),
          Text(
            symbolDetails?.formattedRate(humanic: oaPosition.price) ?? SymbolData.formattedRateDefault(humanic: oaPosition.price),
            style: popup_constants.textStyleBodyBold,
          ),
        ]),
        Row(children: <Widget>[
          Text(l10n.takeProfit, style: popup_constants.textStyleBody),
          const Spacer(),
          Text(
            oaPosition.takeProfit == null
                ? l10n.no
                : symbolDetails?.formattedRate(humanic: oaPosition.takeProfit) ?? SymbolData.formattedRateDefault(humanic: oaPosition.takeProfit),
            style: popup_constants.textStyleBodyBold,
          ),
        ]),
        Row(children: <Widget>[
          Text(oaPosition.trailingStopLoss == true && oaPosition.stopLoss != null ? l10n.trailingStop : l10n.stopLoss, style: popup_constants.textStyleBody),
          const Spacer(),
          Text(sl, style: popup_constants.textStyleBodyBold),
        ]),
        Row(children: <Widget>[
          Text(l10n.created, style: popup_constants.textStyleBody),
          const Spacer(),
          Text(
            DateTime.fromMillisecondsSinceEpoch(oaPosition.tradeData.openTimestamp ?? 0).formatted(),
            style: popup_constants.textStyleBodyBold,
          ),
        ]),
        if (isPartial)
          Row(children: <Widget>[
            Text(l10n.goodTill, style: popup_constants.textStyleBody),
            const Spacer(),
            Text(
              oaOrder.expirationTimestamp == null ? l10n.cancelled : DateTime.fromMillisecondsSinceEpoch(oaOrder.expirationTimestamp ?? 0).formatted(),
              style: popup_constants.textStyleBodyBold,
            ),
          ]),
      ],
    );
  }

  Future<PopupResult> showPendingOrderExecutedAsClosed(AppLocalizations l10n, ProtoOAExecutionEvent event, {SymbolDetailsData? symbolDetails}) {
    final ProtoOAOrder oaOrder = event.order!;
    final ProtoOAPosition oaPosition = event.position!;
    final ProtoOADeal oaDeal = event.deal!;
    final ProtoOAClosePositionDetail? closeDetail = event.deal?.closePositionDetail;
    final bool isPartial = event.executionType == ProtoOAExecutionType.orderPartialFill;
    final UserState userState = GetIt.I<UserState>();
    final TraderData? trader = userState.trader(event.ctidTraderAccountId);
    final SymbolData? symbol = trader?.tree.symbol(oaOrder.tradeData.symbolId);
    double? pnl;

    symbolDetails ??= symbol?.details;

    if (closeDetail != null) {
      pnl = (closeDetail.grossProfit + closeDetail.swap + closeDetail.commission).toDouble();
      pnl = trader?.toMoney(pnl.toInt()) ?? pnl / math.pow(10, oaPosition.moneyDigits ?? 0);
    }

    return showPopup(
      title: l10n.pendingOrderState(isPartial ? 'executedPartially' : 'executed'),
      content: <Widget>[
        Text(
          l10n.buySellSymbolPositionWas(oaOrder.tradeData.tradeSide.name, symbol?.name ?? '', isPartial ? 'closedPartially' : 'closed'),
          style: popup_constants.textStyleBody,
        ),
        if (trader?.id != userState.selectedTraderId)
          Row(children: <Widget>[
            Text('${l10n.broker}:', style: popup_constants.textStyleBody),
            const Spacer(),
            Text(trader?.name ?? '----', style: popup_constants.textStyleBodyBold),
          ]),
        if (trader?.id != userState.selectedTraderId)
          Row(children: <Widget>[
            Text('${l10n.account}:', style: popup_constants.textStyleBody),
            const Spacer(),
            Text(trader?.login.toString() ?? '----', style: popup_constants.textStyleBodyBold),
          ]),
        if (trader?.id != userState.selectedTraderId) const SizedBox(height: 16),
        Row(children: <Widget>[
          Text(l10n.positionId, style: popup_constants.textStyleBody),
          const Spacer(),
          Text(oaPosition.positionId.toString(), style: popup_constants.textStyleBodyBold),
        ]),
        Row(children: <Widget>[
          Text(l10n.orderId, style: popup_constants.textStyleBody),
          const Spacer(),
          Text(oaOrder.orderId.toString(), style: popup_constants.textStyleBodyBold),
        ]),
        Row(children: <Widget>[
          Text(l10n.amount, style: popup_constants.textStyleBody),
          const Spacer(),
          Text(
            symbolDetails?.formattedVolumeWithUnits(system: oaPosition.tradeData.volume) ??
                SymbolData.formattedVolumeDefault(system: oaPosition.tradeData.volume),
            style: popup_constants.textStyleBodyBold,
          ),
        ]),
        if (isPartial)
          Row(children: <Widget>[
            Text(l10n.filledAmount, style: popup_constants.textStyleBody),
            const Spacer(),
            Text(
              symbolDetails?.formattedVolumeWithUnits(system: oaDeal.filledVolume) ?? SymbolData.formattedVolumeDefault(system: oaDeal.filledVolume),
              style: popup_constants.textStyleBodyBold,
            ),
          ]),
        Row(children: <Widget>[
          Text(l10n.realizedPnl, style: popup_constants.textStyleBody),
          const Spacer(),
          Text(
            pnl == null ? '----' : trader?.formattedMoneyWithCurrency(money: pnl) ?? pnl.toComaSeparated(decimals: oaPosition.moneyDigits),
            style: popup_constants.textStyleBodyBold,
          ),
        ]),
        Row(children: <Widget>[
          Text(l10n.openingPrice, style: popup_constants.textStyleBody),
          const Spacer(),
          Text(
            closeDetail == null
                ? '----'
                : symbolDetails?.formattedRate(humanic: closeDetail.entryPrice) ?? SymbolData.formattedRateDefault(humanic: closeDetail.entryPrice),
            style: popup_constants.textStyleBodyBold,
          ),
        ]),
        Row(children: <Widget>[
          Text(l10n.opened, style: popup_constants.textStyleBody),
          const Spacer(),
          Text(
            DateTime.fromMillisecondsSinceEpoch(oaPosition.tradeData.openTimestamp ?? 0).formatted(),
            style: popup_constants.textStyleBodyBold,
          ),
        ]),
        Row(children: <Widget>[
          Text(l10n.closingPrice, style: popup_constants.textStyleBody),
          const Spacer(),
          Text(
            symbolDetails?.formattedRate(humanic: oaDeal.executionPrice) ?? SymbolData.formattedRateDefault(humanic: oaDeal.executionPrice),
            style: popup_constants.textStyleBodyBold,
          ),
        ]),
        Row(children: <Widget>[
          Text(l10n.closed, style: popup_constants.textStyleBody),
          const Spacer(),
          Text(
            DateTime.fromMillisecondsSinceEpoch(oaDeal.executionTimestamp).formatted(),
            style: popup_constants.textStyleBodyBold,
          ),
        ]),
      ],
    );
  }

  Future<PopupResult> showPendingOrderExecutedAsTemporaryClosed(AppLocalizations l10n, ProtoOAExecutionEvent event, {SymbolDetailsData? symbolDetails}) {
    final ProtoOAOrder oaOrder = event.order!;
    final ProtoOAPosition oaPosition = event.position!;
    final ProtoOADeal oaDeal = event.deal!;
    final UserState userState = GetIt.I<UserState>();
    final TraderData? trader = userState.trader(event.ctidTraderAccountId);
    final SymbolData? symbol = trader?.tree.symbol(oaOrder.tradeData.symbolId);
    final String pendingAmount = oaOrder.executedVolume == null
        ? '----'
        : symbolDetails?.formattedVolume(system: oaOrder.tradeData.volume - oaOrder.executedVolume!) ??
            SymbolData.formattedVolumeDefault(system: oaOrder.tradeData.volume - oaOrder.executedVolume!);
    double? pnl;

    symbolDetails ??= symbol?.details;

    if (oaDeal.closePositionDetail != null) {
      pnl = (oaDeal.closePositionDetail!.grossProfit + oaDeal.closePositionDetail!.swap + oaDeal.closePositionDetail!.commission).toDouble();
      pnl = trader?.toMoney(pnl.toInt()) ?? pnl / math.pow(10, oaPosition.moneyDigits ?? 0);
    }

    return showPopup(
      title: l10n.pendingOrderState('executedPartially'),
      content: <Widget>[
        Text(
          l10n.positionTemporaryClose(oaOrder.tradeData.tradeSide.name, symbol?.name ?? ''),
          style: popup_constants.textStyleBody,
        ),
        if (trader?.id != userState.selectedTraderId)
          Row(children: <Widget>[
            Text('${l10n.broker}:', style: popup_constants.textStyleBody),
            const Spacer(),
            Text(trader?.name ?? '----', style: popup_constants.textStyleBodyBold),
          ]),
        if (trader?.id != userState.selectedTraderId)
          Row(children: <Widget>[
            Text('${l10n.account}:', style: popup_constants.textStyleBody),
            const Spacer(),
            Text(trader?.login.toString() ?? '----', style: popup_constants.textStyleBodyBold),
          ]),
        if (trader?.id != userState.selectedTraderId) const SizedBox(height: 16),
        Row(children: <Widget>[
          Text(l10n.positionId, style: popup_constants.textStyleBody),
          const Spacer(),
          Text(oaPosition.positionId.toString(), style: popup_constants.textStyleBodyBold),
        ]),
        Row(children: <Widget>[
          Text(l10n.closedAmount, style: popup_constants.textStyleBody),
          const Spacer(),
          Text(
            symbolDetails?.formattedVolumeWithUnits(system: oaDeal.volume) ?? SymbolData.formattedVolumeDefault(system: oaDeal.volume),
            style: popup_constants.textStyleBodyBold,
          ),
        ]),
        Row(children: <Widget>[
          Text(l10n.pendingAmount, style: popup_constants.textStyleBody),
          const Spacer(),
          Text(
            pendingAmount,
            style: popup_constants.textStyleBodyBold,
          ),
        ]),
        Row(children: <Widget>[
          Text(l10n.realizedPnl, style: popup_constants.textStyleBody),
          const Spacer(),
          Text(
            pnl == null ? '----' : trader?.formattedMoneyWithCurrency(money: pnl) ?? pnl.toComaSeparated(decimals: oaPosition.moneyDigits),
            style: popup_constants.textStyleBodyBold.copyWith(color: pnl == null || pnl < 0 ? THEME.red : THEME.green),
          ),
        ]),
        Row(children: <Widget>[
          Text(l10n.openingPrice, style: popup_constants.textStyleBody),
          const Spacer(),
          Text(
            symbolDetails?.formattedRate(humanic: oaDeal.closePositionDetail?.entryPrice) ??
                SymbolData.formattedRateDefault(humanic: oaDeal.closePositionDetail?.entryPrice),
            style: popup_constants.textStyleBodyBold,
          ),
        ]),
        Row(children: <Widget>[
          Text(l10n.opened, style: popup_constants.textStyleBody),
          const Spacer(),
          Text(
            DateTime.fromMillisecondsSinceEpoch(oaPosition.tradeData.openTimestamp ?? 0).formatted(),
            style: popup_constants.textStyleBodyBold,
          ),
        ]),
        Row(children: <Widget>[
          Text(l10n.closingPrice, style: popup_constants.textStyleBody),
          const Spacer(),
          Text(
            symbolDetails?.formattedRate(humanic: oaDeal.executionPrice) ?? SymbolData.formattedRateDefault(humanic: oaDeal.executionPrice),
            style: popup_constants.textStyleBodyBold,
          ),
        ]),
        Row(children: <Widget>[
          Text(l10n.closed, style: popup_constants.textStyleBody),
          const Spacer(),
          Text(
            DateTime.fromMillisecondsSinceEpoch(oaDeal.executionTimestamp).formatted(),
            style: popup_constants.textStyleBodyBold,
          ),
        ]),
      ],
    );
  }

  Future<PopupResult> showPendingOrderExecutedAsChanged(AppLocalizations l10n, ProtoOAExecutionEvent event, {SymbolDetailsData? symbolDetails}) {
    final bool isPartial = event.executionType == ProtoOAExecutionType.orderPartialFill;
    final ProtoOAOrder oaOrder = event.order!;
    final ProtoOAPosition oaPosition = event.position!;
    final ProtoOADeal oaDeal = event.deal!;
    final UserState userState = GetIt.I<UserState>();
    final TraderData? trader = userState.trader(event.ctidTraderAccountId);
    final SymbolData? symbol = trader?.tree.symbol(oaOrder.tradeData.symbolId);
    final String action;
    double? pnl;
    String sl = l10n.no;
    String tradeSide = oaOrder.tradeData.tradeSide.name;

    symbolDetails ??= symbol?.details;

    if (oaPosition.tradeData.tradeSide != oaOrder.tradeData.tradeSide) {
      action = 'decreased';
    } else if (oaPosition.tradeData.volume > oaDeal.filledVolume) {
      action = 'increased';
    } else {
      action = 'reversed';
      tradeSide = oaOrder.tradeData.tradeSide == ProtoOATradeSide.buy ? 'sell' : 'buy';
    }

    if (oaDeal.closePositionDetail != null) {
      pnl = (oaDeal.closePositionDetail!.grossProfit + oaDeal.closePositionDetail!.swap + oaDeal.closePositionDetail!.commission).toDouble();
      pnl = trader?.toMoney(pnl.toInt()) ?? pnl / math.pow(10, oaPosition.moneyDigits ?? 0);
    }

    if (oaPosition.stopLoss != null && oaPosition.trailingStopLoss == true) {
      final int? trailingStopDist = userState.trailingStopValues.valueOfPosition(trader?.id ?? -1, oaPosition.positionId);
      if (trailingStopDist != null) {
        sl = symbolDetails?.formattedPips(system: trailingStopDist) ?? SymbolData.formattedRateDefault(system: trailingStopDist);
      } else {
        sl = symbolDetails?.formattedRate(humanic: oaPosition.stopLoss) ?? SymbolData.formattedRateDefault(humanic: oaPosition.stopLoss);
      }
    } else if (oaPosition.stopLoss != null) {
      sl = symbolDetails?.formattedRate(humanic: oaPosition.stopLoss) ?? SymbolData.formattedRateDefault(humanic: oaPosition.stopLoss);
    }

    return showPopup(
      title: l10n.pendingOrderState(isPartial ? 'executedPartially' : 'executed'),
      content: <Widget>[
        Text(
          l10n.buySellSymbolPositionWas(tradeSide, symbol?.name ?? '', action) +
              (action == 'reversed' ? " ${l10n.nowYourPositinBuySellSymbol(oaPosition.tradeData.tradeSide.name, symbol?.name ?? '')}" : ''),
          style: popup_constants.textStyleBody,
        ),
        if (trader?.id != userState.selectedTraderId)
          Row(children: <Widget>[
            Text('${l10n.broker}:', style: popup_constants.textStyleBody),
            const Spacer(),
            Text(trader?.name ?? '----', style: popup_constants.textStyleBodyBold),
          ]),
        if (trader?.id != userState.selectedTraderId)
          Row(children: <Widget>[
            Text('${l10n.account}:', style: popup_constants.textStyleBody),
            const Spacer(),
            Text(trader?.login.toString() ?? '----', style: popup_constants.textStyleBodyBold),
          ]),
        if (trader?.id != userState.selectedTraderId) const SizedBox(height: 16),
        Row(children: <Widget>[
          Text(l10n.positionId, style: popup_constants.textStyleBody),
          const Spacer(),
          Text(oaPosition.positionId.toString(), style: popup_constants.textStyleBodyBold),
        ]),
        Row(children: <Widget>[
          Text(l10n.orderId, style: popup_constants.textStyleBody),
          const Spacer(),
          Text(oaOrder.orderId.toString(), style: popup_constants.textStyleBodyBold),
        ]),
        if (isPartial)
          Row(children: <Widget>[
            Text(l10n.filledAmount, style: popup_constants.textStyleBody),
            const Spacer(),
            Text(
              symbolDetails?.formattedVolumeWithUnits(system: oaOrder.executedVolume) ?? SymbolData.formattedVolumeDefault(system: oaOrder.executedVolume),
              style: popup_constants.textStyleBodyBold,
            ),
          ]),
        Row(children: <Widget>[
          Text(l10n.amount, style: popup_constants.textStyleBody),
          const Spacer(),
          Text(
            symbolDetails?.formattedVolumeWithUnits(system: oaOrder.tradeData.volume) ?? SymbolData.formattedVolumeDefault(system: oaOrder.tradeData.volume),
            style: popup_constants.textStyleBodyBold,
          ),
        ]),
        if (pnl != null)
          Row(children: <Widget>[
            Text(l10n.realizedPnl, style: popup_constants.textStyleBody),
            const Spacer(),
            Text(
              trader?.formattedMoneyWithCurrency(money: pnl) ?? pnl.toComaSeparated(decimals: oaPosition.moneyDigits),
              style: popup_constants.textStyleBodyBold.copyWith(color: pnl < 0 ? THEME.red : THEME.green),
            ),
          ]),
        Row(children: <Widget>[
          Text(l10n.price, style: popup_constants.textStyleBody),
          const Spacer(),
          Text(
            symbolDetails?.formattedRate(humanic: oaPosition.price) ?? SymbolData.formattedRateDefault(humanic: oaPosition.price),
            style: popup_constants.textStyleBodyBold,
          ),
        ]),
        Row(children: <Widget>[
          Text(l10n.takeProfit, style: popup_constants.textStyleBody),
          const Spacer(),
          Text(
            oaPosition.takeProfit == null
                ? l10n.no
                : symbolDetails?.formattedRate(humanic: oaPosition.takeProfit) ?? SymbolData.formattedRateDefault(humanic: oaPosition.takeProfit),
            style: popup_constants.textStyleBodyBold,
          ),
        ]),
        Row(children: <Widget>[
          Text(oaPosition.trailingStopLoss == true && oaPosition.stopLoss != null ? l10n.trailingStop : l10n.stopLoss, style: popup_constants.textStyleBody),
          const Spacer(),
          Text(sl, style: popup_constants.textStyleBodyBold),
        ]),
        Row(children: <Widget>[
          Text(l10n.created, style: popup_constants.textStyleBody),
          const Spacer(),
          Text(
            DateTime.fromMillisecondsSinceEpoch(oaPosition.tradeData.openTimestamp ?? 0).formatted(),
            style: popup_constants.textStyleBodyBold,
          ),
        ]),
        if (isPartial)
          Row(children: <Widget>[
            Text(l10n.created, style: popup_constants.textStyleBody),
            const Spacer(),
            Text(
              oaOrder.expirationTimestamp == null ? l10n.cancelled : DateTime.fromMillisecondsSinceEpoch(oaOrder.expirationTimestamp ?? 0).formatted(),
              style: popup_constants.textStyleBodyBold,
            ),
          ]),
      ],
    );
  }

  Future<PopupResult> showSymbolDisabledByTradingMode(AppLocalizations l10n) {
    return showPopup(
      title: l10n.limitedTradingAccess,
      message: l10n.tradingDisableForSymbolWithDescription,
    );
  }

  Future<PopupResult> showSymbolDisabledForShortTrading(AppLocalizations l10n) {
    return showPopup(
      title: l10n.limitedAccessPopupTitle,
      message: l10n.symbolDisabledForShortTrading,
    );
  }

  Future<PopupResult> askToClosePosition(AppLocalizations l10n, int positionId) {
    final Popup popup = Popup(
      completer: Completer<PopupResult>(),
      payload: Map<String, dynamic>.identity(),
      title: l10n.closingPosition,
      message: l10n.reallyWantClosePosition(positionId),
      buttons: <Widget>[
        ButtonSecondary(
          label: l10n.no,
          height: popup_constants.singleButtonSize.height,
          flex: 1,
          onTap: () => currentPopup?.closeWithResult(false), //  close(result: false),
        ),
        const SizedBox(width: 16),
        ButtonPrimary(
          label: l10n.yes,
          height: popup_constants.singleButtonSize.height,
          flex: 1,
          onTap: () => currentPopup?.closeWithResult(true),
        ),
      ],
    );

    _addToQueue(popup);
    return popup.completer.future;
  }

  Future<PopupResult> askToCancelOrder(AppLocalizations l10n, int orderId) {
    final Popup popup = Popup(
      completer: Completer<PopupResult>(),
      payload: Map<String, dynamic>.identity(),
      title: l10n.closingPendingOrder,
      message: l10n.reallyWantCancelOrder(orderId),
      buttons: <Widget>[
        ButtonSecondary(
          label: l10n.no,
          height: popup_constants.singleButtonSize.height,
          flex: 1,
          onTap: () => currentPopup?.closeWithResult(false),
        ),
        const SizedBox(width: 16),
        ButtonPrimary(
          label: l10n.yes,
          height: popup_constants.singleButtonSize.height,
          flex: 1,
          onTap: () => currentPopup?.closeWithResult(true),
        ),
      ],
    );

    _addToQueue(popup);
    return popup.completer.future;
  }

  Future<PopupResult> askToCancelOrderBeforeNewOne(AppLocalizations l10n, int orderId) {
    final Popup popup = Popup(
      completer: Completer<PopupResult>(),
      payload: Map<String, dynamic>.identity(),
      title: l10n.attention,
      message: l10n.orderWillBeCanceledBeforeNewOne(orderId),
      checkbox: l10n.dontShowAgain,
      buttons: <Widget>[
        ButtonSecondary(
          label: l10n.cancel,
          height: popup_constants.singleButtonSize.height,
          flex: 1,
          onTap: () => currentPopup?.closeWithResult(false),
        ),
        const SizedBox(width: 16),
        ButtonPrimary(
          label: l10n.yes,
          height: popup_constants.singleButtonSize.height,
          flex: 1,
          onTap: () => currentPopup?.closeWithResult(true),
        ),
      ],
    );

    _addToQueue(popup);
    return popup.completer.future;
  }

  Widget _simultaneousTradingAccountLine(AppLocalizations l10n, int accountId) {
    final TraderData? trader = GetIt.I<UserState>().trader(accountId);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(children: <Widget>[
        Container(
          alignment: Alignment.center,
          constraints: BoxConstraints.tight(const Size(55, 26)),
          decoration: BoxDecoration(
            color: trader?.demo != true ? THEME.red : THEME.green,
            borderRadius: BorderRadius.circular(2),
          ),
          child: Text(
            trader == null ? '----' : (trader.demo != true ? l10n.live : l10n.demo),
            style: popup_constants.textStyleBody.copyWith(color: Colors.white, height: 1.1),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '${trader?.login.toString() ?? '----'} · ${trader?.name ?? "----"}',
            style: popup_constants.textStyleBodyBold,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ]),
    );
  }

  Future<PopupResult> showSimultaneousExecutionFaildPopup(AppLocalizations l10n, String broker, String symbol) {
    final Popup popup = Popup(
      completer: Completer<PopupResult>(),
      payload: Map<String, dynamic>.identity(),
      title: l10n.executionFailedForBroker(broker),
      message: l10n.tradingConditionsPlaformNotAllowExecuteOrder(symbol, broker),
    );

    _addToQueue(popup);
    return popup.completer.future;
  }

  Future<PopupResult> askToOpenSimultaneousPosition(AppLocalizations l10n, bool isPosition, bool isBuy, String symbol) {
    if (GetIt.I<UserState>().dontShowSimultaneousTradingPopupForNew) return Future<PopupResult>.value(PopupResult(true, <String, dynamic>{'all': true}));

    final Popup popup = Popup(
      completer: Completer<PopupResult>(),
      payload: Map<String, dynamic>.identity(),
      title: l10n.simultaneousTrading,
      content: <Widget>[
        Text(
          l10n.buySellSymbolSimultaneousActivity(isBuy ? 'buy' : 'sell', symbol, isPosition ? 'position' : 'order'),
          style: popup_constants.textStyleBody,
        ),
        const SizedBox(height: 11),
        Container(
          constraints: const BoxConstraints(maxHeight: 200),
          child: SingleChildScrollView(
            child: Column(children: <Widget>[
              for (final int accId in GetIt.I<SimultaneousTrdaingState>().pariedAccounts) _simultaneousTradingAccountLine(l10n, accId),
            ]),
          ),
        ),
      ],
      checkbox: '${l10n.dontShowAgain} (${l10n.forYesOnly})',
      buttonsAxis: Axis.vertical,
      buttons: <Widget>[
        ButtonPrimary(
          label: l10n.yes,
          height: popup_constants.singleButtonSize.height,
          onTap: () => currentPopup?.closeWithResult(true, <String, dynamic>{'all': true}),
        ),
        const SizedBox(height: 16),
        ButtonThird(
          label: l10n.onlyForThisAccount,
          height: popup_constants.singleButtonSize.height,
          onTap: () => currentPopup?.closeWithResult(true, <String, dynamic>{'all': false}),
        ),
        const SizedBox(height: 16),
        ButtonSecondary(
          label: l10n.cancel,
          height: popup_constants.singleButtonSize.height,
          onTap: () => currentPopup?.closeWithResult(false),
        ),
      ],
    );

    popup.completer.future.then((PopupResult result) {
      if (result.agree && result.payload[Popup.PAYLOAD_CHECKBOX_KEY] == true && result.payload['all'] == true) {
        GetIt.I<UserState>().setDontShowSimultaneousTradingPopupForNew();
      }

      return result;
    });

    _addToQueue(popup);
    return popup.completer.future;
  }

  Future<PopupResult> showSimultaneousSymbolPairNotFound(AppLocalizations l10n, String name, Iterable<int> traders) {
    return showPopup(
      title: l10n.incompleteMatching,
      content: <Widget>[
        Text(l10n.symbolNotFoundForAccounts(name), style: popup_constants.textStyleBody),
        Container(
          constraints: const BoxConstraints(maxHeight: 200),
          child: SingleChildScrollView(
            child: Column(children: <Widget>[
              for (final int traderId in traders) _simultaneousTradingAccountLine(l10n, traderId),
            ]),
          ),
        ),
      ],
    );
  }

  Future<PopupResult> askToApplySimultaneousChanges(AppLocalizations l10n, bool isPosition, Iterable<int> traders) {
    if (GetIt.I<UserState>().dontShowSimultaneousTradingPopupForEdit) return Future<PopupResult>.value(PopupResult(true, <String, dynamic>{'all': true}));

    final Popup popup = Popup(
      completer: Completer<PopupResult>(),
      payload: Map<String, dynamic>.identity(),
      title: l10n.simultaneousTrading,
      content: <Widget>[
        Text(l10n.simultaneousApplyChanges(isPosition ? 'position' : 'order'), style: popup_constants.textStyleBody),
        const SizedBox(height: 11),
        Container(
          constraints: const BoxConstraints(maxHeight: 200),
          child: SingleChildScrollView(
            child: Column(children: <Widget>[
              for (final int id in traders) _simultaneousTradingAccountLine(l10n, id),
            ]),
          ),
        ),
        const SizedBox(height: 11),
        Text(l10n.applyChangesOnOtherAccounts, style: popup_constants.textStyleBody),
      ],
      checkbox: '${l10n.dontShowAgain} (${l10n.forYesOnly})',
      buttonsAxis: Axis.vertical,
      buttons: <Widget>[
        ButtonPrimary(
          label: l10n.yes,
          height: popup_constants.singleButtonSize.height,
          onTap: () => currentPopup?.closeWithResult(true, <String, dynamic>{'all': true}),
        ),
        const SizedBox(height: 16),
        ButtonThird(
          label: l10n.onlyForThisAccount,
          height: popup_constants.singleButtonSize.height,
          onTap: () => currentPopup?.closeWithResult(true, <String, dynamic>{'all': false}),
        ),
        const SizedBox(height: 16),
        ButtonSecondary(
          label: l10n.cancel,
          height: popup_constants.singleButtonSize.height,
          onTap: () => currentPopup?.closeWithResult(false),
        ),
      ],
    );

    popup.completer.future.then((PopupResult result) {
      if (result.agree && result.payload['all'] == true && result.payload[Popup.PAYLOAD_CHECKBOX_KEY] == true) {
        GetIt.I<UserState>().setDontShowSimultaneousTradingPopupForEdit();
      }

      return result;
    });

    _addToQueue(popup);
    return popup.completer.future;
  }

  Future<PopupResult> askToDisableSimulataneousTrading(AppLocalizations l10n) {
    final Popup popup = Popup(
      completer: Completer<PopupResult>(),
      payload: Map<String, dynamic>.identity(),
      title: l10n.warning,
      message: l10n.simultaneousDisablingAllLinksWillBeDeleted,
      buttons: <Widget>[
        ButtonSecondary(
          label: l10n.no,
          flex: 1,
          height: popup_constants.singleButtonSize.height,
          onTap: () => currentPopup?.closeWithResult(false),
        ),
        const SizedBox(width: 8),
        ButtonPrimary(label: l10n.yes, flex: 1, height: popup_constants.singleButtonSize.height, onTap: () => currentPopup?.closeWithResult(true)),
      ],
    );

    _addToQueue(popup);
    return popup.completer.future;
  }

  Future<PopupResult> askToAgreeWithTerms(AppLocalizations l10n) {
    final List<String> split = l10n.readAndAgreeTermsFirst.split('#link');

    return showPopup(
      title: l10n.toContinue,
      content: <Widget>[
        RichText(
          text: TextSpan(children: <TextSpan>[
            TextSpan(text: split[0]),
            TextSpan(
              text: l10n.readAndAgreeLinkName,
              style: const TextStyle(decoration: TextDecoration.underline, fontWeight: FontWeight.bold),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  currentPopup?.closeWithResult(false, <String, dynamic>{'showTerms': true});
                },
            ),
            TextSpan(text: split[1]),
          ]),
        ),
        const SizedBox(height: 12),
      ],
      buttonsAxies: Axis.horizontal,
      buttons: <Widget>[
        Expanded(
          child: ButtonSecondary(
            label: l10n.reject,
            height: popup_constants.singleButtonSize.height,
            onTap: () => currentPopup?.closeWithResult(false),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ButtonPrimary(
            label: l10n.agree,
            height: popup_constants.singleButtonSize.height,
            onTap: () => currentPopup?.closeWithResult(true),
          ),
        ),
      ],
    );
  }
}
