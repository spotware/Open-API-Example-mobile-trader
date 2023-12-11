import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:ctrader_example_app/extensions.dart';
import 'package:ctrader_example_app/l10n/localization_helper.dart';
import 'package:ctrader_example_app/l10n/localizations.dart';
import 'package:ctrader_example_app/logger.dart';
import 'package:ctrader_example_app/main.dart';
import 'package:ctrader_example_app/models/activity_manager.dart';
import 'package:ctrader_example_app/models/order_data.dart';
import 'package:ctrader_example_app/models/position_data.dart';
import 'package:ctrader_example_app/models/symbol_data.dart';
import 'package:ctrader_example_app/models/trader_data.dart';
import 'package:ctrader_example_app/popups/popup_manager.dart';
import 'package:ctrader_example_app/remote/proto.dart';
import 'package:ctrader_example_app/remote/remote_api.dart';
import 'package:ctrader_example_app/remote/spot_sub_manager.dart';
import 'package:ctrader_example_app/states/app_state.dart';
import 'package:ctrader_example_app/states/user_state.dart';
import 'package:ctrader_example_app/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MiniChart extends StatefulWidget {
  const MiniChart({super.key, required this.symbol, this.showToolbar, this.showRotNotif, this.onTapCloseTip});

  final SymbolData symbol;
  final bool? showToolbar;
  final bool? showRotNotif;
  final VoidCallback? onTapCloseTip;

  @override
  State<MiniChart> createState() => _MiniChartState();
}

class _MiniChartState extends State<MiniChart> {
  late WebViewController _controller;
  bool _chartLoaded = false;
  bool _chartLoadingData = true;
  int _symbolId = -1;
  bool? _showToolbar;
  int? _rate;
  ProtoOATrendbarPeriod? _period;
  int? _currentTrendBarTs;

