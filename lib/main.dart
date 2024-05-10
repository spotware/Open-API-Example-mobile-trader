// ignore_for_file: non_constant_identifier_names
import 'dart:convert';

import 'package:ctrader_example_app/extensions.dart';
import 'package:ctrader_example_app/l10n/localizations.dart';
import 'package:ctrader_example_app/logger.dart';
import 'package:ctrader_example_app/models/symbol_icons.dart';
import 'package:ctrader_example_app/popups/popup.dart';
import 'package:ctrader_example_app/popups/popup_manager.dart';
import 'package:ctrader_example_app/remote/proto.dart' as proto;
import 'package:ctrader_example_app/remote/remote_api_manager.dart';
import 'package:ctrader_example_app/screens/account_screen.dart';
import 'package:ctrader_example_app/screens/activity_screen.dart';
import 'package:ctrader_example_app/screens/buy_sell_screen.dart';
import 'package:ctrader_example_app/screens/edit_order_position.dart';
import 'package:ctrader_example_app/screens/login_screen.dart';
import 'package:ctrader_example_app/screens/login_webview.dart';
import 'package:ctrader_example_app/screens/market_screen.dart';
import 'package:ctrader_example_app/screens/trading_room_screen.dart';
import 'package:ctrader_example_app/states/app_state.dart';
import 'package:ctrader_example_app/states/simultaneous_trading_state.dart';
import 'package:ctrader_example_app/states/tutorial_state.dart';
import 'package:ctrader_example_app/states/user_state.dart';
import 'package:ctrader_example_app/styles/dark_theme_config.dart';
import 'package:ctrader_example_app/styles/itheme_config.dart';
import 'package:ctrader_example_app/styles/light_theme_config.dart';
import 'package:ctrader_example_app/styles/login_theme.dart';
import 'package:ctrader_example_app/widgets/block_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:timezone/data/latest_all.dart' as tz_latest;
import 'package:timezone/timezone.dart' as tz;

enum ThemeType { light, dark }

// CONSTANTS
const bool ONLY_DEMO = true;
late IThemeConfig THEME;
final LoginTheme THEME_LOGIN = LoginTheme();
final List<IThemeConfig> THEMES = <IThemeConfig>[LightThemeConfig(), DarkThemeConfig()];
final GlobalKey<NavigatorState> NAVIGATOR_KEY = GlobalKey<NavigatorState>();
String CURRENT_ROUTE_NAME = '';
late final List<List<String>> SYMBOL_PAIRS = <List<String>>[];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Logger.instance.level = kReleaseMode ? LoggerLevel.ERROR : LoggerLevel.DEBUG;
  Logger.instance.title = 'cTrader';
  Logger.instance.printTime = false;
  Logger.log(() => ' LOADING APPLICATION '.centerLabel(80, '-'));

  FlutterError.onError = (FlutterErrorDetails details) {
    Logger.error(' UNHANDELED FLUTTER ERROR '.centerLabel(80, '='), details.exception);
    FlutterError.dumpErrorToConsole(details);
  };
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    Logger.error(' UNHANDELED ERROR '.centerLabel(80, '='), error);
    if (stack.toString().isNotEmpty) Logger.error('Error stack: $stack');
    return true;
  };

  tz_latest.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation(await FlutterNativeTimezone.getLocalTimezone()));

  final String jsonStr = await rootBundle.loadString('assets/json/symbol_pairs.json');
  final List<dynamic> jsonArr = jsonDecode(jsonStr) as List<dynamic>;
  for (final dynamic item in jsonArr) {
    SYMBOL_PAIRS.add(List.castFrom<dynamic, String>(item as List<dynamic>));
  }

  GetIt.I.registerSingleton<SymbolIcons>(SymbolIcons());
  await GetIt.I<SymbolIcons>().init('assets/json/symbol_icons.json');

  GetIt.I.registerSingleton<AppState>(AppState());
  await GetIt.I<AppState>().loadConfigs('assets/json/app_configs.json');

  GetIt.I.registerSingleton<UserState>(UserState());
  await GetIt.I<UserState>().init();

  GetIt.I.registerSingleton<SimultaneousTrdaingState>(SimultaneousTrdaingState());
  GetIt.I.registerSingleton<RemoteAPIManager>(RemoteAPIManager());
  GetIt.I.registerSingleton<PopupManager>(PopupManager());
  GetIt.I.registerSingleton<TutorialState>(TutorialState());

  GetIt.I<RemoteAPIManager>().subscribe<proto.ProtoOASymbolByIdRes>(GetIt.I<UserState>().handleSymbolDetailsResponse);
  GetIt.I<RemoteAPIManager>().subscribe<proto.ProtoOAExecutionEvent>(_handleExecutionEvent);
  GetIt.I<RemoteAPIManager>().subscribe<proto.ProtoOATrailingSLChangedEvent>(GetIt.I<UserState>().handlePositionTrailingStopEvent);
  GetIt.I<RemoteAPIManager>().subscribe<proto.ProtoOASpotEvent>(GetIt.I<UserState>().handleSpotEvent);
  GetIt.I<RemoteAPIManager>().subscribe<proto.ProtoOAGetPositionUnrealizedPnLRes>(GetIt.I<UserState>().handlePnlEvent);
  GetIt.I<RemoteAPIManager>().subscribe<proto.ProtoOAReconcileRes>(GetIt.I<UserState>().handleReconcileResponse);
  GetIt.I<RemoteAPIManager>().subscribe<proto.ProtoOASymbolChangedEvent>(GetIt.I<UserState>().handleSymbolChangedEvent);
  GetIt.I<RemoteAPIManager>().subscribe<proto.ProtoOATraderUpdatedEvent>(GetIt.I<UserState>().handleTraderUpdatedEvent);
  GetIt.I<RemoteAPIManager>().subscribe<proto.ProtoOAMarginChangedEvent>(GetIt.I<UserState>().handleMarginChangedEvent);

  GetIt.I<RemoteAPIManager>().connect();

  runApp(const MyApp());
}

