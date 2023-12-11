import 'dart:async';
import 'dart:collection';

import 'package:ctrader_example_app/logger.dart';
import 'package:ctrader_example_app/remote/proto.dart';
import 'package:ctrader_example_app/remote/remote_api.dart';
import 'package:ctrader_example_app/states/user_state.dart';
import 'package:get_it/get_it.dart';

abstract class ISubscriber {
  ISubscriber(this.completer);

  final Completer<void> completer;

  void finish() {
    try {
      completer.complete();
    } catch (err) {
      Logger.error('Error occurred at execution of subscriber', err);
    }
  }

  void finishWithError(Object error) {
    try {
      completer.completeError(error);
    } catch (err) {
      Logger.error('Error occurred at execution of subscriber with fail result', err);
    }
  }
}

class SpotSubscriber extends ISubscriber {
  SpotSubscriber(super.completer, this.traderId, this.symbols, this.subscribe);

  final int traderId;
  final List<int> symbols;
  final bool subscribe;
}

class BarSubscriber extends ISubscriber {
  BarSubscriber(super.completer, this.traderId, this.symbolId, this.period, this.subscribe);

  final int traderId;
  final int symbolId;
  final ProtoOATrendbarPeriod period;
  final bool subscribe;
}

class SubscribedSymbolBars {
  SubscribedSymbolBars(this.symbolid, this.period);

  final int symbolid;
  final ProtoOATrendbarPeriod period;
}

class SpotSubscriptionManager {
  SpotSubscriptionManager(RemoteApi api) : _remoteApi = api;

  final RemoteApi _remoteApi;
  final Set<int> _subscribedSymbols = <int>{};
  final Queue<SpotSubscriber> _queue = Queue<SpotSubscriber>();
  final List<SubscribedSymbolBars> _subscribedSymbolBars = <SubscribedSymbolBars>[];
  final Queue<BarSubscriber> _barsQueue = Queue<BarSubscriber>();
  bool _isWaiting = false;
  List<int> _cachedSubscribedSymbols = <int>[];
  List<SubscribedSymbolBars> _cachedSubscribedSymbolBars = <SubscribedSymbolBars>[];

  Iterable<int> get subscribedSymbols => _subscribedSymbols;

  bool isSymbolSubscribedForSpots(int symbolId) => _subscribedSymbols.contains(symbolId);
  bool isSymbolSubscribedForBars(int symbolId) => _subscribedSymbolBars.any((SubscribedSymbolBars sub) => sub.symbolid == symbolId);

  Future<void> subscribe(int traderId, List<int> symbols) {
    if (symbols.isEmpty) return Future<void>.value();

    final Completer<void> c = Completer<void>();
    _queue.add(SpotSubscriber(c, traderId, symbols, true));

    _nextSpotsActionAsync();

    return c.future;
  }

  Future<void> unsubscribe(int traderId, List<int> symbols) {
    if (symbols.isEmpty) return Future<void>.value();

    final Completer<void> c = Completer<void>();
    _queue.add(SpotSubscriber(c, traderId, symbols, false));

    _nextSpotsActionAsync();

    return c.future;
  }

  void cacheSubscribedSymbols() {
    _cachedSubscribedSymbols = _subscribedSymbols.toList();
    _subscribedSymbols.clear();

    _cachedSubscribedSymbolBars = _subscribedSymbolBars.toList();
    _subscribedSymbolBars.clear();
  }

  void _nextSpotsActionAsync() => Timer.run(() => _nextSpotsAction());
  void _nextSpotsAction() {
    if (_isWaiting) return;
    if (_queue.isEmpty) {
      _nextBarsAction();
      return;
    }

    _isWaiting = true;
    final SpotSubscriber subscriber = _queue.removeFirst();
    if (subscriber.subscribe) {
      final Iterable<int> symbols = subscriber.symbols.where((int symbol) => !_subscribedSymbols.contains(symbol));
      if (symbols.isEmpty) {
        subscriber.finish();
        _isWaiting = false;
        _nextSpotsActionAsync();
        return;
      }

      _subscribeForSpotsOnServer(subscriber.traderId, symbols.toList()).catchError((Object err) {
        subscriber.finishWithError(err);
      }).whenComplete(() {
        _isWaiting = false;
        _nextSpotsActionAsync();
        subscriber.finish();
      });
    } else {
      _remoteApi.unsubscribeFromSpots(subscriber.traderId, subscriber.symbols).then((ProtoOAUnsubscribeSpotsRes resp) {
        _subscribedSymbols.removeAll(subscriber.symbols);
        subscriber.finish();
      }, onError: (Object err) {
        subscriber.finishWithError(err);
      }).whenComplete(() {
        _isWaiting = false;
        _nextSpotsActionAsync();
      });
    }
  }