  @override
  void initState() {
    super.initState();

    final TraderData trader = GetIt.I<UserState>().selectedTrader;

    trader.remoteApi.subscribe<ProtoOASpotEvent>(_onHandleSpotEvent);
    trader.positionsManager.addListener(ActivityManagerEventType.added, _onPositionCreatedEvent);
    trader.positionsManager.addListener(ActivityManagerEventType.removed, _onPositionRemovedEvent);
    trader.positionsManager.addListener(ActivityManagerEventType.updated, _onPositionUpdated);
    trader.ordersManager.addListener(ActivityManagerEventType.added, _onOrderCreatedEvent);
    trader.ordersManager.addListener(ActivityManagerEventType.removed, _onOrderRemovedEvent);
    trader.ordersManager.addListener(ActivityManagerEventType.updated, _onOrderUpdatedEvent);

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {},
          onPageFinished: (String url) {
            _chartLoaded = true;
            final String bg = THEME.background().value.toRadixString(16).substring(2);
            final String fg = THEME.onBackground().value.toRadixString(16).substring(2);
            _symbolId = widget.symbol.id;
            _controller.runJavaScript("initChart('#$bg', '#$fg', '${widget.symbol.name}', ${widget.showToolbar});chart.setSymbol('${widget.symbol.name}');");
          },
          onWebResourceError: (WebResourceError error) {
            Logger.error('onWebResourceError: ${error.errorCode} - ${error.description}');
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('file://')) {
              return Future<NavigationDecision>.value(NavigationDecision.navigate);
            } else {
              openUrlInBrowser(request.url);
              return Future<NavigationDecision>.value(NavigationDecision.prevent);
            }
          },
        ),
      )
      ..addJavaScriptChannel('native', onMessageReceived: (JavaScriptMessage msg) {
        Logger.log(() => 'Chart requesting candles: ${msg.message}');
        final dynamic event = jsonDecode(msg.message);
        final String type = event['type'] as String;
        if (type == 'loadCandles') {
          final String jsCallback = event['data']['callback'] as String;
          final String timeframe = event['data']['timeframe'] as String;
          final int? timestampFrom = event['data']['timestampFrom'] as int?;
          final int count = event['data']['count'] as int;
          _loadCandlesToChart(jsCallback, timeframe, count, timestampFrom);
        } else if (type == 'closeDeal') {
          final int positionId = event['data']['id'] as int;
          _closePositionByChartEvent(positionId);
        } else if (type == 'setDealTakeProfit') {
          final int positionId = event['data']['id'] as int;
          final double? rate = event['data']['rate'] as double?;
          _updateDealSLTPByChartEvent(positionId, takeProfit: rate ?? -1);
        } else if (type == 'setDealStopLoss') {
          final int positionId = event['data']['id'] as int;
          final double? rate = event['data']['rate'] as double?;
          _updateDealSLTPByChartEvent(positionId, stopLoss: rate ?? -1);
        } else if (type == 'closeOrder') {
          final int orderId = event['data']['id'] as int;
          _closeOrderByChartEvent(orderId);
        } else if (type == 'setOrderTakeProfit') {
          final int orderId = event['data']['id'] as int;
          final double? rate = event['data']['rate'] as double?;
          _updateOrderSLTPByChartEvent(orderId, takeProfit: rate ?? -1);
        } else if (type == 'setOrderStopLoss') {
          final int id = event['data']['id'] as int;
          final double? rate = event['data']['rate'] as double?;
          _updateOrderSLTPByChartEvent(id, stopLoss: rate ?? -1);
        }
      })
      ..loadFlutterAsset('assets/trading4pro/mini-chart.html');
  }

  @override
  void dispose() {
    final UserState userState = GetIt.I<UserState>();
    if (userState.selectedTraderId > 0) {
      try {
        final TraderData trader = userState.selectedTrader;
        trader.remoteApi.unsubscribe<ProtoOASpotEvent>(_onHandleSpotEvent);

        if (_period != null) trader.subscriptionManagerApi.unsubscribeFromTrendBars(trader.id, _symbolId, _period!);

        trader.positionsManager.removeListener(ActivityManagerEventType.added, _onPositionCreatedEvent);
        trader.positionsManager.removeListener(ActivityManagerEventType.removed, _onPositionRemovedEvent);
        trader.positionsManager.removeListener(ActivityManagerEventType.updated, _onPositionUpdated);
      } catch (e) {
        Logger.error('Error occurred at disposing chart: $e');
      }
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    context.watch<UserState>();

    if (_chartLoaded && _symbolId != widget.symbol.id) _symbolChanged();

    if (widget.showToolbar != null && widget.showToolbar != _showToolbar) {
      _showToolbar = widget.showToolbar;
      _controller.runJavaScript("document.getElementsByTagName('body')[0].className='${_showToolbar == true ? "" : "portreit"}';");
    }

    return Stack(children: <Widget>[
      WebViewWidget(
        controller: _controller,
        gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer())},
      ),
      if (widget.showRotNotif == true) Positioned.fill(child: Container(color: THEME.chartBlockBackground())),
      if (widget.showRotNotif == true)
        Positioned(
          right: 8,
          top: 8,
          child: GestureDetector(
            onTap: widget.onTapCloseTip,
            child: Container(
              color: Colors.transparent,
              width: 24,
              height: 24,
              child: SvgPicture.asset(
                'assets/svg/x.svg',
                width: 18,
                height: 18,
                colorFilter: THEME.chartBlockOnBackground().asFilter,
              ),
            ),
          ),
        ),
      if (widget.showRotNotif == true)
        Positioned.fill(
            child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SvgPicture.asset(
                'assets/svg/rotate_device.svg',
                width: 48,
                height: 48,
                colorFilter: THEME.chartBlockOnBackground().asFilter,
              ),
              Text(l10n.chartRotateTip, style: THEME.texts.chartRotateTip, textAlign: TextAlign.center),
            ],
          ),
        ))
    ]);
  }

  Future<void> _loadCandlesToChart(String jsCallback, String timeframe, int count, [int? tsFrom]) async {
    final TraderData trader = GetIt.I<UserState>().selectedTrader;
    final RemoteApi remoteAPI = trader.remoteApi;
    final SpotSubscriptionManager spotSubscriptionManager = trader.subscriptionManagerApi;
    final ProtoOATrendbarPeriod period = ProtoOATrendbarPeriodExtention.byChartName(timeframe);

    count = min(count, 250);

    Logger.debug(() => 'MiniChart: chart requested to load candles: $timeframe, $count, $tsFrom');
    if (!mounted || !remoteAPI.isAutorized) {
      _controller.runJavaScript('$jsCallback([]);');
      return;
    }
    Logger.debug(() => 'MiniChart: is mounted and authorized');

    if (tsFrom == null) _currentTrendBarTs = null;

    if (_period != null && _period != period) {
      try {
        await spotSubscriptionManager.unsubscribeFromTrendBars(trader.id, _symbolId, _period!);
      } catch (e) {
        Logger.log(() => 'Error occurred at unsubscribing from trndbars for symbol($_symbolId) of ${_period!.name}(${_period!.index})');
      }
    }

    final int to = tsFrom != null ? tsFrom * 1000 : DateTime.now().millisecondsSinceEpoch;
    final int from = DateTime.fromMillisecondsSinceEpoch(to).subtract(Duration(seconds: period.seconds() * count)).millisecondsSinceEpoch;

    // need to wait until symbol subscribded for spots
    while (!spotSubscriptionManager.isSymbolSubscribedForSpots(widget.symbol.id)) {
      if (!mounted || !remoteAPI.isAutorized) return;
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }

    Logger.debug(() => 'MiniChart: symbol subscribed for spots');
    // only after symbol is subscribed for spots we can subscribe for trendbars
    if (_period == null || _period != period) {
      // subscribe only when period is changed or not initialized
      try {
        _period = period;
        await spotSubscriptionManager.subscribeForTrendBars(trader.id, widget.symbol.id, period);
      } catch (err) {
        _period = null;
        String msg = "Can't subscribe for live trendbars";
        if (err is ProtoOAErrorRes) {
          msg += '\n${err.errorCode}: ${err.description}';
        } else {
          msg += '$err';
        }
        Logger.error(msg);
        _controller.runJavaScript('$jsCallback([]);');
        return;
      }
    }

    final ProtoOAGetTrendbarsRes trendbarsRes;
    try {
      trendbarsRes = await remoteAPI.sendGetTrendbars(trader.id, widget.symbol.id, count, period, from, to);
    } catch (err) {
      Logger.error('Error occurred at loading candles for chart', err);
      String msg = "Can't load trendbars history";
      if (err is ProtoOAErrorRes) {
        msg += AppLocalizations.of(context)!.getServerErrorDescription(err.errorCode) ?? err.description ?? err.errorCode;
      } else {
        msg += '$err';
      }
      GetIt.I<PopupManager>().showError(AppLocalizations.of(context)!, msg);
      return;
    }

    final List<Map<String, dynamic>> candles = <Map<String, dynamic>>[];
    for (final ProtoOATrendbar bar in trendbarsRes.trendbar) {
      candles.add(<String, dynamic>{
        'symbol': widget.symbol.name,
        'timeframe': trendbarsRes.period.toChartName(),
        'timestamp': (bar.utcTimestampInMinutes ?? 0) * 60,
        'open': SymbolData.humanicRateFromSystem((bar.low ?? 0) + (bar.deltaOpen ?? 0)),
        'high': SymbolData.humanicRateFromSystem((bar.low ?? 0) + (bar.deltaHigh ?? 0)),
        'low': SymbolData.humanicRateFromSystem(bar.low ?? 0),
        'close': SymbolData.humanicRateFromSystem((bar.low ?? 0) + (bar.deltaClose ?? 0)),
        'volume': bar.volume,
      });
    }

    await _controller.runJavaScript('$jsCallback(${jsonEncode(candles)});');
    _chartLoadingData = false;

    _addPositionsToChart(trader);
    _addOrdersToChart(trader);
  }

  void _addPositionsToChart(TraderData trader) {
    final Iterable<PositionData> positions = trader.positionsManager.activitiesBy(symbolId: widget.symbol.id);
    for (final PositionData p in positions) {
      final double rate = SymbolData.humanicRateFromSystem(p.rate);
      final double? tp = p.takeProfit != null ? SymbolData.humanicRateFromSystem(p.takeProfit!) : null;
      final double? sl = p.stopLoss != null ? SymbolData.humanicRateFromSystem(p.stopLoss!) : null;

      _controller.runJavaScript('addDealToChart('
          '"${widget.symbol.name}", '
          '${p.id}, '
          '${p.isBuy.toString()}, '
          '${p.opened.secondsSinceEpoch}, '
          '$rate, '
          '$tp, '
          '$sl, '
          '"${p.formattedPnlWithCurrency}", '
          '"${p.isBuy ? 'Buy' : 'Sell'} ${p.formattedVolume}", '
          ');');
    }
  }

  void _addOrdersToChart(TraderData trader) {
    final Iterable<OrderData> orders = trader.ordersManager.activitiesBy(symbolId: widget.symbol.id);
    for (final OrderData order in orders) {
      _controller.runJavaScript('addOrderToChart('
          '${order.id}, '
          '"${widget.symbol.name}", '
          '"${order.formattedVolumeWithUnits}", '
          '${order.isBuy}, '
          '${order.opened.secondsSinceEpoch}, '
          '"${SymbolData.humanicRateFromSystem(order.rate)}", '
          '${order.takeProfit != null ? '"${SymbolData.humanicRateFromSystem(order.takeProfit!)}"' : "null"}, '
          '${order.stopLoss != null ? '"${SymbolData.humanicRateFromSystem(order.stopLoss!)}"' : 'null'},'
          ');');
    }
  }

  Future<void> _onHandleSpotEvent(ProtoOASpotEvent event) async {
    if (_chartLoaded && event.symbolId == widget.symbol.id) {
      if (_currentTrendBarTs != null && event.bid != null && _rate != event.bid) {
        await _controller.runJavaScript(
          "chart.data.addRate('${widget.symbol.name}', $_currentTrendBarTs, ${SymbolData.humanicRateFromSystem(event.bid!)});",
        );
        _rate = event.bid;
      }
      if (_period != null && event.trendbar != null && event.trendbar!.isNotEmpty) {
        final ProtoOATrendbar trendbar = event.trendbar!.first;
        if (_period == trendbar.period) {
          final DateTime ts = DateTime.utc(1970, 1, 1, 0, trendbar.utcTimestampInMinutes!);
          final String msg = "chart.data.setCandle('${widget.symbol.name}', '${_period!.toChartName()}',"
              '${ts.millisecondsSinceEpoch ~/ 1000},'
              '${SymbolData.humanicRateFromSystem(trendbar.low! + trendbar.deltaOpen!)},'
              '${SymbolData.humanicRateFromSystem(trendbar.low! + trendbar.deltaHigh!)},'
              '${SymbolData.humanicRateFromSystem(trendbar.low!)},'
              '${widget.symbol.bid == null ? null : SymbolData.humanicRateFromSystem(widget.symbol.bid!)},'
              '${trendbar.volume});';

          await _controller.runJavaScript(msg);
          _currentTrendBarTs = ts.millisecondsSinceEpoch ~/ 1000;
        }
      }
    }
  }

  Future<void> _symbolChanged() async {
    _chartLoadingData = true;
    _rate = null;

    if (_period != null) {
      GetIt.I<UserState>().selectedTrader.subscriptionManagerApi.unsubscribeFromTrendBars(GetIt.I<UserState>().selectedTraderId, _symbolId, _period!);
    }

    _period = null;
    _currentTrendBarTs = null;
    _symbolId = widget.symbol.id;

    await _controller.runJavaScript("dropAllDeals(); chart.setSymbol('${widget.symbol.name}');");
  }

  void _onPositionCreatedEvent(PositionData position) {
    if (!mounted || widget.symbol.id != position.symbolId) return;

    final int ts = position.opened.millisecondsSinceEpoch ~/ 1000;
    final double rate = SymbolData.humanicRateFromSystem(position.rate);
    final double? tp = position.takeProfit != null ? SymbolData.humanicRateFromSystem(position.takeProfit!) : null;
    final double? sl = position.stopLoss != null ? SymbolData.humanicRateFromSystem(position.stopLoss!) : null;

    _controller.runJavaScript('addDealToChart('
        '"${widget.symbol.name}",'
        '${position.id},'
        '${position.isBuy.toString()},'
        '$ts,'
        '$rate,'
        '$tp,'
        '$sl,'
        '"${position.formattedPnlWithCurrency}");');
  }

  void _onPositionRemovedEvent(PositionData position) {
    if (!mounted || widget.symbol.id != position.symbolId) return;

    _controller.runJavaScript('dropDeal(${position.id});');
  }

  void _onPositionUpdated(PositionData position) {
    if (!mounted || widget.symbol.id != position.symbolId) return;

    final double? tp = position.takeProfit != null ? SymbolData.humanicRateFromSystem(position.takeProfit!) : null;
    final double? sl = position.stopLoss != null ? SymbolData.humanicRateFromSystem(position.stopLoss!) : null;

    _controller.runJavaScript(
        'updateDealOnChart(${position.id}, $tp, $sl, "${position.formattedPnlWithCurrency}", "${position.isBuy ? 'Buy' : 'Sell'} ${position.formattedVolume}");');
  }

  void _onOrderCreatedEvent(OrderData order) {
    if (!mounted || widget.symbol.id != order.symbolId) return;

    _controller.runJavaScript('addOrderToChart('
        '${order.id}, '
        '"${widget.symbol.name}", '
        '"${order.formattedVolumeWithUnits}", '
        '${order.isBuy}, '
        '${order.opened.secondsSinceEpoch}, '
        '"${SymbolData.humanicRateFromSystem(order.rate)}", '
        '${order.takeProfit != null ? '"${SymbolData.humanicRateFromSystem(order.takeProfit!)}"' : "null"}, '
        '${order.stopLoss != null ? '"${SymbolData.humanicRateFromSystem(order.stopLoss!)}"' : 'null'},'
        ');');
  }

  void _onOrderRemovedEvent(OrderData order) {
    if (!mounted || widget.symbol.id != order.symbolId) return;

    _controller.runJavaScript('dropOrder(${order.id});');
  }

  void _onOrderUpdatedEvent(OrderData order) {
    if (!mounted || widget.symbol.id != order.symbolId) return;

    final String stopLossRate = order.stopLoss != null ? '"${SymbolData.humanicRateFromSystem(order.stopLoss!)}"' : 'null';

    _controller.runJavaScript('updateOrder('
        '${order.id}, '
        '"${SymbolData.humanicRateFromSystem(order.rate)}", '
        '"${order.formattedVolumeWithUnits}", '
        '${order.takeProfit != null ? '"${SymbolData.humanicRateFromSystem(order.takeProfit!)}"' : 'null'}, '
        '$stopLossRate'
        ')');
  }

  Future<void> _updateDealSLTPByChartEvent(int positionId, {double? takeProfit, double? stopLoss}) async {
    final TraderData trader = widget.symbol.trader;
    final PositionData? position = trader.positionsManager.activityBy(id: positionId);

    if (trader.accessRights.index >= ProtoOAAccessRights.noTrading.index) {
      final UserState userState = GetIt.I<UserState>();
      GetIt.I<PopupManager>().showTraderSelection(AppLocalizations.of(context)!, userState.selectedTrader, userState.traders.length > 1);
      return;
    }

    if (position == null) return;
    if (position.symbol?.details?.data.tradingMode == ProtoOATradingMode.disabledWithPendingsExecution ||
        position.symbol?.details?.data.tradingMode == ProtoOATradingMode.disabledWithoutPendingsExecution) {
      GetIt.I<PopupManager>().showSymbolDisabledByTradingMode(AppLocalizations.of(context)!);
      return;
    }

    final SymbolData? symbol = position.symbol;
    final int rounder = pow(10, 5 - (symbol?.details?.data.digits ?? 0)).toInt();
    int? tp = position.takeProfit;
    int? sl = position.stopLoss;

    if (takeProfit != null) {
      if (takeProfit < 0) {
        tp = null;
      } else {
        final int systemTP = SymbolData.systemRateFromHumanic(takeProfit);
        tp = (systemTP / rounder).round() * rounder;

        final int? takeProfitDisatance = symbol?.takeProfitDisatance;
        final int? rate = position.currentRate;

        if (takeProfitDisatance != null && rate != null) {
          final int extremeRate = rate + takeProfitDisatance * (position.isBuy ? 1 : -1);
          if ((position.isBuy && tp < extremeRate) || (!position.isBuy && tp > extremeRate)) {
            tp = null;
          }
        }
      }
    }
    if (stopLoss != null) {
      if (stopLoss < 0) {
        sl = null;
      } else {
        sl = (SymbolData.systemRateFromHumanic(stopLoss) / rounder).round() * rounder;
        final int? rate = position.currentRate;
        final int? lossDistance = position.symbol?.stopLossDistance;

        if (rate != null && lossDistance != null) {
          final int extremeRate = rate + lossDistance * (position.isBuy ? -1 : 1);
          if ((position.isBuy && sl > extremeRate) || (!position.isBuy && sl < extremeRate)) {
            sl = null;
          }
        }
      }
    }

    if (position.stopLoss == sl && position.takeProfit == tp) {
      _controller.runJavaScript('updateDealOnChart('
          '$positionId, '
          '${position.takeProfit == null ? 'null' : SymbolData.humanicRateFromSystem(position.takeProfit!)}, '
          '${position.stopLoss == null ? 'null' : SymbolData.humanicRateFromSystem(position.stopLoss!)}, '
          '"${position.formattedPnlWithCurrency}", '
          '"${position.isBuy ? 'Buy' : 'Sell'} ${position.humanicVolume}");');
      return;
    } else {
      await position.editPosition(context, stopLoss: sl, takeProfit: tp);
    }
  }

  Future<void> _updateOrderSLTPByChartEvent(int orderId, {double? takeProfit, double? stopLoss}) async {
    if (!mounted) return;

    final TraderData trader = GetIt.I<UserState>().selectedTrader;
    if (trader.accessRights.index >= ProtoOAAccessRights.noTrading.index) {
      final UserState userState = GetIt.I<UserState>();
      GetIt.I<PopupManager>().showTraderSelection(AppLocalizations.of(context)!, userState.selectedTrader, userState.traders.length > 1);
      return;
    }

    final OrderData? order = trader.ordersManager.activityBy(id: orderId);
    if (order == null) {
      GetIt.I<PopupManager>().showSomeErrorOccurred(AppLocalizations.of(context)!);
      return;
    }
    if (order.symbol?.details?.data.tradingMode == ProtoOATradingMode.disabledWithPendingsExecution ||
        order.symbol?.details?.data.tradingMode == ProtoOATradingMode.disabledWithoutPendingsExecution) {
      GetIt.I<PopupManager>().showSymbolDisabledByTradingMode(AppLocalizations.of(context)!);
    }

    final SymbolData? symbol = order.symbol;
    final int rounder = pow(10, 5 - (symbol?.details?.data.digits ?? 0)).toInt();
    int? tp = order.takeProfit;
    int? sl = order.stopLoss;

    if (takeProfit != null) {
      if (takeProfit < 0) {
        tp = null;
      } else {
        final int systemTP = SymbolData.systemRateFromHumanic(takeProfit);
        tp = (systemTP / rounder).round() * rounder;

        final int? takeProfitDisatance = symbol?.takeProfitDisatance;

        if (takeProfitDisatance != null) {
          final int extremeRate = order.rate + takeProfitDisatance * (order.isBuy ? 1 : -1);
          if ((order.isBuy && tp < extremeRate) || (!order.isBuy && tp > extremeRate)) {
            tp = null;
          }
        }
      }
    }
    if (stopLoss != null) {
      if (stopLoss < 0) {
        sl = null;
      } else {
        final int systemSL = SymbolData.systemRateFromHumanic(stopLoss);
        sl = (systemSL / rounder).round() * rounder;
        final int? lossDistance = order.symbol?.stopLossDistance;

        if (lossDistance != null) {
          final int extremeRate = order.rate + lossDistance * (order.isBuy ? -1 : 1);
          if ((order.isBuy && sl > extremeRate) || (!order.isBuy && sl < extremeRate)) {
            sl = null;
          }
        }
      }
    }

    if (order.stopLoss == sl && order.takeProfit == tp) {
      _controller.runJavaScript('updateOrder('
          '$orderId, '
          '${SymbolData.humanicRateFromSystem(order.rate)}, '
          '${SymbolData.humanicVolume(order.volumeLeft!)}, '
          '${order.takeProfit == null ? 'null' : SymbolData.humanicRateFromSystem(order.takeProfit!)}, '
          '${order.stopLoss == null ? 'null' : SymbolData.humanicRateFromSystem(order.stopLoss!)});');
      return;
    } else {
      await order.editOrder(context, order.rate, order.volume, takeProfit: tp, stopLoss: sl, expiresAtTs: order.expireAt?.millisecondsSinceEpoch);
    }
  }

  Future<void> _closePositionByChartEvent(int positionId) async {
    final TraderData trader = GetIt.I<UserState>().selectedTrader;

    if (trader.accessRights.index >= ProtoOAAccessRights.noTrading.index) {
      final UserState userState = GetIt.I<UserState>();
      GetIt.I<PopupManager>().showTraderSelection(AppLocalizations.of(context)!, userState.selectedTrader, userState.traders.length > 1);
    } else {
      final PositionData? position = trader.positionsManager.activityBy(id: positionId);
      if (position?.symbol?.details?.data.tradingMode == ProtoOATradingMode.disabledWithPendingsExecution ||
          position?.symbol?.details?.data.tradingMode == ProtoOATradingMode.disabledWithoutPendingsExecution) {
        GetIt.I<PopupManager>().showSymbolDisabledByTradingMode(AppLocalizations.of(context)!);
      } else {
        GetIt.I<AppState>().setUIBlocked(true);
        try {
          await trader.positionsManager.activityBy(id: positionId)?.closePosition(context);
        } catch (e) {
          Logger.error('Error occurred for closing position by chart', e);
          GetIt.I<PopupManager>().showSomeErrorOccurred(AppLocalizations.of(context)!);
        }
        GetIt.I<AppState>().setUIBlocked(false);
      }
    }
  }

  Future<void> _closeOrderByChartEvent(int orderId) async {
    final TraderData trader = GetIt.I<UserState>().selectedTrader;

    if (trader.accessRights.index >= ProtoOAAccessRights.noTrading.index) {
      final UserState userState = GetIt.I<UserState>();
      GetIt.I<PopupManager>().showTraderSelection(AppLocalizations.of(context)!, userState.selectedTrader, userState.traders.length > 1);
    } else {
      final OrderData? order = trader.ordersManager.activityBy(id: orderId);

      if (order?.symbol?.details?.data.tradingMode == ProtoOATradingMode.disabledWithPendingsExecution ||
          order?.symbol?.details?.data.tradingMode == ProtoOATradingMode.disabledWithoutPendingsExecution) {
        GetIt.I<PopupManager>().showSymbolDisabledByTradingMode(AppLocalizations.of(context)!);
      } else {
        GetIt.I<AppState>().setUIBlocked(true);
        await GetIt.I<UserState>().selectedTrader.ordersManager.activityBy(id: orderId)?.cancelOrder(context);
        GetIt.I<AppState>().setUIBlocked(false);
      }
    }
  }
}
