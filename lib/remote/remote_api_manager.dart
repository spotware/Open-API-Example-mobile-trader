import 'dart:async';

import 'package:ctrader_example_app/logger.dart';
import 'package:ctrader_example_app/main.dart';
import 'package:ctrader_example_app/models/trader_data.dart';
import 'package:ctrader_example_app/remote/remote_api.dart';
import 'package:ctrader_example_app/remote/spot_sub_manager.dart';
import 'package:ctrader_example_app/states/app_state.dart';
import 'package:ctrader_example_app/states/user_state.dart';
import 'package:get_it/get_it.dart';

class RemoteAPIManager {
  RemoteAPIManager() {
    final AppState appState = GetIt.I<AppState>();
    _demo = RemoteApi(appState.socketDemoURL, true);
    _demoSpotSubMngr = SpotSubscriptionManager(_demo);

    _live = RemoteApi(appState.socketLiveURL, false);
    _liveSpotSubMngr = SpotSubscriptionManager(_live);
  }

  late final RemoteApi _demo;
  late final RemoteApi _live;
  late final SpotSubscriptionManager _demoSpotSubMngr;
  late final SpotSubscriptionManager _liveSpotSubMngr;

  Timer? _pnlRequestTimer;

  Future<void> connect() async {
    if (!ONLY_DEMO) await _live.connect();
    await _demo.connect();
  }

  void onAppPaused() {
    _demo.disconnect();
    _live.disconnect();

    _pnlRequestTimer?.cancel();
  }

  Future<void> onAppResumed() async {
    _liveSpotSubMngr.cacheSubscribedSymbols();
    _demoSpotSubMngr.cacheSubscribedSymbols();

    if (!ONLY_DEMO) await _live.reconnect();
    await _demo.reconnect();

    if (!ONLY_DEMO) await _liveSpotSubMngr.restoreSubscriptions();
    await _demoSpotSubMngr.restoreSubscriptions();

    startPnlUpdateTimer();
  }

  RemoteApi getAPI({required bool demo}) {
    return demo ? _demo : _live;
  }

  SpotSubscriptionManager getSpotSubscriptionManager({required bool demo}) {
    return demo ? _demoSpotSubMngr : _liveSpotSubMngr;
  }

  void subscribe<T>(void Function(T) handler) {
    if (!ONLY_DEMO) _live.subscribe<T>(handler);
    _demo.subscribe<T>(handler);
  }

  void unsubscribe<T>(void Function(T) handler) {
    _live.unsubscribe<T>(handler);
    _demo.unsubscribe<T>(handler);
  }

  void startPnlUpdateTimer() {
    if (_pnlRequestTimer?.isActive == true) return;

    _pnlRequestTimer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      final UserState userState = GetIt.I<UserState>();
      if (!userState.isTraderSelected) return;

      try {
        final TraderData trader = userState.selectedTrader;
        final RemoteApi remoteAPI = trader.demo ? _demo : _live;
        if (remoteAPI.isAutorized) remoteAPI.sendGetPositionsPnl(trader.id);
      } catch (err) {
        Logger.error('Error occurred at pnl request by timer', err);
      }
    });
  }
}