  Future<void> _subscribeForSpotsOnServer(int traderId, List<int> symbols) {
    if (symbols.isEmpty) return Future<void>.value();

    final Completer<void> completer = Completer<void>();

    _remoteApi.subscribeForSpots(traderId, symbols).then((ProtoOASubscribeSpotsRes resp) {
      _subscribedSymbols.addAll(symbols);
      completer.complete();
    }, onError: (Object err) async {
      if (err is ProtoOAErrorRes && err.errorCode == 'ALREADY_SUBSCRIBED') {
        if (symbols.length == 1) {
          _subscribedSymbols.add(symbols.first);
          completer.complete();
        } else {
          for (final int s in symbols) {
            try {
              await Future<void>.delayed(const Duration(milliseconds: 100));
              await _subscribeForSpotsOnServer(traderId, <int>[s]);

              _subscribedSymbols.add(s);
            } catch (err) {
              if (err is ProtoOAErrorRes && err.errorCode == 'ALREADY_SUBSCRIBED') {
                _subscribedSymbols.add(s);
              } else {
                Logger.error('Error occurred at subscribing for spots', err);
                completer.completeError(err);
                return;
              }
            }
          }

          completer.complete();
        }
      } else {
        completer.completeError(err);
      }
    });

    return completer.future;
  }

  void _nextBarsActionAsync() => Timer.run(_nextBarsAction);
  Future<void> _nextBarsAction() async {
    if (_isWaiting || _barsQueue.isEmpty) return;

    _isWaiting = true;
    final BarSubscriber subscriber = _barsQueue.removeFirst();
    if (subscriber.subscribe) {
      if (!_subscribedSymbols.contains(subscriber.symbolId)) {
        _barsQueue.addFirst(subscriber);
        _isWaiting = false;
        _nextSpotsActionAsync();
        return;
      }

      if (_subscribedSymbolBars
          .where((SubscribedSymbolBars element) => element.symbolid == subscriber.symbolId && element.period == subscriber.period)
          .isNotEmpty) {
        subscriber.finish();
      } else {
        try {
          await _remoteApi.subscribeForLiveTrendbars(subscriber.traderId, subscriber.symbolId, subscriber.period);
          _subscribedSymbolBars.add(SubscribedSymbolBars(subscriber.symbolId, subscriber.period));
          subscriber.finish();
        } catch (err) {
          if (err is ProtoOAErrorRes && err.errorCode == 'ALREADY_SUBSCRIBED') {
            _subscribedSymbolBars.add(SubscribedSymbolBars(subscriber.symbolId, subscriber.period));
            subscriber.finish();
          } else {
            subscriber.finishWithError(err);
          }
        }
      }
    } else {
      try {
        await _remoteApi.unsubscribeFromLiveTrendbars(subscriber.traderId, subscriber.symbolId, subscriber.period);
        _subscribedSymbolBars.removeWhere((SubscribedSymbolBars sub) => sub.symbolid == subscriber.symbolId && sub.period == subscriber.period);
        subscriber.finish();
      } catch (err) {
        Logger.error('Error occurred at subscribing for trend bars', err);
        subscriber.finishWithError(err);
      }
    }

    _isWaiting = false;
    _nextBarsActionAsync();
  }

  Future<void> _subscribeForLiveTrendBarsOnServer(int traderId, List<SubscribedSymbolBars> symbols) async {
    if (symbols.isEmpty) return Future<void>.value();

    for (int i = symbols.length - 1; i >= 0; i--) {
      final SubscribedSymbolBars data = symbols[i];
      try {
        await _remoteApi.subscribeForLiveTrendbars(traderId, data.symbolid, data.period);
      } on ProtoOAErrorRes catch (err) {
        if (err.errorCode != 'ALREADY_SUBSCRIBED') {
          Logger.log(() => 'Error occurred at subscriprtion to live trenbars of symbol(${data.symbolid}) for ${data.period.name}(${data.period.index})');
          _subscribedSymbolBars.remove(data);
        }
      } catch (err) {
        Logger.error(
          'Unhandeled error occurred at subscriprtion to live trenbars of symbol(${data.symbolid}) for ${data.period.name}(${data.period.index})',
          err,
        );
        _subscribedSymbolBars.remove(data);
      }
    }
  }

  Future<void> subscribeForTrendBars(int traderId, int symbolId, ProtoOATrendbarPeriod period) {
    final Completer<void> c = Completer<void>();
    _barsQueue.add(BarSubscriber(c, traderId, symbolId, period, true));
    _nextBarsActionAsync();
    return c.future;
  }

  Future<void> unsubscribeFromTrendBars(int traderId, int symbolId, ProtoOATrendbarPeriod period) {
    final Completer<void> c = Completer<void>();
    _barsQueue.add(BarSubscriber(c, traderId, symbolId, period, false));
    _nextBarsActionAsync();
    return c.future;
  }

  Future<void> restoreSubscriptions() async {
    final int traderId = GetIt.I<UserState>().selectedTraderId;
    await _subscribeForSpotsOnServer(traderId, _cachedSubscribedSymbols);
    await _subscribeForLiveTrendBarsOnServer(traderId, _cachedSubscribedSymbolBars);
  }
}
