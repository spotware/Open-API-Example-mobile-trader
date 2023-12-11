import 'dart:async';
import 'dart:convert';

import 'package:ctrader_example_app/extensions.dart';
import 'package:ctrader_example_app/l10n/localizations.dart';
import 'package:ctrader_example_app/logger.dart';
import 'package:ctrader_example_app/main.dart';
import 'package:ctrader_example_app/models/symbol_data.dart';
import 'package:ctrader_example_app/models/trader_data.dart';
import 'package:ctrader_example_app/remote/proto.dart';
import 'package:ctrader_example_app/remote/spot_sub_manager.dart';
import 'package:ctrader_example_app/screens/buy_sell_screen.dart';
import 'package:ctrader_example_app/states/user_state.dart';
import 'package:ctrader_example_app/styles/itheme_config.dart';
import 'package:ctrader_example_app/utils.dart';
import 'package:ctrader_example_app/widgets/buy_sell_button.dart';
import 'package:ctrader_example_app/widgets/side_menu.dart';
import 'package:ctrader_example_app/widgets/wrapped_appbar.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TradingRoomScreen extends StatefulWidget {
  const TradingRoomScreen({super.key});

  static const String ROUTE_NAME = '/tradingRoom';

  @override
  State<TradingRoomScreen> createState() => _TradingRoomScreenState();
}

class _TradingRoomScreenState extends State<TradingRoomScreen> {
  late WebViewController _controller;
  String? _chartSymbolName;
  SymbolData? _chartSymbol;
  ProtoOATrendbarPeriod? _chartPeriod;
  int? _chartLiveTrendbarTs;

