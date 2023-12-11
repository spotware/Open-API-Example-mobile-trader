import 'dart:math';

import 'package:ctrader_example_app/extensions.dart';
import 'package:ctrader_example_app/l10n/localizations.dart';
import 'package:ctrader_example_app/main.dart';
import 'package:ctrader_example_app/models/asset_data.dart';
import 'package:ctrader_example_app/models/order_data.dart';
import 'package:ctrader_example_app/models/position_data.dart';
import 'package:ctrader_example_app/models/symbol_data.dart';
import 'package:ctrader_example_app/models/symbol_icons.dart';
import 'package:ctrader_example_app/models/trader_data.dart';
import 'package:ctrader_example_app/popups/popup_manager.dart';
import 'package:ctrader_example_app/remote/proto.dart';
import 'package:ctrader_example_app/remote/remote_api.dart';
import 'package:ctrader_example_app/screens/edit_order_position.dart';
import 'package:ctrader_example_app/states/app_state.dart';
import 'package:ctrader_example_app/states/user_state.dart';
import 'package:ctrader_example_app/widgets/buy_sell_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:timezone/timezone.dart' as tz;

const double _lastColumnWidth = 50.0;

class SymbolBuySell extends StatefulWidget {
  const SymbolBuySell({
    super.key,
    this.symbol,
    required this.onAction,
    this.highlightBuy,
    this.highlightSell,
    this.isSelected,
    this.showPositions,
    this.onSelect,
  });

  final SymbolData? symbol;
  final bool? highlightBuy;
  final bool? highlightSell;
  final bool? isSelected;
  final bool? showPositions;
  final void Function(int? symbolId, bool isBuy) onAction;
  final VoidCallback? onSelect;

  @override
  State<SymbolBuySell> createState() => _SymbolBuySellState();
}

class _SymbolBuySellState extends State<SymbolBuySell> {
  bool _showDetails = false;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final Color dcColor = (widget.symbol?.dailyChangePips ?? 0) < 0 ? THEME.red : THEME.green;
    final String iconPath = GetIt.I<SymbolIcons>().getIconNameBySymbolName(widget.symbol?.name);
    final TraderData trader = GetIt.I<UserState>().selectedTrader;

