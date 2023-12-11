import 'dart:async';
import 'dart:convert';

import 'package:ctrader_example_app/l10n/localizations.dart';
import 'package:ctrader_example_app/logger.dart';
import 'package:ctrader_example_app/main.dart';
import 'package:ctrader_example_app/models/trader_data.dart';
import 'package:ctrader_example_app/popups/popup.dart';
import 'package:ctrader_example_app/popups/popup_manager.dart';
import 'package:ctrader_example_app/remote/proto.dart' as proto;
import 'package:ctrader_example_app/remote/remote_api.dart';
import 'package:ctrader_example_app/remote/remote_api_manager.dart';
import 'package:ctrader_example_app/screens/login_webview.dart';
import 'package:ctrader_example_app/screens/market_screen.dart';
import 'package:ctrader_example_app/states/app_state.dart';
import 'package:ctrader_example_app/states/user_state.dart';
import 'package:ctrader_example_app/utils.dart';
import 'package:ctrader_example_app/widgets/block_login_ui.dart';
import 'package:ctrader_example_app/widgets/button_primary.dart';
import 'package:ctrader_example_app/widgets/login_bottom_banner.dart';
import 'package:ctrader_example_app/widgets/side_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const String ROUTE_NAME = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isBlocked = false;
  String _blockUiLabel = 'Wait please';

  @override
  void initState() {
    super.initState();

    if (!GetIt.I<UserState>().isLogining && GetIt.I<UserState>().atJSONString != null) {
      Timer.run(_onClickLoginButton);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Scaffold(
      drawer: const SideMenu(),
      backgroundColor: THEME_LOGIN.background,
      body: Stack(
        children: <Widget>[
          SafeArea(
            child: LoginBottomBanner.wrap(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    const SizedBox(height: 40),
                    SvgPicture.asset('assets/svg/login_logo.svg'),
                    const SizedBox(height: 36),
                    Text(l10n.loginSignInLable, style: THEME_LOGIN.texts.headingStrong, textAlign: TextAlign.center),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ButtonPrimary(label: l10n.loginSignInButton, onTap: _onClickLoginButton),
                    ),
                    const SizedBox(height: 26),
                    Text(l10n.dontHaveAnAccoutnYet, style: THEME_LOGIN.texts.headingStrong),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        l10n.chooseBrokerFromFeaturesList,
                        style: THEME_LOGIN.texts.headingSmall,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    _renderBroker(context, l10n.continueWithBroker('IC Markets'), 'ic_markets', 'https://www.icmarkets.com/open-new-live-account/?camp=3263'),
                    _renderBroker(
                        context, l10n.continueWithBroker('Pepperstone'), 'pepperstone', 'https://track.pepperstonepartners.com/visit/?bta=35600&nci=5399'),
                    _renderBroker(context, l10n.continueWithBroker('TopFx'), 'top_fx',
                        'https://signup.topfx.com.sc/Registration/Main/Account?dest=live&isSpecAts=true&camp=7087'),
                    _renderBroker(context, l10n.continueWithBroker('FxPro'), 'fx_pro', 'https://direct.fxpro.com.cy/partner/8033201'),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
          if (_isBlocked) Positioned.fill(child: BlockLoginUI(label: _blockUiLabel)),
        ],
      ),
    );
  }

  Widget _renderBroker(BuildContext context, String broker, String icon, String link) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: GestureDetector(
        onTap: () => openUrlInBrowser(link),
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(2),
            border: Border.all(color: THEME_LOGIN.brokerBorder),
          ),
          child: Row(
            children: <Widget>[
              Text(broker, style: THEME_LOGIN.texts.brokerButton),
              const Spacer(),
              Image.asset('assets/png/broker_$icon.png', height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onClickLoginButton() async {
    final AppState appState = GetIt.I<AppState>();
    final UserState userState = GetIt.I<UserState>();
    final RemoteAPIManager remoteApiMngr = GetIt.I<RemoteAPIManager>();

    userState.isLogining = true;
    _blockUiLabel = AppLocalizations.of(context)!.waitPlease;
    try {
      String? at = userState.atJSONString;
      if (at == null) {
        final String? authCode = await Navigator.pushNamed(context, LoginWebView.ROUTE_NAME);
        if (authCode == null || authCode.isEmpty) return;

        setState(() => _isBlocked = true);

        final Map<String, String> params = <String, String>{
          'code': authCode,
          'grant_type': 'authorization_code',
          'redirect_uri': 'https://login.confirm',
          'client_id': appState.clientID,
          'client_secret': appState.clientSecret,
        };
        final Uri url = Uri.http(appState.remoteURL, '/apps/token', params);
        final Response tokenResp = await get(url);
        if (tokenResp.statusCode != 200) return Logger.error(tokenResp.body);
        final Map<String, dynamic> jsonResp = jsonDecode(tokenResp.body) as Map<String, dynamic>;
        if (jsonResp['errorCode'] != null) {
          GetIt.I<PopupManager>().showError(AppLocalizations.of(context)!, '${jsonResp['errorCode']} ${jsonResp['description']}');
          setState(() => _isBlocked = false);
          return;
        }
        at = tokenResp.body;
        userState.cacheATJSONString(at);
      } else {
        setState(() => _isBlocked = true);
      }

      Map<String, dynamic> jsonAT = jsonDecode(at) as Map<String, dynamic>;
      final RemoteApi demoAPI = remoteApiMngr.getAPI(demo: true);
      final RemoteApi liveAPI = remoteApiMngr.getAPI(demo: false);
      proto.ProtoOAGetAccountListByAccessTokenRes accountsResp;

      int counter = 0;
      while (!demoAPI.isAutorized && counter < 60) {
        counter++;
        await Future<void>.delayed(const Duration(milliseconds: 250));
      }

      if (!demoAPI.isAutorized) {
        final AppLocalizations l10n = AppLocalizations.of(context)!;
        GetIt.I<PopupManager>().showPopup(title: l10n.errorOccurred, message: l10n.someErrorOccuredTryLater);
        setState(() => _isBlocked = false);
        return;
      }

      try {
        accountsResp = await demoAPI.getAccountListByAccessTokenReq(jsonAT['accessToken'] as String);
        userState.cacheAccountToken(accountsResp.accessToken);
      } catch (e) {
        if (e is proto.ProtoOAErrorRes && e.errorCode == 'CH_ACCESS_TOKEN_INVALID') {
          // need to get new token by refreshToken

          final Map<String, String> params = <String, String>{
            'refresh_token': jsonAT['refreshToken'] as String,
            'grant_type': 'refresh_token',
            'redirect_uri': 'https://login.confirm',
            'client_id': appState.clientID,
            'client_secret': appState.clientSecret,
          };
          final Uri url = Uri.http(appState.remoteURL, '/apps/token', params);
          final Response tokenResp = await get(url);
          if (tokenResp.statusCode != 200) return;
          at = tokenResp.body;
          jsonAT = jsonDecode(at) as Map<String, dynamic>;
          if (jsonAT['errorCode'] != null) {
            userState.cacheATJSONString(null);
            setState(() => _isBlocked = false);
            return;
          }

          userState.cacheATJSONString(at);

          accountsResp = await demoAPI.getAccountListByAccessTokenReq(jsonAT['accessToken'] as String);
          userState.cacheAccountToken(accountsResp.accessToken);
        } else {
          rethrow;
        }
      }

      for (final proto.ProtoOACtidTraderAccount traderAcc in accountsResp.ctidTraderAccount) {
        if (ONLY_DEMO && traderAcc.isLive == true) continue;

        setState(() => _blockUiLabel = AppLocalizations.of(context)!.loadingDataForAcc(traderAcc.traderLogin ?? 0));
        final RemoteApi traderRemoteAPI = traderAcc.isLive == true ? liveAPI : demoAPI;
        try {
          await traderRemoteAPI.autorizeAccount(traderAcc.ctidTraderAccountId);
        } catch (e) {
          userState.addBlockedAccount(traderAcc);
          if (e is proto.ProtoOAErrorRes) {
            Logger.log(() => jsonEncode(e.$payload()).toString());
          } else {
            Logger.error('Error occurred at trader account authenthification', e);
          }
          continue;
        }

        final proto.ProtoOATraderRes traderResp = await traderRemoteAPI.sendTraderReq(traderAcc.ctidTraderAccountId);

        userState.addTrader(traderAcc.isLive == true, traderResp.trader);

        final TraderData trader = userState.trader(traderAcc.ctidTraderAccountId)!;
        trader.name = traderAcc.brokerTitleShort;

        final proto.ProtoOAAssetListRes assetsResp = await traderRemoteAPI.sendAssetListReq(trader.id);
        trader.tree.handleAssetsResponse(assetsResp.asset);

        final proto.ProtoOAAssetClassListRes assetClassResp = await traderRemoteAPI.sendAssetClassListReq(trader.id);
        trader.tree.handleAssetClassResponse(assetClassResp.assetClass);

        final proto.ProtoOASymbolCategoryListRes symbolCategoryResp = await traderRemoteAPI.sendSymbolCategoryListReq(trader.id);
        trader.tree.handleSymbolCategoryResponse(symbolCategoryResp.symbolCategory);

        final proto.ProtoOASymbolsListRes symbolsResp = await traderRemoteAPI.sendSymbolsListReq(trader.id);
        trader.tree.handleSymbolsResponse(symbolsResp.symbol);

        await traderRemoteAPI.sendReconcileReq(trader.id);

        userState.restoreTraderFavorites(trader.id);
        userState.restoreCollapsedCategories(trader.id);
      }

      if (userState.traders.isEmpty && ONLY_DEMO) {
        setState(() => _isBlocked = false);
        final AppLocalizations l10n = AppLocalizations.of(context)!;
        await GetIt.I<PopupManager>().showPopup(title: l10n.demoAccountRequired, message: l10n.loginWithDemoAccount);
        logout(context);
        return;
      } else if (userState.traders.isEmpty && userState.hasBlockedAccounts) {
        final AppLocalizations l10n = AppLocalizations.of(context)!;
        setState(() => _isBlocked = false);
        GetIt.I<PopupManager>().showPopup(title: l10n.noAccess, message: l10n.noAccessToTradingContactBroker);
        throw 'NO_ACCESS';
      } else if (userState.traders.isEmpty) {
        setState(() => _isBlocked = false);
        GetIt.I<PopupManager>().showSomeErrorOccurred(AppLocalizations.of(context)!);
        return;
      }

      final int? selectedTraderId = await userState.restoreSelectedTrader();
      TraderData? trader = userState.trader(selectedTraderId ?? -1);
      if (trader == null) {
        final List<TraderData> traders = userState.traders.toList();
        traders.sort((TraderData a, TraderData b) {
          if (a.accountType == proto.ProtoOAAccountType.spreadBetting) {
            return -1;
          } else if (b.accountType == proto.ProtoOAAccountType.spreadBetting) {
            return 1;
          } else if (a.accessRights != b.accessRights) {
            return b.accessRights.index - a.accessRights.index;
          } else if (a.accountType != b.accountType) {
            return b.accountType.index - a.accountType.index;
          } else {
            return a.login - b.login;
          }
        });
        trader = traders.last;
      }

      setState(() => _isBlocked = false);

      if (!appState.moreAccountsWarnPopupShowed && (userState.traders.length > 1 || trader.accessRights != proto.ProtoOAAccessRights.fullAccess)) {
        appState.setMoreAccountsWarnPopupShowed();
        await GetIt.I<PopupManager>().showTraderSelection(AppLocalizations.of(context)!, trader, userState.traders.length > 1);
      }

      if (trader.accountType == proto.ProtoOAAccountType.spreadBetting) {
        final PopupResult result = await GetIt.I<PopupManager>().showTraderSelection(AppLocalizations.of(context)!, trader, false);
        if (result.agree) {
          openUrlInBrowser('https://www.spotware.com/featured-ctrader-brokers');
        }
      } else if (trader.accessRights != proto.ProtoOAAccessRights.noLogin) {
        userState.selectTrader(trader.id);
        remoteApiMngr.startPnlUpdateTimer();
        Navigator.pushReplacementNamed(context, MarketScreen.ROUTE_NAME);
      }
    } catch (err) {
      if (err is proto.ProtoOAErrorRes) {
        Logger.log(() => 'Server error: #${err.errorCode}: ${err.description}');
      } else {
        Logger.error('Unhandled error occurred at login process', err);
      }

      userState.onLogedOut();
      if (err != 'SOCKET_CLOSED' && err != 'NO_ACCESS') GetIt.I<PopupManager>().showSomeErrorOccurred(AppLocalizations.of(context)!);
    }

    setState(() => _isBlocked = false);
  }
}