  @override
  void initState() {
    super.initState();

    GetIt.I<UserState>().selectedTrader.remoteApi.subscribe<ProtoOASpotEvent>(_onHandleSpotEvent);

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {},
          onPageFinished: (String url) {
            final IThemeConfig theme = THEMES[ThemeType.light.index];
            final String bg = theme.background().value.toRadixString(16).substring(2);
            final String fg = theme.onBackground().value.toRadixString(16).substring(2);
            _controller.runJavaScript("init('#$bg', '#$fg');");
          },
          onWebResourceError: (WebResourceError error) {},
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
        Logger.debug(() => 'TradingRoom: ${msg.message}');
        final Map<String, dynamic> event = jsonDecode(msg.message) as Map<String, dynamic>;
        if (event['type'] == 'loadCandles') {
          final Map<String, dynamic> data = event['data'] as Map<String, dynamic>;
          final String symbol = data['symbol'] as String;
          final String timeframe = data['timeframe'] as String;
          final String callback = data['callback'] as String;
          final int count = data['count'] as int;
          final int? timestampFrom = event['data']['timestampFrom'] as int?;

          _loadCandlesForChart(symbol, timeframe, count, callback, timestampFrom);
        } else if (event['type'] == 'symbolChanged') {
          _symbolChanged(event['data']['symbol'] as String);
        }
      })
      // ..loadRequest(Uri.parse('https://ya.ru'));
      ..loadFlutterAsset('assets/trading4pro/trading-room.html');
  }

  @override
  void dispose() {
    Timer.run(() async {
      final TraderData trader = GetIt.I<UserState>().selectedTrader;
      final SpotSubscriptionManager spotSubscriptionManager = trader.subscriptionManagerApi;

      trader.remoteApi.unsubscribe<ProtoOASpotEvent>(_onHandleSpotEvent);
      if (_chartPeriod != null && _chartSymbol != null) await spotSubscriptionManager.unsubscribeFromTrendBars(trader.id, _chartSymbol!.id, _chartPeriod!);
      if (_chartSymbol != null) await spotSubscriptionManager.unsubscribe(trader.id, <int>[_chartSymbol!.id]);
    });

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    // need subscription for updates to update symbol rates on buttons
    context.watch<UserState>();

    return WillPopScope(
      onWillPop: () => Future<bool>.value(false),
      child: Scaffold(
        appBar: WrappedAppBar(title: l10n.tradingRoom),
        drawer: const SideMenu(),
        body: Column(children: <Widget>[
          Expanded(child: WebViewWidget(controller: _controller)),
          SizedBox(
            height: 80,
            child: Row(children: <Widget>[
              const SizedBox(width: 16),
              Expanded(child: BuySellButton(false, _chartSymbol?.formattedSellRate ?? '----', _onClickBuySellButton)),
              const SizedBox(width: 16),
              Expanded(child: BuySellButton(true, _chartSymbol?.formattedBuyRate ?? '----', _onClickBuySellButton)),
              const SizedBox(width: 16),
            ]),
          ),
        ]),
      ),
    );
  }

  void _onHandleSpotEvent(ProtoOASpotEvent event) {
    if (!mounted || _chartSymbol?.id != event.symbolId) return;

    if (_chartPeriod != null && _chartSymbol != null) {
      if (event.trendbar != null && event.trendbar!.isNotEmpty) {
        final ProtoOATrendbar trendbar = event.trendbar!.first;
        if (trendbar.period == _chartPeriod) {
          final DateTime ts = DateTime.utc(1970, 1, 1, 0, trendbar.utcTimestampInMinutes!);
          final String msg = "chart.data.setCandle('$_chartSymbolName', '${_chartPeriod!.toChartName()}',"
              '${ts.millisecondsSinceEpoch ~/ 1000},'
              '${SymbolData.humanicRateFromSystem(trendbar.low! + trendbar.deltaOpen!)},'
              '${SymbolData.humanicRateFromSystem(trendbar.low! + trendbar.deltaHigh!)},'
              '${SymbolData.humanicRateFromSystem(trendbar.low!)},'
              '${_chartSymbol?.bid == null ? null : SymbolData.humanicRateFromSystem(_chartSymbol!.bid!)},'
              '${trendbar.volume});';

          _controller.runJavaScript(msg);
          _chartLiveTrendbarTs = ts.millisecondsSinceEpoch ~/ 1000;
        }
      }

      if (_chartLiveTrendbarTs != null && event.bid != null) {
        _controller.runJavaScript(
          "chart.data.addRate('$_chartSymbolName', $_chartLiveTrendbarTs, ${SymbolData.humanicRateFromSystem(event.bid!)});",
        );
      }
    }
  }

  Future<void> _loadCandlesForChart(String symbolName, String timeframe, int count, String callback, [int? timestampFrom]) async {
    if (!mounted) return _controller.runJavaScript('$callback();');

    final TraderData trader = GetIt.I<UserState>().selectedTrader;
    final SpotSubscriptionManager spotSubscriptionManager = trader.subscriptionManagerApi;
    final ProtoOATrendbarPeriod period = ProtoOATrendbarPeriodExtention.byChartName(timeframe);
    final Iterable<SymbolData> symbols = trader.tree.findSymbolForSimultaneousTrading(name: symbolName);
    final SymbolData? symbol = symbols.isEmpty ? null : symbols.first;

    // if user comes from markets page, need delay for unsubscription event for unvisible symbols
    // in other case selected symbol will be unsubscribed
    if (_chartSymbol == null) await Future<void>.delayed(const Duration(milliseconds: 1000));

    if (_chartSymbol != null && _chartPeriod != null && _chartSymbol != symbol) {
      // unsubscribe from previous symbol
      await spotSubscriptionManager.unsubscribeFromTrendBars(trader.id, _chartSymbol!.id, _chartPeriod!);
      _chartPeriod = null;

      await spotSubscriptionManager.unsubscribe(trader.id, <int>[_chartSymbol!.id]);
      _chartSymbol = null;
      _chartSymbolName = null;
    } else if (_chartPeriod != null && _chartPeriod != period) {
      // unsubscribe from previous period
      await spotSubscriptionManager.unsubscribeFromTrendBars(trader.id, _chartSymbol!.id, _chartPeriod!);
      _chartPeriod = null;
    }

    final int to = timestampFrom != null ? timestampFrom * 1000 : DateTime.now().millisecondsSinceEpoch;
    final int from = DateTime.fromMillisecondsSinceEpoch(to).subtract(Duration(seconds: period.seconds() * count)).millisecondsSinceEpoch;

    if (symbol == null) {
      setState(() {});
      return Logger.error("Can't find symbol($symbolName) in platform");
    }

    symbol.getDetailsData();

    try {
      _chartSymbolName = symbolName;
      await spotSubscriptionManager.subscribe(trader.id, <int>[symbol.id]);
      _chartSymbol = symbol;

      _chartPeriod = period;
      await spotSubscriptionManager.subscribeForTrendBars(trader.id, symbol.id, period);

      final ProtoOAGetTrendbarsRes trendbarsRes = await trader.remoteApi.sendGetTrendbars(trader.id, symbol.id, count, period, from, to);

      final List<Map<String, dynamic>> candles = <Map<String, dynamic>>[];
      for (final ProtoOATrendbar bar in trendbarsRes.trendbar) {
        candles.add(<String, dynamic>{
          'symbol': symbol.name,
          'timeframe': trendbarsRes.period.toChartName(),
          'timestamp': (bar.utcTimestampInMinutes ?? 0) * 60,
          'open': SymbolData.humanicRateFromSystem((bar.low ?? 0) + (bar.deltaOpen ?? 0)),
          'high': SymbolData.humanicRateFromSystem((bar.low ?? 0) + (bar.deltaHigh ?? 0)),
          'low': SymbolData.humanicRateFromSystem(bar.low ?? 0),
          'close': SymbolData.humanicRateFromSystem((bar.low ?? 0) + (bar.deltaClose ?? 0)),
          'volume': bar.volume,
        });
      }

      await _controller.runJavaScript('$callback(${jsonEncode(candles)});');
    } catch (e) {
      Logger.error("Can't subscribe for spots", e);
    }

    setState(() {});
  }

  Future<void> _symbolChanged(String symbolName) async {
    final TraderData trader = GetIt.I<UserState>().selectedTrader;
    final SpotSubscriptionManager spotSubscriptionManager = trader.subscriptionManagerApi;
    final Iterable<SymbolData> symbols = trader.tree.findSymbolForSimultaneousTrading(name: symbolName);

    if (!mounted) return Logger.log(() => 'Widget is not loaded anymore');

    if (_chartSymbol != null && _chartPeriod != null) {
      try {
        await spotSubscriptionManager.unsubscribeFromTrendBars(trader.id, _chartSymbol!.id, _chartPeriod!);
      } catch (e) {
        Logger.error('Error occurred for unsubscibing from live trend bars for symbol(${_chartSymbol!.name})', e);
      }
    }

    if (_chartSymbol != null) {
      try {
        await spotSubscriptionManager.unsubscribe(trader.id, <int>[_chartSymbol!.id]);
      } catch (e) {
        Logger.error('Error occurred for unsubscribing from spots for symbol(${_chartSymbol!.name})', e);
      } finally {
        _chartSymbol = null;
        _chartSymbolName = null;
      }
    }

    if (symbols.isEmpty) {
      setState(() {});
      return Logger.error('Symbol($symbolName) is not found for selected trader');
    }
    final SymbolData symbol = symbols.first;
    symbol.getDetailsData();

    try {
      _chartSymbolName = symbolName;
      await spotSubscriptionManager.subscribe(trader.id, <int>[symbol.id]);
      _chartSymbol = symbol;

      await spotSubscriptionManager.subscribeForTrendBars(trader.id, symbol.id, _chartPeriod!);
    } catch (e) {
      Logger.error('Error occurred at subscribing process', e);
    }

    setState(() {});
  }

  void _onClickBuySellButton(bool isBuy) {
    if (_chartSymbol != null) {
      Navigator.pushNamed(context, BuySellScreen.ROUTE_NAME, arguments: <String, Object>{'isBuy': isBuy, 'symbolId': _chartSymbol!.id});
    }
  }
}
