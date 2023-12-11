import 'dart:async';
import 'dart:math';

import 'package:ctrader_example_app/extensions.dart';
import 'package:ctrader_example_app/l10n/localizations.dart';
import 'package:ctrader_example_app/main.dart';
import 'package:ctrader_example_app/models/symbol_data.dart';
import 'package:ctrader_example_app/models/trader_data.dart';
import 'package:ctrader_example_app/popups/popup_manager.dart';
import 'package:ctrader_example_app/remote/proto.dart';
import 'package:ctrader_example_app/remote/remote_api.dart';
import 'package:ctrader_example_app/states/app_state.dart';
import 'package:ctrader_example_app/states/user_state.dart';
import 'package:ctrader_example_app/widgets/button_primary.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

class ActivityClosedPositions extends StatefulWidget {
  const ActivityClosedPositions({super.key});

  @override
  State<ActivityClosedPositions> createState() => _ActivityClosedPositionsState();
}

class _ActivityClosedPositionsState extends State<ActivityClosedPositions> {
  int _timestampOfLastDeal = -1;
  final List<ProtoOADeal> _deals = <ProtoOADeal>[];
  final Map<int, List<ProtoOADealOffset>> _dealOffsets = <int, List<ProtoOADealOffset>>{};
  final Set<int> _expandedDeals = <int>{};
  bool _hasMoreDeals = true;

