import 'dart:async';

import 'package:ctrader_example_app/extensions.dart';
import 'package:ctrader_example_app/l10n/localizations.dart';
import 'package:ctrader_example_app/main.dart';
import 'package:ctrader_example_app/models/position_data.dart';
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

class ActivityPositions extends StatefulWidget {
  const ActivityPositions({super.key});

  @override
  State<ActivityPositions> createState() => _ActivityPositionsState();
}

class _ActivityPositionsState extends State<ActivityPositions> {
  final Set<int> _expandedPositions = <int>{};

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    final TraderData trader = GetIt.I<UserState>().selectedTrader;
    final Set<int> symbolsToLoad = <int>{};

    for (final PositionData position in trader.positionsManager.activities) {
      if (position.symbol?.details == null) symbolsToLoad.add(position.symbolId);
    }

    if (symbolsToLoad.isNotEmpty) trader.remoteApi.sendSymbolById(trader.id, symbolsToLoad.toList());

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final TraderData trader = context.watch<UserState>().selectedTrader;
    final List<PositionData> positions = trader.positionsManager.activities.toList();

    if (positions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Text(l10n.noActivePositions, style: THEME.texts.headingBold, textAlign: TextAlign.center),
      );
    } else {
      positions.sort((PositionData a, PositionData b) => b.opened.compareTo(a.opened));

      return ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          final PositionData position = positions.elementAt(index);
          final SymbolData? symbol = trader.tree.symbol(position.symbolId);

          return _positionItem(l10n, position, symbol);
        },
        itemCount: positions.length,
      );
    }
  }

  Widget _positionItem(AppLocalizations l10n, PositionData position, SymbolData? symbol) {
    final bool isExpanded = _expandedPositions.contains(position.id);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: THEME.dividerLight())),
        color: isExpanded ? THEME.tabSelectorBackground() : null,
      ),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 250),
        alignment: Alignment.topCenter,
        child: Column(children: <Widget>[
          GestureDetector(
            onTap: () => _togglePositionExpand(position.id),
            child: Row(children: <Widget>[
              const SizedBox(width: 16),
              Container(
                constraints: BoxConstraints.tight(const Size(32, 22)),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: THEME.tabSelectorBackground(),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Text(position.isBuy ? l10n.buy : l10n.sell, style: THEME.texts.bodySmall),
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(symbol?.name ?? '----', style: THEME.texts.bodyBold, overflow: TextOverflow.ellipsis)),
              const SizedBox(width: 8),
              Text(
                symbol?.trader.formattedMoneyWithCurrency(cents: position.netPnl) ?? (position.netPnl / 100).toComaSeparated(decimals: 2),
                style: THEME.texts.bodyBold.copyWith(color: position.netPnl < 0 ? THEME.red : THEME.green),
                textAlign: TextAlign.right,
              ),
              const SizedBox(width: 8),
              RotatedBox(
                quarterTurns: _expandedPositions.contains(position.id) ? 2 : 0,
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
          if (_expandedPositions.contains(position.id))
            for (final Widget w in _positionDetails(l10n, position)) w,
        ]),
      ),
    );
  }

  List<Widget> _positionDetails(AppLocalizations l10n, PositionData position) {
    String? trailingStop;
    if (position.trailingStopLoss) {
      final int? trailingStopDist = position.trailingStopDistance;
      if (trailingStopDist != null) {
        trailingStop = position.symbol?.details?.formattedPips(system: trailingStopDist) ?? SymbolData.formattedRateDefault(system: trailingStopDist);
      } else {
        trailingStop = position.formattedRate(system: position.stopLoss);
      }
    }

    return <Widget>[
      const SizedBox(height: 4),
      Container(height: 1, color: THEME.dividerLight()),
      const SizedBox(height: 4),
      Row(children: <Widget>[
        const SizedBox(width: 16),
        Text(l10n.positionId, style: THEME.texts.bodyMediumSecondary),
        const Spacer(),
        Text(position.id.toString(), style: THEME.texts.bodyMediumSecondary),
        const SizedBox(width: 16),
      ]),
      Row(children: <Widget>[
        const SizedBox(width: 16),
        Text(l10n.amount, style: THEME.texts.bodyMediumSecondary),
        const Spacer(),
        Text(position.formattedVolumeWithUnits, style: THEME.texts.bodyMediumSecondary),
        const SizedBox(width: 16),
      ]),
      Row(children: <Widget>[
        const SizedBox(width: 16),
        Text(l10n.openingPrice, style: THEME.texts.bodyMediumSecondary),
        const Spacer(),
        Text(position.formattedRate(system: position.rate), style: THEME.texts.bodyMediumSecondary),
        const SizedBox(width: 16),
      ]),
      Row(children: <Widget>[
        const SizedBox(width: 16),
        Text(l10n.takeProfit, style: THEME.texts.bodyMediumSecondary),
        const Spacer(),
        Text(
          position.takeProfit == null ? l10n.no : position.formattedRate(system: position.takeProfit),
          style: THEME.texts.bodyMediumSecondary,
        ),
        const SizedBox(width: 16),
      ]),
      if (!position.trailingStopLoss)
        Row(children: <Widget>[
          const SizedBox(width: 16),
          Text(
            position.garanteedStopLoss ? l10n.guaranteedStopLoss : l10n.stopLoss,
            style: THEME.texts.bodyMediumSecondary,
          ),
          const Spacer(),
          Text(
            position.stopLoss == null ? l10n.no : position.formattedRate(system: position.stopLoss),
            style: THEME.texts.bodyMediumSecondary,
          ),
          const SizedBox(width: 16),
        ]),
      if (position.trailingStopLoss)
        Row(children: <Widget>[
          const SizedBox(width: 16),
          Text(l10n.trailingStop, style: THEME.texts.bodyMediumSecondary),
          const Spacer(),
          Text(trailingStop ?? '----', style: THEME.texts.bodyMediumSecondary),
          const SizedBox(width: 16),
        ]),
      Row(children: <Widget>[
        const SizedBox(width: 16),
        Text(l10n.openTime, style: THEME.texts.bodyMediumSecondary),
        const Spacer(),
        Text(
          position.opened.formatted(),
          style: THEME.texts.bodyMediumSecondary,
        ),
        const SizedBox(width: 16),
      ]),
      const SizedBox(height: 8),
      Row(children: <Widget>[
        const SizedBox(width: 16),
        ButtonPrimary(
          label: l10n.edit,
          flex: 1,
          height: 32,
          onTap: () => _onTapEditPosition(position),
        ),
        const SizedBox(width: 16),
        ButtonSecondary(
          label: l10n.close,
          flex: 1,
          height: 32,
          onTap: () => _onTapClosePosition(l10n, position),
        ),
        const SizedBox(width: 16),
      ]),
      const SizedBox(height: 4),
    ];
  }

  void _togglePositionExpand(int positionId) {
    if (!_expandedPositions.remove(positionId)) _expandedPositions.add(positionId);
    setState(() {});
  }

  Future<void> _onTapClosePosition(AppLocalizations l10n, PositionData position) async {
    if (GetIt.I<UserState>().selectedTrader.accessRights.index >= ProtoOAAccessRights.noTrading.index) {
      final UserState userState = GetIt.I<UserState>();
      GetIt.I<PopupManager>().showTraderSelection(AppLocalizations.of(context)!, userState.selectedTrader, userState.traders.length > 1);
    } else if (position.symbol?.details?.data.tradingMode == ProtoOATradingMode.disabledWithPendingsExecution ||
        position.symbol?.details?.data.tradingMode == ProtoOATradingMode.disabledWithoutPendingsExecution) {
      GetIt.I<PopupManager>().showSymbolDisabledByTradingMode(AppLocalizations.of(context)!);
    } else {
      GetIt.I<AppState>().setUIBlocked(true);
      await position.closePosition(context);
      GetIt.I<AppState>().setUIBlocked(false);
    }
  }

  void _onTapEditPosition(PositionData position) {
    if (GetIt.I<UserState>().selectedTrader.accessRights.index >= ProtoOAAccessRights.noTrading.index) {
      final UserState userState = GetIt.I<UserState>();
      GetIt.I<PopupManager>().showTraderSelection(AppLocalizations.of(context)!, userState.selectedTrader, userState.traders.length > 1);
    } else if (position.symbol?.details?.data.tradingMode == ProtoOATradingMode.disabledWithPendingsExecution ||
        position.symbol?.details?.data.tradingMode == ProtoOATradingMode.disabledWithoutPendingsExecution) {
      GetIt.I<PopupManager>().showSymbolDisabledByTradingMode(AppLocalizations.of(context)!);
    } else {
      Navigator.pushNamed(context, EditOrderPositionScreen.ROUTE_NAME, arguments: <String, dynamic>{'positionId': position.id});
    }
  }
}
