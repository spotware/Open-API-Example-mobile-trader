import 'dart:async';

import 'package:ctrader_example_app/extensions.dart';
import 'package:ctrader_example_app/l10n/localizations.dart';
import 'package:ctrader_example_app/main.dart';
import 'package:ctrader_example_app/models/order_data.dart';
import 'package:ctrader_example_app/models/symbol_data.dart';
import 'package:ctrader_example_app/models/trader_data.dart';
import 'package:ctrader_example_app/popups/popup_manager.dart';
import 'package:ctrader_example_app/remote/proto.dart';
import 'package:ctrader_example_app/screens/edit_order_position.dart';
import 'package:ctrader_example_app/states/app_state.dart';
import 'package:ctrader_example_app/states/user_state.dart';
import 'package:ctrader_example_app/widgets/button_primary.dart';
import 'package:ctrader_example_app/widgets/button_secondary.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

class ActivityOrders extends StatefulWidget {
  const ActivityOrders({super.key});

  @override
  State<ActivityOrders> createState() => _ActivityOrdersState();
}

class _ActivityOrdersState extends State<ActivityOrders> {
  final Set<int> _expandedOrders = <int>{};

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    final TraderData trader = GetIt.I<UserState>().selectedTrader;
    final Set<int> symbolsToLoad = <int>{};

    for (final OrderData order in trader.ordersManager.activities) {
      if (order.symbol?.details == null) symbolsToLoad.add(order.symbolId);
    }

    if (symbolsToLoad.isNotEmpty) trader.remoteApi.sendSymbolById(trader.id, symbolsToLoad.toList());

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final TraderData trader = context.watch<UserState>().selectedTrader;
    final List<OrderData> orders = trader.ordersManager.activities.toList();