  @override
  void initState() {
    super.initState();

    _timestampOfLastDeal = DateTime.now().millisecondsSinceEpoch;
    Timer.run(() => _loadMoreDeals());
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final TraderData trader = context.watch<UserState>().selectedTrader;

    return ListView.builder(
      itemCount: _deals.length + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index == _deals.length) return _loadMoreButton(l10n);

        final ProtoOADeal deal = _deals.elementAt(index);
        final SymbolData? symbol = trader.tree.symbol(deal.symbolId);
        final int pnl = deal.closePositionDetail!.grossProfit + deal.closePositionDetail!.swap + deal.closePositionDetail!.commission;
        final Color pnlColor = pnl < 0 ? THEME.red : THEME.green;
        final bool isExpanded = _expandedDeals.contains(deal.dealId);

        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            color: isExpanded ? THEME.tabSelectorBackground() : null,
            border: Border(bottom: BorderSide(color: THEME.dividerLight())),
          ),
          child: AnimatedSize(
            duration: const Duration(milliseconds: 250),
            alignment: Alignment.topCenter,
            child: Column(children: <Widget>[
              GestureDetector(
                onTap: () => _onToggleDealExpend(deal.dealId),
                child: Row(children: <Widget>[
                  const SizedBox(width: 16),
                  Container(
                    constraints: BoxConstraints.tight(const Size(32, 22)),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: THEME.tabSelectorBackground(),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Text(
                      deal.tradeSide == ProtoOATradeSide.buy ? l10n.sell : l10n.buy,
                      style: THEME.texts.bodySmall,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      symbol?.name ?? '----',
                      style: THEME.texts.bodyMedium,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    trader.formattedMoneyWithCurrency(cents: pnl),
                    style: THEME.texts.bodyMedium.copyWith(color: pnlColor),
                  ),
                  const SizedBox(width: 8),
                  RotatedBox(
                    quarterTurns: isExpanded ? 2 : 0,
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
              if (isExpanded)
                for (final Widget w in _dealDetails(l10n, deal, symbol)) w,
            ]),
          ),
        );
      },
    );
  }

  List<Widget> _dealDetails(AppLocalizations l10n, ProtoOADeal deal, SymbolData? symbol) {
    final List<ProtoOADealOffset>? offsets = _dealOffsets[deal.dealId];
    String openPrice = '----';
    String openTime = '----';

    if (offsets != null && offsets.isNotEmpty) {
      if (offsets.length == 1) {
        openPrice =
            symbol?.details?.formattedRate(humanic: offsets.first.executionPrice) ?? SymbolData.formattedRateDefault(humanic: offsets.first.executionPrice);
      } else {
        double rateAvarage = 0;
        double volumeSum = 0;
        for (final ProtoOADealOffset offset in offsets) {
          volumeSum += offset.volume;
        }
        for (final ProtoOADealOffset offset in offsets) {
          rateAvarage += offset.volume * (offset.executionPrice ?? 0) / volumeSum;
        }
        openPrice = symbol?.details?.formattedRate(humanic: rateAvarage) ?? SymbolData.formattedRateDefault(humanic: rateAvarage);
      }

      final int openTS = offsets.fold<int>(-1, (int previousValue, ProtoOADealOffset offset) {
        if (offset.executionTimestamp == null) return previousValue;
        if (previousValue < 0) return offset.executionTimestamp!;
        return min(previousValue, offset.executionTimestamp!);
      });
      openTime = DateTime.fromMillisecondsSinceEpoch(openTS).formatted();
    }

    return <Widget>[
      const SizedBox(height: 4),
      Container(height: 1, color: THEME.dividerLight()),
      const SizedBox(height: 4),
      Row(children: <Widget>[
        const SizedBox(width: 16),
        Text(l10n.transactionId, style: THEME.texts.bodyMediumSecondary),
        const Spacer(),
        Text(deal.dealId.toString(), style: THEME.texts.bodyMediumSecondary),
        const SizedBox(width: 16),
      ]),
      Row(children: <Widget>[
        const SizedBox(width: 16),
        Text(l10n.relatedId, style: THEME.texts.bodyMediumSecondary),
        const Spacer(),
        Text(deal.positionId.toString(), style: THEME.texts.bodyMediumSecondary),
        const SizedBox(width: 16),
      ]),
      Row(children: <Widget>[
        const SizedBox(width: 16),
        Text(l10n.amount, style: THEME.texts.bodyMediumSecondary),
        const Spacer(),
        Text(
          symbol?.details?.formattedVolumeWithUnits(system: deal.filledVolume) ?? SymbolData.formattedVolumeDefault(system: deal.filledVolume),
          style: THEME.texts.bodyMediumSecondary,
        ),
        const SizedBox(width: 16),
      ]),
      Row(children: <Widget>[
        const SizedBox(width: 16),
        Text(l10n.grossPnl, style: THEME.texts.bodyMediumSecondary),
        const Spacer(),
        Text(
          _formatedToMoneyWithCurrency(symbol?.trader, deal.closePositionDetail!.grossProfit),
          style: THEME.texts.bodyMediumSecondary.copyWith(color: deal.closePositionDetail!.grossProfit < 0 ? THEME.red : THEME.green),
        ),
        const SizedBox(width: 16),
      ]),
      Row(children: <Widget>[
        const SizedBox(width: 16),
        Text(l10n.commission, style: THEME.texts.bodyMediumSecondary),
        const Spacer(),
        Text(
          _formatedToMoneyWithCurrency(symbol?.trader, deal.closePositionDetail!.commission),
          style: THEME.texts.bodyMediumSecondary,
        ),
        const SizedBox(width: 16),
      ]),
      Row(children: <Widget>[
        const SizedBox(width: 16),
        Text(l10n.swapCommission, style: THEME.texts.bodyMediumSecondary),
        const Spacer(),
        Text(
          _formatedToMoneyWithCurrency(symbol?.trader, deal.closePositionDetail!.swap),
          style: THEME.texts.bodyMediumSecondary,
        ),
        const SizedBox(width: 16),
      ]),
      Row(children: <Widget>[
        const SizedBox(width: 16),
        Text(l10n.openPrice, style: THEME.texts.bodyMediumSecondary),
        const Spacer(),
        Text(openPrice, style: THEME.texts.bodyMediumSecondary),
        const SizedBox(width: 16),
      ]),
      Row(children: <Widget>[
        const SizedBox(width: 16),
        Text(l10n.openTime, style: THEME.texts.bodyMediumSecondary),
        const Spacer(),
        Text(openTime, style: THEME.texts.bodyMediumSecondary),
        const SizedBox(width: 16),
      ]),
      Row(children: <Widget>[
        const SizedBox(width: 16),
        Text(l10n.closePrice, style: THEME.texts.bodyMediumSecondary),
        const Spacer(),
        Text(
          symbol?.details?.formattedRate(humanic: deal.executionPrice) ?? SymbolData.formattedRateDefault(humanic: deal.executionPrice),
          style: THEME.texts.bodyMediumSecondary,
        ),
        const SizedBox(width: 16),
      ]),
      Row(children: <Widget>[
        const SizedBox(width: 16),
        Text(l10n.closeTime, style: THEME.texts.bodyMediumSecondary),
        const Spacer(),
        Text(
          DateTime.fromMillisecondsSinceEpoch(deal.executionTimestamp).formatted(),
          style: THEME.texts.bodyMediumSecondary,
        ),
        const SizedBox(width: 16),
      ]),
    ];
  }

  Widget _loadMoreButton(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ButtonPrimary(
        label: l10n.showMore,
        height: 32,
        disabled: !_hasMoreDeals,
        onTap: _loadMoreDeals,
      ),
    );
  }

