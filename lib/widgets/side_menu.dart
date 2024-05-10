import 'dart:convert';

import 'package:ctrader_example_app/extensions.dart';
import 'package:ctrader_example_app/l10n/localizations.dart';
import 'package:ctrader_example_app/main.dart';
import 'package:ctrader_example_app/screens/account_screen.dart';
import 'package:ctrader_example_app/screens/activity_screen.dart';
import 'package:ctrader_example_app/screens/market_screen.dart';
import 'package:ctrader_example_app/screens/terms_screen.dart';

import 'package:ctrader_example_app/screens/trading_room_screen.dart';
import 'package:ctrader_example_app/states/app_state.dart';
import 'package:ctrader_example_app/states/user_state.dart';
import 'package:ctrader_example_app/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final UserState userState = context.watch<UserState>();

    return Drawer(
      child: SafeArea(
        child: Column(
          children: <Widget>[
            _menuLine(context, l10n),
            _divider(),
            _helloUser(l10n),
            _divider(),
            _menuItem(l10n.markets, () => _openMarkets(context)),
            _menuItem(l10n.myAccound, () => _openMyAccount(context)),
            _menuItem(l10n.myActivity, () => _openMyActivity(context), widgets: <Widget>[
              _activityCircleAmount(
                userState.selectedTrader.pnl < 0 ? THEME.red : THEME.green,
                userState.selectedTrader.positionsManager.count,
              ),
              _activityCircleAmount(THEME.menuActivityOrders(), userState.selectedTrader.ordersManager.count),
            ]),
            _menuItem(l10n.tradingRoom, () => _openTradingRoom(context)),
            const Spacer(),
            _menuItemBottom(l10n.logOut, () => _logOut(context)),
            _divider(),
            _menuItemBottom(
              l10n.openApiSupport,
              () => _support(context),
              icon: SvgPicture.asset('assets/svg/telegram.svg'),
            ),
            _divider(),
            _menuItemBottom(
              l10n.specialThanks,
              () => _specialThanks(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() => Divider(height: 1, color: THEME.menuDivider());

  Widget _menuLine(BuildContext context, AppLocalizations l10n) {
    return Container(
      height: 47,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.center,
      child: Row(
        children: <Widget>[
          Expanded(child: Text(l10n.menu, style: THEME.texts.sideMenu, textAlign: TextAlign.center)),
          GestureDetector(
            onTap: () => _closeMenu(context),
            child: Container(
              height: 24,
              width: 24,
              alignment: Alignment.center,
              child: SvgPicture.asset(
                'assets/svg/x.svg',
                colorFilter: THEME.menuTextSecondary().asFilter,
                width: 20,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _helloUser(AppLocalizations l10n) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.centerLeft,
      child: Text(l10n.helloTrader, style: THEME.texts.sideMenu),
    );
  }

  Widget _menuItem(String label, VoidCallback onTap, {List<Widget>? widgets}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: <Widget>[
            Text(label, style: THEME.texts.sideMenu),
            for (final Widget w in widgets ?? <Widget>[]) w,
            const Spacer(),
            SvgPicture.asset('assets/svg/arrow_greater.svg'),
          ],
        ),
      ),
    );
  }

  Widget _menuItemBottom(String label, VoidCallback onTap, {Widget? icon}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: <Widget>[
            Text(label, style: THEME.texts.sideMenuSecondary),
            const Spacer(),
            icon ?? SvgPicture.asset('assets/svg/arrow_greater.svg'),
          ],
        ),
      ),
    );
  }

  Widget _activityCircleAmount(Color color, int amount) {
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: Container(
        height: 24,
        width: 24,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(24)),
        child: FittedBox(child: Text(amount.toString(), style: THEME.texts.sideMenuActivityCircles)),
      ),
    );
  }

  void _closeMenu(BuildContext context) {
    Scaffold.of(context).closeDrawer();
  }

  void _openMarkets(BuildContext context) {
    if (CURRENT_ROUTE_NAME == MarketScreen.ROUTE_NAME) {
      _closeMenu(context);
      return;
    }

    Navigator.pushNamedAndRemoveUntil(context, MarketScreen.ROUTE_NAME, (Route<dynamic> route) => false);
  }

  void _openMyAccount(BuildContext context) {
    if (CURRENT_ROUTE_NAME == AccountScreen.ROUTE_NAME) {
      _closeMenu(context);
      return;
    }

    Navigator.pushNamedAndRemoveUntil(context, AccountScreen.ROUTE_NAME, (Route<dynamic> route) => false);
  }

  void _openMyActivity(BuildContext context) {
    if (CURRENT_ROUTE_NAME == ActivityScreen.ROUTE_NAME) {
      _closeMenu(context);
      return;
    }
    Navigator.pushNamedAndRemoveUntil(context, ActivityScreen.ROUTE_NAME, (Route<dynamic> route) => false);
  }

  void _openManageAccount(BuildContext context) {}

  Future<void> _openTradingRoom(BuildContext context) async {
    if (CURRENT_ROUTE_NAME == TradingRoomScreen.ROUTE_NAME) {
      _closeMenu(context);
      return;
    }

    if (!GetIt.I<AppState>().isTrTermsChecked) {
      final List<dynamic> json = jsonDecode(await rootBundle.loadString('assets/json/tr_terms.json')) as List<dynamic>;
      final Iterable<List<String>> terms = json.cast<List<dynamic>>().map((List<dynamic> e) => e.cast<String>());
      final bool? agree = await Navigator.push<bool?>(context, MaterialPageRoute<bool?>(builder: (BuildContext context) => TermsScreen(terms: terms)));

      if (agree == true) {
        GetIt.I<AppState>().markTrTermsChecked();
      } else {
        return;
      }
    }

    Navigator.pushNamedAndRemoveUntil(context, TradingRoomScreen.ROUTE_NAME, (Route<dynamic> route) => false);
  }

  void _logOut(BuildContext context) {
    logout(context);
  }

  void _support(BuildContext context) {
    openOpenApiTelegram();
  }

  void _specialThanks(BuildContext context) {
    // Navigator.push(context, MaterialPageRoute<void>(builder: (BuildContext context) => const SpecialThanksScreen()));
    showLicensePage(context: context, applicationName: 'Open API Trader');
  }
}