    if (orders.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Text(l10n.noActiveOrders, style: THEME.texts.headingBold, textAlign: TextAlign.center),
      );
    } else {
      orders.sort((OrderData a, OrderData b) => b.id.compareTo(a.id));

      return ListView.builder(
        itemCount: orders.length,
        itemBuilder: (BuildContext context, int index) {
          return _listItem(l10n, orders.elementAt(index));
        },
      );
    }
  }

  Widget _listItem(AppLocalizations l10n, OrderData order) {
    final SymbolData? symbol = order.symbol;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: THEME.dividerLight())),
        color: _expandedOrders.contains(order.id) ? THEME.tabSelectorBackground() : null,
      ),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 250),
        alignment: Alignment.topCenter,
        child: Column(children: <Widget>[
          GestureDetector(
            onTap: () => _onToggleOrderExpend(order.id),
            child: Row(children: <Widget>[
              const SizedBox(width: 16),
              Container(
                constraints: BoxConstraints.tight(const Size(32, 22)),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: THEME.tabSelectorBackground(),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Text(order.isBuy ? l10n.buy : l10n.sell, style: THEME.texts.bodySmall),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(symbol?.name ?? '----', style: THEME.texts.bodyBold, overflow: TextOverflow.ellipsis),
              ),
              const SizedBox(width: 8),
              Text(
                '@${order.formattedRate(system: order.rate)}',
                style: THEME.texts.bodyBold,
                textAlign: TextAlign.right,
              ),
              const SizedBox(width: 8),
              RotatedBox(
                quarterTurns: _expandedOrders.contains(order.id) ? 2 : 0,
                child: Container(
                  constraints: BoxConstraints.tight(const Size.square(24)),
                  color: Colors.transparent,
                  alignment: Alignment.center,
                  child: SvgPicture.asset(
                    'assets/svg/triangle_down.svg',
                    width: 16,
                    height: 8,
                    colorFilter: THEME.onBackground().asFilter,
                  ),
                ),
              ),
              const SizedBox(width: 16),
            ]),
          ),
          if (_expandedOrders.contains(order.id))
            for (final Widget w in _itemDetails(l10n, order)) w,
        ]),
      ),
    );
  }

  List<Widget> _itemDetails(AppLocalizations l10n, OrderData order) {
    String goodTill = l10n.cancelled;
    if (order.timeInForce == ProtoOATimeInForce.goodTillDate) {
      if (order.expireAt != null) {
        goodTill = order.expireAt!.formatted();
      } else {
        goodTill = 'n/a';
      }
    }

    String? trailingStop;
    if (order.trailingStopLoss) {
      final int? trailingStopDist = order.trailingStopDistance;
      if (trailingStopDist != null) {
        trailingStop = order.symbol?.details?.formattedPips(system: trailingStopDist) ?? SymbolData.formattedRateDefault(system: trailingStopDist);
      } else {
        trailingStop = order.formattedRate(system: order.stopLoss);
      }
    }

    return <Widget>[
      const SizedBox(height: 4),
      Container(height: 1, color: THEME.dividerLight()),
      const SizedBox(height: 4),
      Row(children: <Widget>[
        const SizedBox(width: 16),
        Text(l10n.orderId, style: THEME.texts.bodyMediumSecondary),
        const Spacer(),
        Text(order.id.toString(), style: THEME.texts.bodyMediumSecondary),
        const SizedBox(width: 16),
      ]),
      if (order.executedVolume > 0)
        Row(children: <Widget>[
          const SizedBox(width: 16),
          Text(l10n.filledAmount, style: THEME.texts.bodyMediumSecondary),
          const Spacer(),
          Text(
            order.symbol?.details?.formattedVolumeWithUnits(system: order.executedVolume) ?? SymbolData.formattedVolumeDefault(system: order.executedVolume),
            style: THEME.texts.bodyMediumSecondary,
          ),
          const SizedBox(width: 16),
        ]),
      Row(children: <Widget>[
        const SizedBox(width: 16),
        Text(l10n.amount, style: THEME.texts.bodyMediumSecondary),
        const Spacer(),
        Text(order.formattedVolumeWithUnits, style: THEME.texts.bodyMediumSecondary),
        const SizedBox(width: 16),
      ]),
      Row(children: <Widget>[
        const SizedBox(width: 16),
        Text(l10n.goodTill, style: THEME.texts.bodyMediumSecondary),
        const Spacer(),
        Text(goodTill, style: THEME.texts.bodyMediumSecondary),
        const SizedBox(width: 16),
      ]),
      Row(children: <Widget>[
        const SizedBox(width: 16),
        Text(l10n.takeProfit, style: THEME.texts.bodyMediumSecondary),
        const Spacer(),
        Text(
          order.takeProfit == null ? l10n.no : order.formattedRate(system: order.takeProfit),
          style: THEME.texts.bodyMediumSecondary,
        ),
        const SizedBox(width: 16),
      ]),
      if (!order.trailingStopLoss)
        Row(children: <Widget>[
          const SizedBox(width: 16),
          Text(
            order.garanteedStopLoss ? l10n.guaranteedStopLoss : l10n.stopLoss,
            style: THEME.texts.bodyMediumSecondary,
          ),
          const Spacer(),
          Text(
            order.stopLoss == null ? l10n.no : order.formattedRate(system: order.stopLoss),
            style: THEME.texts.bodyMediumSecondary,
          ),
          const SizedBox(width: 16),
        ]),
      if (order.trailingStopLoss)
        Row(children: <Widget>[
          const SizedBox(width: 16),
          Text(l10n.trailingStop, style: THEME.texts.bodyMediumSecondary),
          const Spacer(),
          Text(trailingStop ?? '----', style: THEME.texts.bodyMediumSecondary),
          const SizedBox(width: 16),
        ]),
      Row(children: <Widget>[
        const SizedBox(width: 16),
        Text(l10n.creationTime, style: THEME.texts.bodyMediumSecondary),
        const Spacer(),
        Text(order.opened.formatted(), style: THEME.texts.bodyMediumSecondary),
        const SizedBox(width: 16),
      ]),
      const SizedBox(height: 8),
      Row(children: <Widget>[
        const SizedBox(width: 16),
        ButtonPrimary(label: l10n.edit, flex: 1, height: 32, onTap: () => _onTapEditOrder(order)),
        const SizedBox(width: 16),
        ButtonSecondary(
          label: l10n.cancel,
          flex: 1,
          height: 32,
          onTap: () => _onTapCancelOrder(l10n, order),
        ),
        const SizedBox(width: 16),
      ]),
      const SizedBox(height: 4),
    ];
  }

  void _onToggleOrderExpend(int orderId) {
    if (!_expandedOrders.remove(orderId)) _expandedOrders.add(orderId);
    setState(() {});
  }

  void _onTapEditOrder(OrderData order) {
    if (GetIt.I<UserState>().selectedTrader.accessRights.index >= ProtoOAAccessRights.noTrading.index) {
      final UserState userState = GetIt.I<UserState>();
      GetIt.I<PopupManager>().showTraderSelection(AppLocalizations.of(context)!, userState.selectedTrader, userState.traders.length > 1);
    } else if (order.symbol?.details?.data.tradingMode == ProtoOATradingMode.disabledWithPendingsExecution ||
        order.symbol?.details?.data.tradingMode == ProtoOATradingMode.disabledWithoutPendingsExecution) {
      GetIt.I<PopupManager>().showSymbolDisabledByTradingMode(AppLocalizations.of(context)!);
    } else {
      Navigator.pushNamed(context, EditOrderPositionScreen.ROUTE_NAME, arguments: <String, dynamic>{'orderId': order.id});
    }
  }

  Future<void> _onTapCancelOrder(AppLocalizations l10n, OrderData order) async {
    if (GetIt.I<UserState>().selectedTrader.accessRights.index >= ProtoOAAccessRights.noTrading.index) {
      final UserState userState = GetIt.I<UserState>();
      GetIt.I<PopupManager>().showTraderSelection(AppLocalizations.of(context)!, userState.selectedTrader, userState.traders.length > 1);
    } else if (order.symbol?.details?.data.tradingMode == ProtoOATradingMode.disabledWithPendingsExecution ||
        order.symbol?.details?.data.tradingMode == ProtoOATradingMode.disabledWithoutPendingsExecution) {
      GetIt.I<PopupManager>().showSymbolDisabledByTradingMode(AppLocalizations.of(context)!);
    } else {
      GetIt.I<AppState>().setUIBlocked(true);
      await GetIt.I<UserState>().selectedTrader.ordersManager.activityBy(id: order.id)?.cancelOrder(context);
      GetIt.I<AppState>().setUIBlocked(false);
    }
  }
}