void _handleExecutionEvent(proto.ProtoOAExecutionEvent event) {
  GetIt.I<UserState>().handleExecutionEvent(event);
  final int selectedTraderId = GetIt.I<UserState>().selectedTraderId;

  if (!GetIt.I<SimultaneousTrdaingState>().isAccountPaired(event.ctidTraderAccountId) && selectedTraderId != event.ctidTraderAccountId) return;

  if (event.order == null) return;

  final AppLocalizations l10n = AppLocalizations.of(NAVIGATOR_KEY.currentContext!)!;
  final proto.ProtoOAOrder oaOrder = event.order!;
  final bool isMarket = oaOrder.orderType == proto.ProtoOAOrderType.market;
  final bool isOrder = oaOrder.orderType == proto.ProtoOAOrderType.limit || oaOrder.orderType == proto.ProtoOAOrderType.stop;
  final bool isSlTp = oaOrder.orderType == proto.ProtoOAOrderType.stopLossTakeProfit;
  final bool isFilled = event.executionType == proto.ProtoOAExecutionType.orderFilled || event.executionType == proto.ProtoOAExecutionType.orderPartialFill;

  if (isMarket && oaOrder.isStopOut == true) {
    GetIt.I<PopupManager>().showPositionStopOut(l10n, event);
  } else if ((isMarket && oaOrder.closingOrder == true && event.executionType == proto.ProtoOAExecutionType.orderFilled) ||
      (isMarket && event.position?.tradeData.volume == 0 && event.executionType != proto.ProtoOAExecutionType.orderAccepted)) {
    GetIt.I<PopupManager>().showPositionClosed(l10n, event);
  } else if (isOrder && event.executionType == proto.ProtoOAExecutionType.orderCancelled) {
    GetIt.I<PopupManager>().showPendingOrderWasCancelled(l10n, event);
  } else if (isOrder && event.executionType == proto.ProtoOAExecutionType.orderRejected) {
    GetIt.I<PopupManager>().showPendingOrderRejected(l10n, event);
  } else if (isOrder && event.executionType == proto.ProtoOAExecutionType.orderExpired) {
    GetIt.I<PopupManager>().showPendingOrderExpired(l10n, event);
  } else if (isOrder && isFilled) {
    GetIt.I<PopupManager>().handlePendingOrderExecutedEvent(l10n, event);
  } else if (isSlTp && event.executionType == proto.ProtoOAExecutionType.orderFilled && event.position?.tradeData.volume == 0) {
    GetIt.I<PopupManager>().showPositionClosed(l10n, event);
  } else if (isMarket &&
      event.executionType != proto.ProtoOAExecutionType.orderAccepted &&
      (oaOrder.closingOrder == true || event.position!.tradeData.volume == 0)) {
    Logger.log(() => 'position closed by tp/sl/ts'); // not fire
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.paused) {
      _onApplicationPaused();
    } else if (state == AppLifecycleState.resumed) {
      _onApplicationResumed();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: <SingleChildWidget>[
        ChangeNotifierProvider<PopupManager>(create: (BuildContext context) => GetIt.I<PopupManager>()),
        ChangeNotifierProvider<AppState>(create: (BuildContext context) => GetIt.I<AppState>()),
        ChangeNotifierProvider<UserState>(create: (BuildContext context) => GetIt.I<UserState>()),
        ChangeNotifierProvider<TutorialState>(create: (BuildContext context) => GetIt.I<TutorialState>()),
      ],
      builder: (BuildContext context, Widget? child) {
        final AppState appState = context.watch<AppState>();
        THEME = THEMES[appState.themeType.index];

        return MaterialApp(
          navigatorKey: NAVIGATOR_KEY,
          title: 'cTrader Open API example app',
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: appState.locale,
          theme: THEME.theme,
          builder: (BuildContext context, Widget? child) {
            final Popup? popup = context.watch<PopupManager>().currentPopup;
            child ??= Container();

            if (popup != null) {
              return Stack(children: <Widget>[child, popup]);
            } else if (context.watch<AppState>().isUIBlocked) {
              return BlockWidget(child: child);
            }

            return child;
          },
          initialRoute: LoginScreen.ROUTE_NAME,
          onGenerateRoute: (RouteSettings settings) {
            switch (settings.name) {
              case LoginScreen.ROUTE_NAME:
                CURRENT_ROUTE_NAME = LoginScreen.ROUTE_NAME;
                return MaterialPageRoute<void>(builder: (BuildContext context) => const LoginScreen());

              case MarketScreen.ROUTE_NAME:
                CURRENT_ROUTE_NAME = MarketScreen.ROUTE_NAME;
                return MaterialPageRoute<void>(builder: (BuildContext context) => const MarketScreen());

              case AccountScreen.ROUTE_NAME:
                CURRENT_ROUTE_NAME = AccountScreen.ROUTE_NAME;
                return MaterialPageRoute<void>(builder: (BuildContext context) => const AccountScreen());

              case ActivityScreen.ROUTE_NAME:
                CURRENT_ROUTE_NAME = ActivityScreen.ROUTE_NAME;
                return MaterialPageRoute<void>(builder: (BuildContext context) => const ActivityScreen());

              case TradingRoomScreen.ROUTE_NAME:
                CURRENT_ROUTE_NAME = TradingRoomScreen.ROUTE_NAME;
                return MaterialPageRoute<void>(builder: (BuildContext context) => const TradingRoomScreen());

              case LoginWebView.ROUTE_NAME:
                return MaterialPageRoute<String?>(builder: (BuildContext context) => const LoginWebView());

              case BuySellScreen.ROUTE_NAME:
                final Map<String, dynamic> arguments = settings.arguments! as Map<String, dynamic>;
                final bool isBuy = arguments['isBuy'] as bool;
                final int symbolId = arguments['symbolId'] as int;

                return MaterialPageRoute<void>(builder: (BuildContext context) => BuySellScreen(isBuy: isBuy, symbolId: symbolId));

              case EditOrderPositionScreen.ROUTE_NAME:
                final Map<String, dynamic> arguments = settings.arguments! as Map<String, dynamic>;
                final int? orderId = arguments['orderId'] as int?;
                final int? positionId = arguments['positionId'] as int?;

                return MaterialPageRoute<void>(builder: (BuildContext context) => EditOrderPositionScreen(orderId: orderId, positionId: positionId));
            }

            return null;
          },
        );
      },
    );
  }

  void _onApplicationPaused() {
    Logger.log(() => 'Application enter background mode');
    GetIt.I<AppState>().changeAppStatus(AppStatus.SLEEP);
    GetIt.I<RemoteAPIManager>().onAppPaused();
  }

  void _onApplicationResumed() {
    final AppState appState = GetIt.I<AppState>();
    if (appState.appStatus == AppStatus.ACTIVE) return;

    Logger.log(() => 'Application backs to active mode');
    appState.changeAppStatus(AppStatus.ACTIVE);
    GetIt.I<RemoteAPIManager>().onAppResumed();
  }
}
