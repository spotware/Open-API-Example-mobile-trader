import 'package:ctrader_example_app/main.dart';
import 'package:ctrader_example_app/models/trader_data.dart';
import 'package:ctrader_example_app/remote/remote_api_manager.dart';
import 'package:ctrader_example_app/remote/spot_sub_manager.dart';
import 'package:ctrader_example_app/screens/account_screen.dart';
import 'package:ctrader_example_app/screens/activity_screen.dart';
import 'package:ctrader_example_app/screens/login_screen.dart';
import 'package:ctrader_example_app/screens/market_screen.dart';
import 'package:ctrader_example_app/states/app_state.dart';
import 'package:ctrader_example_app/states/simultaneous_trading_state.dart';
import 'package:ctrader_example_app/states/user_state.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> openUrlInBrowser(String url) {
  final Uri uri = Uri.parse(url);
  return canLaunchUrl(uri).then((_) => launchUrl(uri, mode: LaunchMode.externalApplication));
}

Future<void> openOpenApiTelegram() {
  return openUrlInBrowser('https://t.me/ctrader_open_api_support');
}

void changePageWithSlideTransition(BuildContext context, Offset direction, Widget page) {
  final PageRouteBuilder<void> routeBuilder = PageRouteBuilder<void>(
    pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
      CURRENT_ROUTE_NAME = page is MarketScreen
          ? MarketScreen.ROUTE_NAME
          : (page is AccountScreen ? AccountScreen.ROUTE_NAME : (page is ActivityScreen ? ActivityScreen.ROUTE_NAME : ''));

      return page;
    },
    transitionsBuilder: (
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
    ) {
      final Tween<Offset> tween = Tween<Offset>(begin: direction, end: Offset.zero);
      final Animation<Offset> offsetAnimation = animation.drive(tween);

      return SlideTransition(position: offsetAnimation, child: child);
    },
  );

  Navigator.pushAndRemoveUntil(context, routeBuilder, (Route<dynamic> route) => false);
}

Future<void> logout(BuildContext context) async {
  final AppState appState = GetIt.I<AppState>();
  final UserState userState = GetIt.I<UserState>();
  final RemoteAPIManager remoteApiMngr = GetIt.I<RemoteAPIManager>();

  appState.setUIBlocked(true);

  if (!userState.selectedTraderId.isNegative) {
    final SpotSubscriptionManager spotSubMngr = remoteApiMngr.getSpotSubscriptionManager(demo: userState.selectedTrader.demo);
    await spotSubMngr.unsubscribe(userState.selectedTraderId, spotSubMngr.subscribedSymbols.toList());
  }

  for (final TraderData trader in userState.traders) await trader.remoteApi.logoutAccount(trader.id);

  userState.onLogedOut();
  GetIt.I<SimultaneousTrdaingState>().disable();

  Navigator.pushNamedAndRemoveUntil(context, LoginScreen.ROUTE_NAME, (Route<dynamic> route) => false);

  appState.setUIBlocked(false);
}