    return GestureDetector(
      onTap: widget.onSelect,
      child: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: THEME.dividerLight())),
              color: widget.isSelected == true ? THEME.marketsSymbolSelectedBackground() : null,
            ),
            child: Column(children: <Widget>[
              const SizedBox(height: 16),
              IntrinsicHeight(
                child: Row(children: <Widget>[
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(children: <Widget>[
                      IntrinsicHeight(
                        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                          Container(width: 48, height: 48, alignment: Alignment.center, child: SvgPicture.asset(iconPath, width: 48, height: 48)),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(widget.symbol?.name ?? 'n/a', style: THEME.texts.headingBold, overflow: TextOverflow.ellipsis),
                                Text(widget.symbol?.category.assetClass.name ?? 'n/a', style: THEME.texts.bodyRegularSecondary),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(crossAxisAlignment: CrossAxisAlignment.end, children: <Widget>[
                            Text(
                              widget.symbol?.formattedDailyChangePercents ?? ' n/a',
                              style: THEME.texts.headingBold.copyWith(color: dcColor),
                            ),
                            Text(
                              widget.symbol?.formattedDailyChangePips ?? '',
                              style: THEME.texts.bodyRegular.copyWith(color: dcColor),
                            ),
                          ]),
                          const SizedBox(width: 16),
                          GestureDetector(
                            onTap: _toggleFavorite,
                            child: Container(
                              width: 24,
                              height: 24,
                              alignment: Alignment.center,
                              color: Colors.transparent,
                              child: SvgPicture.asset(
                                widget.symbol?.isFavorite == true ? 'assets/svg/star_filled.svg' : 'assets/svg/star.svg',
                                height: 16,
                                width: 16,
                                colorFilter: THEME.onBackground().asFilter,
                              ),
                            ),
                          )
                        ]),
                      ),
                      const SizedBox(height: 12),
                      IntrinsicHeight(
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: BuySellButton(
                                false,
                                widget.symbol?.formattedSellRate ?? '----',
                                (bool isBuy) {
                                  if (widget.onSelect != null) widget.onSelect!();
                                  widget.onAction(widget.symbol?.id, isBuy);
                                },
                                highlight: widget.highlightSell,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: BuySellButton(
                                true,
                                widget.symbol?.formattedBuyRate ?? '----',
                                (bool isBuy) {
                                  if (widget.onSelect != null) widget.onSelect!();
                                  widget.onAction(widget.symbol?.id, isBuy);
                                },
                                highlight: widget.highlightBuy,
                              ),
                            ),
                            const SizedBox(width: 16),
                            GestureDetector(
                              onTap: _toggleShowDetails,
                              child: Container(
                                width: 24,
                                decoration: BoxDecoration(
                                  color: THEME.tabSelectorBackgroundSelected(),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                alignment: Alignment.center,
                                child: SvgPicture.asset(
                                  'assets/svg/circle_i.svg',
                                  width: 16,
                                  height: 16,
                                  colorFilter: THEME.onBackground().asFilter,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ]),
                  ),
                  const SizedBox(width: 16),
                ]),
              ),
              const SizedBox(height: 12),
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                alignment: Alignment.topCenter,
                child: _showDetails ? _symbolDetails(l10n) : Container(),
              ),
              if (widget.showPositions == true)
                AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  child: Column(children: <Widget>[
                    if (widget.symbol != null)
                      for (final PositionData pos in trader.positionsManager.activitiesBy(symbolId: widget.symbol!.id)) _positionListItem(l10n, pos),
                    if (widget.symbol != null)
                      for (final OrderData order in trader.ordersManager.activitiesBy(symbolId: widget.symbol!.id)) _orderListItem(l10n, order),
                  ]),
                ),
            ]),
          ),
          if (widget.symbol?.isMarketClosed() == true) _blockWithTraidingHoursOverlay(l10n),
        ],
      ),
    );
  }

  Widget _blockWithTraidingHoursOverlay(AppLocalizations l10n) {
    return Positioned.fill(
      child: Container(
        color: THEME.chartBlockBackground(),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
          SvgPicture.asset(
            'assets/svg/sleep_watch.svg',
            width: 40,
            height: 40,
            colorFilter: THEME.onBackground().asFilter,
          ),
          const SizedBox(height: 4),
          Text(l10n.tradingForSymbolClosed, style: THEME.texts.headingLargeBold),
        ]),
      ),
    );
  }

  Widget _symbolDetails(AppLocalizations l10n) {
    const double combinedColWidth = _lastColumnWidth * 2;
    final TextStyle style = THEME.texts.bodyMedium;
    final ProtoOASymbol? details = widget.symbol?.details?.data;

    return Container(
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      decoration: BoxDecoration(color: THEME.marketsSymbolDetailsBackground()),
      child: details == null
          ? Text(l10n.cantGetSymbolDetails, style: THEME.texts.headingSmall)
          : Column(children: <Widget>[
              Row(children: <Widget>[
                Text('${l10n.units}:', style: style),
                const Spacer(),
                Container(
                  width: combinedColWidth,
                  alignment: Alignment.center,
                  child: Text(widget.symbol?.units ?? 'n/a', style: style),
                ),
              ]),
              Row(children: <Widget>[
                Text('${l10n.pipPosition}:', style: style),
                const Spacer(),
                Text(details.pipPosition.toString(), style: style),
                const SizedBox(width: _lastColumnWidth),
              ]),
              if (details.enableShortSelling != true)
                Row(children: <Widget>[
                  Text('${l10n.shortSelling}:', style: style),
                  const Spacer(),
                  Container(
                    width: combinedColWidth,
                    alignment: Alignment.center,
                    child: Text(l10n.notAllowed, style: style),
                  ),
                ]),
              for (final Widget item in _symbolDetailsLeverage(l10n, widget.symbol?.details?.leverages)) item,
              for (final Widget item in _symbolDetailsSwap(l10n, widget.symbol?.details)) item,
              if (details.minVolume != null) _symbolMinimumOrder(l10n, details.minVolume, style),
              if (details.maxVolume != null) _symbolMaximumOrder(l10n, details.maxVolume, style),
              for (final Widget item in _symbolDetailsCommissions(l10n, widget.symbol?.details)) item,
              const SizedBox(height: 12),
              _symbolDetailsTradingHours(l10n, widget.symbol?.details),
            ]),
    );
  }

  List<Widget> _symbolDetailsLeverage(AppLocalizations l10n, List<ProtoOADynamicLeverageTier>? leverages) {
    final List<Widget> items = <Widget>[];
    final TextStyle style = THEME.texts.bodyMedium;
    final int traderLeverage = GetIt.I<UserState>().selectedTrader.levelrageInCents;

    if (leverages == null || leverages.isEmpty) {
      items.add(Row(children: <Widget>[
        Text('${l10n.leverage}:', style: style),
        const Spacer(),
        Text('n/a', style: style),
        const SizedBox(width: _lastColumnWidth),
      ]));
    } else if (leverages.length == 1) {
      final int leverage = min(traderLeverage, leverages.first.leverage) ~/ 100;
      items.add(Row(children: <Widget>[
        Text('${l10n.leverage}:', style: style),
        const Spacer(),
        Text('1:', style: style),
        SizedBox(width: _lastColumnWidth, child: Text('$leverage', style: style)),
      ]));
    } else {
      items.add(const SizedBox(height: 8));
      items.add(Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: THEME.background(),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(children: <Widget>[
          Text(l10n.leverageTiers, style: THEME.texts.bodyBold),
          Row(children: <Widget>[
            Text(l10n.volumeUsd, style: style),
            const Spacer(),
            Container(width: _lastColumnWidth * 2, alignment: Alignment.center, child: Text(l10n.leverage, style: style)),
          ]),
          for (int i = 0; i < leverages.length; i++)
            Row(children: <Widget>[
              Text(
                (i < leverages.length - 1)
                    ? '${(i == 0 ? 0.0 : leverages[i - 1].volume / 100).toComaSeparated(decimals: 0)} - ${(leverages[i].volume / 100).toComaSeparated(decimals: 0)}'
                    : '${(leverages[i - 1].volume / 100).toComaSeparated(decimals: 0)} < ',
                style: style,
              ),
              const Spacer(),
              Text('1:', style: style),
              SizedBox(width: _lastColumnWidth, child: Text('${min(leverages[i].leverage, traderLeverage) ~/ 100}', style: style)),
            ])
        ]),
      ));
      items.add(const SizedBox(height: 8));
    }

    return items;
  }

  List<Widget> _symbolDetailsSwap(AppLocalizations l10n, SymbolDetailsData? details) {
    final List<Widget> items = <Widget>[];
    final TextStyle style = THEME.texts.bodyMedium;

    if (details != null) {
      if (details.symbol.trader.swapFree) {
        if (details.data.rolloverCommission != null && details.data.rolloverCommission! > 0) {
          if (details.data.rolloverCommission3Days != null) {
            items.add(Row(children: <Widget>[
              Text('${l10n.rolloverCommission3Days}:', style: style),
              const Spacer(),
              SizedBox(
                width: _lastColumnWidth * 2,
                child: Text(l10n.dayOfWeek(details.data.rolloverCommission3Days!.name)),
              ),
            ]));
          }

          items.add(Row(children: <Widget>[
            Text('${l10n.rolloverCommission}:', style: style),
            Expanded(
              child: FittedBox(
                child: Text(
                  '  ${((details.data.rolloverCommission ?? 0) / 100).toComaSeparated(decimals: 2)} ${l10n.commissionUsdPerMillionUsd}',
                  style: style,
                  textAlign: TextAlign.right,
                ),
              ),
            ),
          ]));
        }
      } else {
        if (details.data.swapRollover3Days != null && details.data.swapRollover3Days != ProtoOADayOfWeek.none) {
          items.add(Row(children: <Widget>[
            Text(l10n.swap3Days, style: style),
            const Spacer(),
            SizedBox(
              width: _lastColumnWidth * 2,
              child: Text(l10n.dayOfWeek(details.data.swapRollover3Days!.name), textAlign: TextAlign.center),
            ),
          ]));
        }

        if (details.data.swapLong != null) {
          final double value = (details.data.lotSize ?? 0) / 100;
          items.add(Row(children: <Widget>[
            Text(l10n.swapPerLot(value.toComaSeparated(), details.data.measurementUnits ?? '', 'long'), style: style),
            const Spacer(),
            Text(details.data.swapLong!.toComaSeparated(), style: style),
            ConstrainedBox(
                constraints: const BoxConstraints(minWidth: _lastColumnWidth),
                child: Text(
                  details.data.swapCalculationType == ProtoOASwapCalculationType.percentage ? '%' : ' ${l10n.pips}',
                  style: style,
                )),
          ]));
        }

        if (details.data.swapShort != null) {
          final double value = (details.data.lotSize ?? 0) / 100;
          items.add(Row(children: <Widget>[
            Text(l10n.swapPerLot(value.toComaSeparated(), details.data.measurementUnits ?? '', 'short'), style: style),
            const Spacer(),
            Text(details.data.swapShort!.toComaSeparated(), style: style),
            ConstrainedBox(
                constraints: const BoxConstraints(minWidth: _lastColumnWidth),
                child: Text(
                  details.data.swapCalculationType == ProtoOASwapCalculationType.percentage ? '%' : ' ${l10n.pips}',
                  style: style,
                )),
          ]));
        }
      }
    }

    return items;
  }

  Widget _symbolMinimumOrder(AppLocalizations l10n, int volume, TextStyle style) {
    return Row(children: <Widget>[
      Text('${l10n.minOrder}:', style: style),
      const Spacer(),
      Text(
          (volume / 100).toComaSeparated(
              decimals: volume % 100 == 0
                  ? 0
                  : volume % 10 == 0
                      ? 1
                      : 2),
          style: style),
      ConstrainedBox(
        constraints: const BoxConstraints(minWidth: _lastColumnWidth),
        child: Text(' ${widget.symbol?.units ?? ''}', style: style, softWrap: false),
      ),
    ]);
  }

  Widget _symbolMaximumOrder(AppLocalizations l10n, int volume, TextStyle style) {
    return Row(children: <Widget>[
      Text('${l10n.maxOrder}:', style: style),
      const Spacer(),
      Text((volume / 100).toComaSeparated(decimals: volume % 100 == 0 ? 0 : 2), style: style),
      ConstrainedBox(
        constraints: const BoxConstraints(minWidth: _lastColumnWidth),
        child: Text(' ${widget.symbol?.units ?? ''}', style: style, softWrap: false),
      ),
    ]);
  }

  List<Widget> _symbolDetailsCommissions(AppLocalizations l10n, SymbolDetailsData? details) {
    final List<Widget> items = <Widget>[];
    final TextStyle style = THEME.texts.bodyMedium;

    final int? preciseMinCommission = details?.data.preciseMinCommission;
    if (preciseMinCommission != null && preciseMinCommission > 0) {
      final String currency = details?.data.minCommissionType == ProtoOAMinCommissionType.currency
          ? details?.data.minCommissionAsset?.toUpperCase() ?? ''
          : widget.symbol?.tree.asset(widget.symbol?.quoteAssetId)?.name ?? '';

      items.add(Row(children: <Widget>[
        Text('${l10n.minCommission}:', style: style),
        const Spacer(),
        Text((preciseMinCommission / 100000000).toComaSeparated(decimals: 2), style: style),
        SizedBox(
          width: _lastColumnWidth,
          child: Text(' $currency', style: style),
        ),
      ]));
    }

    final int? commissionRate = details?.data.preciseTradingCommissionRate;
    if (commissionRate != null && commissionRate > 0) {
      final StringBuffer value = StringBuffer();
      if (details?.data.commissionType == ProtoOACommissionType.percentageOfValue) {
        value.write(l10n.commissionPercentageOfValue((commissionRate / 100000).toString()));
      } else {
        final double amount = commissionRate / 100000000;
        if (details?.data.commissionType == ProtoOACommissionType.usdPerMillionUsd) {
          value.write('${amount.toComaSeparated(decimals: 2)} ${l10n.commissionUsdPerMillionUsd}');
        } else if (details?.data.commissionType == ProtoOACommissionType.usdPerLot) {
          value.write(l10n.commissionUsdPerLot(
            amount.toComaSeparated(decimals: 2),
            ((details?.data.lotSize ?? 0) ~/ 100).toString(),
            details?.data.measurementUnits ?? '',
          ));
        } else {
          final AssetData? asset = details?.symbol.tree.asset(details.symbol.quoteAssetId);
          value.write(l10n.commissionQuoteCcyPerLot(
            amount.toComaSeparated(decimals: 2),
            asset?.name ?? '???',
            ((details?.data.lotSize ?? 0) ~/ 100).toString(),
            details?.data.measurementUnits ?? 'n/a',
          ));
        }
      }

      items.add(Row(children: <Widget>[
        Text('${l10n.commission}:', style: style),
        const Spacer(),
        Text(value.toString(), style: style),
      ]));
    }

    return items;
  }

  Widget _symbolDetailsTradingHours(AppLocalizations l10n, SymbolDetailsData? details) {
    final TextStyle style = THEME.texts.bodyMedium;
    final List<ProtoOAInterval> schedule = details?.data.schedule ?? <ProtoOAInterval>[];
    final List<Widget> items = <Widget>[];
    final tz.Location tzLocation = tz.getLocation(details?.data.scheduleTimeZone ?? 'UTC');

    items.add(Text('${l10n.tradingHours}:', style: THEME.texts.bodyBold));

    if (schedule.isEmpty) {
      items.add(Row(
        children: <Widget>[
          const SizedBox(width: 16),
          Text('${l10n.tradingSchedule}:', style: style),
          const Spacer(),
          Text('24/7', style: style),
          const SizedBox(width: 24),
        ],
      ));
    }

    final DateTime now = DateTime.now();
    final DateTime sunday = now.previousSundayMidnight();

    for (final ProtoOAInterval interval in schedule) {
      final tz.TZDateTime start = tz.TZDateTime(tzLocation, sunday.year, sunday.month, sunday.day, 0, 0, interval.startSecond).toLocal();
      final tz.TZDateTime end = tz.TZDateTime(tzLocation, sunday.year, sunday.month, sunday.day, 0, 0, interval.endSecond).toLocal();
      final bool isCurrent = now.isAfter(start) && now.isBefore(end);

      items.add(Container(
        color: isCurrent ? THEME.tradingHoursSelectedBackground() : null,
        child: Row(children: <Widget>[
          Container(
            width: 16,
            alignment: Alignment.centerLeft,
            child: isCurrent
                ? Transform.rotate(
                    angle: -1.571,
                    child: SvgPicture.asset(
                      'assets/svg/triangle_down.svg',
                      width: 16,
                      height: 8,
                      colorFilter: THEME.onBackground().asFilter,
                    ),
                  )
                : null,
          ),
          Expanded(
            child: Text(
              "${l10n.dayOfWeekByNum(start.weekday.toString())} ${start.hour.toString().padLeft(2, "0")}:${start.minute.toString().padLeft(2, "0")}",
              style: isCurrent ? style.copyWith(fontWeight: FontWeight.bold) : style,
            ),
          ),
          const SizedBox(width: 12),
          Container(width: 14, height: isCurrent ? 2 : 1, color: style.color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "${l10n.dayOfWeekByNum(end.weekday.toString())} ${end.hour.toString().padLeft(2, "0")}:${end.minute.toString().padLeft(2, "0")}",
              style: isCurrent ? style.copyWith(fontWeight: FontWeight.bold) : style,
            ),
          ),
          const SizedBox(width: 16),
        ]),
      ));
    }

    final List<ProtoOAHoliday> holidays = details?.holidays ?? <ProtoOAHoliday>[];

    if (holidays.isNotEmpty) {
      items.add(const SizedBox(height: 12));
      items.add(Container(height: 1, color: THEME.dividerStrong()));
      items.add(const SizedBox(height: 12));
      items.add(Text(l10n.holidays, style: THEME.texts.bodyBold));

      items.addAll(_symbolDetailsHoliday(l10n, holidays.elementAt(0), false));
      if (holidays.length > 1 && holidays[0].startDateTime().difference(DateTime.now()).inDays < 7)
        items.addAll(_symbolDetailsHoliday(l10n, holidays.elementAt(1), true));
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: THEME.background(),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(children: <Widget>[
        for (final Widget item in items) item,
      ]),
    );
  }

  List<Widget> _symbolDetailsHoliday(AppLocalizations l10n, ProtoOAHoliday holiday, bool isNext) {
    final List<Widget> items = <Widget>[];
    final DateTime starts = holiday.startDateTime();
    final DateTime ends = holiday.endDateTime();

    items.add(Row(children: <Widget>[
      const SizedBox(width: 16),
      Expanded(child: Text('${isNext ? l10n.nextHoliday : l10n.holiday}:', style: THEME.texts.bodyBold)),
      Expanded(child: Text(holiday.name, style: THEME.texts.bodyBold, overflow: TextOverflow.ellipsis)),
      const SizedBox(width: 16),
    ]));

    if (starts.day == ends.day) {
      items.add(Row(children: <Widget>[
        const SizedBox(width: 16),
        Expanded(child: Text(l10n.date, style: THEME.texts.bodyMedium)),
        Expanded(child: Text(starts.formatted('MMM d'), style: THEME.texts.bodyMedium)),
        const SizedBox(width: 16),
      ]));
      items.add(Row(children: <Widget>[
        const SizedBox(width: 16),
        Expanded(child: Text('${l10n.from}:', style: THEME.texts.bodyMedium)),
        Expanded(
          child: Row(
            children: <Widget>[
              Expanded(child: Text(starts.formatted('HH:mm'), style: THEME.texts.bodyMedium)),
              Expanded(child: Text('${l10n.to.toLowerCase()}:', style: THEME.texts.bodyMedium, textAlign: TextAlign.center)),
              Expanded(child: Text(ends.formatted('HH:mm'), style: THEME.texts.bodyMedium, textAlign: TextAlign.right)),
            ],
          ),
        ),
        const SizedBox(width: 16),
      ]));
    } else {
      items.add(Row(children: <Widget>[
        const SizedBox(width: 16),
        Expanded(child: Text('${l10n.dateFrom}:', style: THEME.texts.bodyMedium)),
        Expanded(
          child: Row(
            children: <Widget>[
              Expanded(child: Text(starts.formatted('MMM d'), style: THEME.texts.bodyMedium)),
              Expanded(child: Text(starts.formatted('HH:mm'), style: THEME.texts.bodyMedium)),
            ],
          ),
        ),
        const SizedBox(width: 16),
      ]));
      items.add(Row(children: <Widget>[
        const SizedBox(width: 16),
        Expanded(child: Text('${l10n.dateTo}:', style: THEME.texts.bodyMedium)),
        Expanded(
          child: Row(
            children: <Widget>[
              Expanded(child: Text(ends.formatted('MMM d'), style: THEME.texts.bodyMedium)),
              Expanded(child: Text(ends.formatted('HH:mm'), style: THEME.texts.bodyMedium)),
            ],
          ),
        ),
        const SizedBox(width: 16),
      ]));
    }

    return items;
  }

  Widget _positionListItem(AppLocalizations l10n, PositionData position) {
    final Color pnlColor = position.netPnl < 0 ? THEME.red : THEME.green;

    return IntrinsicHeight(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(border: Border(top: BorderSide(color: THEME.dividerLight()))),
        child: Flex(direction: Axis.horizontal, children: <Widget>[
          Container(
            height: 40,
            width: 27,
            alignment: Alignment.center,
            child: SvgPicture.asset(
              GetIt.I<SymbolIcons>().getIconNameBySymbolName(widget.symbol?.name),
              width: 27,
              height: 27,
            ),
          ),
          const SizedBox(width: 4),
          Text(position.isBuy ? l10n.buy : l10n.sell, style: THEME.texts.bodyBold),
          const SizedBox(width: 12),
          Expanded(
            child: FittedBox(
              alignment: Alignment.centerLeft,
              fit: BoxFit.scaleDown,
              child: Text(position.formattedVolumeWithUnits, style: THEME.texts.bodyMedium),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FittedBox(
              alignment: Alignment.centerRight,
              fit: BoxFit.scaleDown,
              child: Text(
                GetIt.I<UserState>().selectedTrader.formattedMoneyWithCurrency(cents: position.netPnl),
                style: THEME.texts.bodyMedium.copyWith(color: pnlColor),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _onTapEditPosition(position.id),
            child: Container(
              width: 24,
              height: double.infinity,
              alignment: Alignment.center,
              color: Colors.transparent,
              child: SvgPicture.asset(
                'assets/svg/edit_position.svg',
                width: 16,
                height: 16,
                colorFilter: THEME.marketsPositionOnBackground().asFilter,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _closePosition(l10n, position),
            child: Container(
              width: 24,
              alignment: Alignment.center,
              color: Colors.transparent,
              child: SvgPicture.asset(
                'assets/svg/close_position.svg',
                width: 16,
                height: 16,
                colorFilter: THEME.marketsPositionOnBackground().asFilter,
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _orderListItem(AppLocalizations l10n, OrderData order) {
    return IntrinsicHeight(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(border: Border(top: BorderSide(color: THEME.dividerLight()))),
        child: Flex(direction: Axis.horizontal, children: <Widget>[
          Container(
            height: 40,
            width: 27,
            alignment: Alignment.center,
            child: SvgPicture.asset(
              GetIt.I<SymbolIcons>().getIconNameBySymbolName(widget.symbol?.name),
              width: 27,
              height: 27,
            ),
          ),
          const SizedBox(width: 4),
          Text(order.isBuy ? l10n.buy : l10n.sell, style: THEME.texts.bodyBold),
          const SizedBox(width: 12),
          Expanded(
            child: FittedBox(
              alignment: Alignment.centerLeft,
              fit: BoxFit.scaleDown,
              child: Text(order.formattedVolumeWithUnits, style: THEME.texts.bodyMedium),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FittedBox(
              alignment: Alignment.centerRight,
              fit: BoxFit.scaleDown,
              child: Text('@${order.formattedRate(system: order.rate)}', style: THEME.texts.bodyMedium),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _onTapEditOrder(order.id),
            child: Container(
              width: 24,
              height: double.infinity,
              alignment: Alignment.center,
              color: Colors.transparent,
              child: SvgPicture.asset(
                'assets/svg/edit_position.svg',
                width: 16,
                height: 16,
                colorFilter: THEME.marketsPositionOnBackground().asFilter,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _cancelOrder(l10n, order.id),
            child: Container(
              width: 24,
              alignment: Alignment.center,
              color: Colors.transparent,
              child: SvgPicture.asset(
                'assets/svg/close_position.svg',
                width: 16,
                height: 16,
                colorFilter: THEME.marketsPositionOnBackground().asFilter,
              ),
            ),
          ),
        ]),
      ),
    );
  }

  void _toggleFavorite() {
    if (widget.symbol != null) GetIt.I<UserState>().toggleFavoriteSymbol(widget.symbol!.id);
    if (widget.onSelect != null) widget.onSelect!();
  }

  Future<void> _toggleShowDetails() async {
    if (widget.symbol == null) return;

    final RemoteApi remoteApi = widget.symbol!.trader.remoteApi;
    _showDetails = !_showDetails;
    if (_showDetails && widget.symbol!.details == null) {
      await remoteApi.sendSymbolById(widget.symbol!.trader.id, <int>[widget.symbol!.id]);
    }

    final int? leverageId = widget.symbol!.details?.data.leverageId;
    if (_showDetails && leverageId != null && !widget.symbol!.tree.hasLeverage(leverageId)) {
      remoteApi
          .sendLeverageById(widget.symbol!.trader.id, leverageId)
          .then((ProtoOAGetDynamicLeverageByIDRes resp) => widget.symbol!.tree.addLeverage(resp.leverage));
    }

    if (widget.onSelect != null) widget.onSelect!();

    setState(() {});
  }

  void _onTapEditPosition(int positionId) {
    if (GetIt.I<UserState>().selectedTrader.accessRights.index > ProtoOAAccessRights.closeOnly.index) {
      final UserState userState = GetIt.I<UserState>();
      GetIt.I<PopupManager>().showTraderSelection(AppLocalizations.of(context)!, userState.selectedTrader, userState.traders.length > 1);
    } else if (widget.symbol?.details?.data.tradingMode == ProtoOATradingMode.disabledWithPendingsExecution ||
        widget.symbol?.details?.data.tradingMode == ProtoOATradingMode.disabledWithoutPendingsExecution) {
      GetIt.I<PopupManager>().showSymbolDisabledByTradingMode(AppLocalizations.of(context)!);
    } else {
      if (widget.onSelect != null) widget.onSelect!();
      Navigator.pushNamed(context, EditOrderPositionScreen.ROUTE_NAME, arguments: <String, dynamic>{'positionId': positionId});
    }
  }

  Future<void> _closePosition(AppLocalizations l10n, PositionData position) async {
    if (GetIt.I<UserState>().selectedTrader.accessRights.index > ProtoOAAccessRights.closeOnly.index) {
      final UserState userState = GetIt.I<UserState>();
      GetIt.I<PopupManager>().showTraderSelection(AppLocalizations.of(context)!, userState.selectedTrader, userState.traders.length > 1);
    } else if (widget.symbol?.details?.data.tradingMode == ProtoOATradingMode.disabledWithPendingsExecution ||
        widget.symbol?.details?.data.tradingMode == ProtoOATradingMode.disabledWithoutPendingsExecution) {
      GetIt.I<PopupManager>().showSymbolDisabledByTradingMode(AppLocalizations.of(context)!);
    } else {
      if (widget.onSelect != null) widget.onSelect!();

      GetIt.I<AppState>().setUIBlocked(true);
      await position.closePosition(context);
      GetIt.I<AppState>().setUIBlocked(false);
    }
  }

  void _onTapEditOrder(int orderId) {
    if (GetIt.I<UserState>().selectedTrader.accessRights.index > ProtoOAAccessRights.closeOnly.index) {
      final UserState userState = GetIt.I<UserState>();
      GetIt.I<PopupManager>().showTraderSelection(AppLocalizations.of(context)!, userState.selectedTrader, userState.traders.length > 1);
    } else if (widget.symbol?.details?.data.tradingMode == ProtoOATradingMode.disabledWithPendingsExecution ||
        widget.symbol?.details?.data.tradingMode == ProtoOATradingMode.disabledWithoutPendingsExecution) {
      GetIt.I<PopupManager>().showSymbolDisabledByTradingMode(AppLocalizations.of(context)!);
    } else {
      if (widget.onSelect != null) widget.onSelect!();
      Navigator.pushNamed(context, EditOrderPositionScreen.ROUTE_NAME, arguments: <String, dynamic>{'orderId': orderId});
    }
  }

  Future<void> _cancelOrder(AppLocalizations l10n, int orderId) async {
    if (GetIt.I<UserState>().selectedTrader.accessRights.index > ProtoOAAccessRights.closeOnly.index) {
      final UserState userState = GetIt.I<UserState>();
      GetIt.I<PopupManager>().showTraderSelection(AppLocalizations.of(context)!, userState.selectedTrader, userState.traders.length > 1);
    } else if (widget.symbol?.details?.data.tradingMode == ProtoOATradingMode.disabledWithPendingsExecution ||
        widget.symbol?.details?.data.tradingMode == ProtoOATradingMode.disabledWithoutPendingsExecution) {
      GetIt.I<PopupManager>().showSymbolDisabledByTradingMode(AppLocalizations.of(context)!);
    } else {
      if (widget.onSelect != null) widget.onSelect!();

      GetIt.I<AppState>().setUIBlocked(true);
      await GetIt.I<UserState>().selectedTrader.ordersManager.activityBy(id: orderId)?.cancelOrder(context);
      GetIt.I<AppState>().setUIBlocked(false);
    }
  }
}