  String _formatedToMoneyWithCurrency(TraderData? trader, int cents) {
    return trader?.formattedMoneyWithCurrency(cents: cents) ?? (cents / 100).toComaSeparated(decimals: 2);
  }

  Future<void> _loadMoreDeals([int loaded = 0, int reqNum = 1]) async {
    final TraderData trader = GetIt.I<UserState>().selectedTrader;
    final RemoteApi remoteAPI = trader.remoteApi;
    int lastTS = _timestampOfLastDeal;

    GetIt.I<AppState>().setUIBlocked(true);
    final int fromTs = max(_timestampOfLastDeal - 604800000, trader.registretionTs);
    if (fromTs >= _timestampOfLastDeal) {
      final AppLocalizations l10n = AppLocalizations.of(context)!;
      _hasMoreDeals = false;
      GetIt.I<PopupManager>().showPopup(title: l10n.tradingHistory, message: l10n.allHistoryLoaded);
      GetIt.I<AppState>().setUIBlocked(false);
      return;
    }

    final ProtoOADealListRes resp = await remoteAPI.sendDealList(trader.id, fromTs, _timestampOfLastDeal);

    final Set<int> _symbolsToLoad = <int>{};
    for (final ProtoOADeal d in resp.deal) {
      if (d.closePositionDetail != null) {
        _deals.add(d);
        loaded++;
        if (trader.tree.symbol(d.symbolId)?.details == null) _symbolsToLoad.add(d.symbolId);
      }
      lastTS = min(lastTS, d.executionTimestamp);
    }

    if (_symbolsToLoad.isNotEmpty) remoteAPI.sendSymbolById(trader.id, _symbolsToLoad.toList());

    if (resp.deal.length == 250) {
      _timestampOfLastDeal = lastTS;
    } else {
      _timestampOfLastDeal = fromTs;
    }

    if (loaded < 50 && reqNum < 5) {
      _loadMoreDeals(loaded, reqNum + 1);
    } else {
      GetIt.I<AppState>().setUIBlocked(false);

      final AppLocalizations l10n = AppLocalizations.of(context)!;
      if (loaded == 0) {
        GetIt.I<PopupManager>().showPopup(title: l10n.tradingHistory, message: l10n.noRecentHistory);
      }
    }

    setState(() {});
  }

  Future<void> _onToggleDealExpend(int dealId) async {
    final TraderData trader = GetIt.I<UserState>().selectedTrader;

    if (!_expandedDeals.remove(dealId)) {
      _expandedDeals.add(dealId);
      setState(() {});

      if (!_dealOffsets.containsKey(dealId)) {
        final ProtoOADealOffsetListRes resp = await trader.remoteApi.sendDealOffsetList(trader.id, dealId);
        _dealOffsets[dealId] = resp.offsetting;
      }
    }

    setState(() {});
  }
}
