import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:ctrader_example_app/logger.dart';
import 'package:ctrader_example_app/models/trader_data.dart';
import 'package:ctrader_example_app/remote/proto.dart';
import 'package:ctrader_example_app/states/app_state.dart';
import 'package:ctrader_example_app/states/user_state.dart';
import 'package:get_it/get_it.dart';

class RemoteAPIWaiter {
  RemoteAPIWaiter(this.timestamp, this.completer);

  int timestamp;
  Completer<ProtoMessage> completer;
}

const Duration requestTimeout = Duration(seconds: 15);

const List<Type> NON_LOGGABLE_TYPES = <Type>[
  // responses and events
  ProtoHeartbeatEvent,
  ProtoOASpotEvent,
  ProtoOAGetPositionUnrealizedPnLRes,

  // requests
  ProtoHeartbeatEvent,
  ProtoOAGetPositionUnrealizedPnLReq,
];

class RemoteApi {
  RemoteApi(this.url, this.isDemo) : logTag = 'Remote.${isDemo ? 'demo' : 'live'}' {
    subscribe<ProtoHeartbeatEvent>(_handleHeartBeatEvent);

    Timer.periodic(const Duration(seconds: 1), (_) => _checkWaitersForTimeout());
    Timer.periodic(const Duration(seconds: 28), (Timer timer) => _isAutorized ? _send(ProtoHeartbeatEvent()) : null);
  }

  final String url;
  final String logTag;
  final bool isDemo;
  bool shouldReconnect = false;

  final StringBuffer _receiveBuffer = StringBuffer();
  final Map<Type, List<Function>> _listeners = <Type, List<Function>>{};
  final Map<String, RemoteAPIWaiter> _waiters = <String, RemoteAPIWaiter>{};
  final Map<String, Queue<RemoteAPIWaiter>> _oneShotWaiters = <String, Queue<RemoteAPIWaiter>>{};
  final Set<int> _autorizedAccounts = <int>{};
  final Queue<Completer<void>> _appAutorizationWaiters = Queue<Completer<void>>();
  final Map<int, Queue<Completer<void>>> _accountAutorizationWaiters = <int, Queue<Completer<void>>>{};

  bool _isAutorized = false;
  SecureSocket? _socket;
  int _messageId = 0;

  bool get isConnected => _socket != null;
  bool get isAutorized => isConnected && _isAutorized;

  String _nextMsgId() => 'cmd_id_${(++_messageId).toRadixString(36)}';

  /// Returns messageId needed for query requests
  String _send(ProtoMessage message) {
    assert(isConnected, 'Socket connection is not initialized');

    final String messageId = _nextMsgId();
    final Map<String, dynamic> wrappedMessage = <String, dynamic>{
      'clientMsgId': messageId,
      'payloadType': message.payloadType,
      'payload': message.$payload(),
    };

    if (!NON_LOGGABLE_TYPES.contains(message.runtimeType)) {
      Logger.debug(() {
        final Map<String, dynamic> payload = message.$payload();
        if (message is ProtoOAApplicationAuthReq) {
          payload['clientId'] = '***';
          payload['clientSecret'] = '***';
        } else if (message is ProtoOAGetAccountListByAccessTokenReq || message is ProtoOAAccountAuthReq) {
          payload['accessToken'] = '***';
        }

        return '$logTag send > [${message.runtimeType.toString()}] {"clientMsgId": $messageId, "payloadType":${message.payloadType}, "payload":${jsonEncode(payload)}}';
      });
    }

    _socket!.add(utf8.encode(jsonEncode(wrappedMessage)));

    return messageId;
  }

  Future<T> _query<T extends ProtoMessage>(ProtoMessage message) {
    final Completer<T> completer = Completer<T>();
    final String id = _send(message);
    _waiters[id] = RemoteAPIWaiter(DateTime.now().millisecondsSinceEpoch, completer);
    return completer.future;
  }

  void _handleSocketMessage(List<int> data) {
    final dynamic json;

    _receiveBuffer.write(utf8.decode(data));
    try {
      json = jsonDecode(_receiveBuffer.toString());
      _receiveBuffer.clear();
    } catch (e) {
      return; // received data from socket is not fully readed, waiting for second part
    }

    final int payloadType = json['payloadType'] as int;
    final ProtoMessage Function()? constructor = messageFactory[payloadType];
    if (constructor != null) {
      final ProtoMessage message = constructor();
      final dynamic payload = json['payload'];
      if (payload != null) message.$parse(payload as Map<String, dynamic>?);
      if (json['clientMsgId'] != null) message.cmdId = json['clientMsgId'] as String;

      if (message is ProtoOAErrorRes) {
        Logger.log(() => '$logTag Server error ${jsonEncode(message.$payload())}');
      } else if (!NON_LOGGABLE_TYPES.contains(message.runtimeType)) {
        Logger.debug(() {
          if (message is ProtoOAGetAccountListByAccessTokenRes) {
            return '$logTag rcvd < [${message.runtimeType}] ${jsonEncode(json).replaceFirst(RegExp(r'"accessToken":\s*"[a-zA-Z0-9\-]*"'), '"accessToken": "***"')}';
          } else {
            return '$logTag rcvd < [${message.runtimeType}] ${jsonEncode(json)}';
          }
        });
      }

      _notifyListeners(message);
      _notifyOneShotWaiters(message);
      _notifyWaiters(message);
    } else {
      Logger.log(() => '$logTag unhandeled message: $payloadType\n${jsonEncode(json["payload"])}');
    }
  }

  void _handleHeartBeatEvent(ProtoHeartbeatEvent event) => _send(ProtoHeartbeatEvent());

  void _notifyListeners(ProtoMessage message) {
    if (!_listeners.containsKey(message.runtimeType)) return;

    for (final Function listener in _listeners[message.runtimeType]!) {
      try {
        listener(message);
      } catch (e) {
        Logger.error('$logTag error occurred in excecuting listener.', e, StackTrace.current);
      }
    }
  }

  void _notifyWaiters(ProtoMessage message) {
    if (message.cmdId == null || !_waiters.containsKey(message.cmdId)) return;

    final RemoteAPIWaiter waiter = _waiters[message.cmdId]!;
    try {
      if (message is ProtoOAErrorRes) {
        waiter.completer.completeError(message);
      } else {
        waiter.completer.complete(message);
      }
    } catch (e) {
      Logger.error('$logTag error occurred at executing waiter.', e);
    }

    _waiters.remove(message.cmdId);
  }

  void _notifyOneShotWaiters(ProtoMessage message) {
    if (message.cmdId == null || !_oneShotWaiters.containsKey(message.cmdId)) return;

    final Queue<RemoteAPIWaiter> waiters = _oneShotWaiters[message.cmdId]!;
    while (waiters.isNotEmpty) {
      final RemoteAPIWaiter waiter = waiters.removeFirst();
      try {
        if (message is ProtoOAErrorRes) {
          waiter.completer.completeError(message);
        } else {
          waiter.completer.complete(message);
        }
      } catch (e) {
        Logger.error('$logTag error occurred at executing oneshot waiter.', e);
      }
    }

    _oneShotWaiters.remove(waiters);
  }

  void _checkWaitersForTimeout() {
    if (!isConnected) return;

    final int extreamTimestamp = DateTime.now().millisecondsSinceEpoch - requestTimeout.inMilliseconds;

    final List<String> keys = _waiters.keys.toList();
    for (final String key in keys) {
      if (_waiters[key]!.timestamp < extreamTimestamp) {
        try {
          _waiters[key]!.completer.completeError('TIMEOUT');
        } catch (e) {
          Logger.error(logTag, e);
        }
        _waiters.remove(key);
      }
    }
  }

  void _cancelAllWaiters(String reason) {
    for (final String key in _waiters.keys) {
      try {
        _waiters[key]!.completer.completeError(reason);
      } catch (e) {
        Logger.error('$logTag error occurred at canceling waiter with error', e);
      }
    }
    _waiters.clear();

    for (final String cmdId in _oneShotWaiters.keys) {
      for (final RemoteAPIWaiter waiter in _oneShotWaiters[cmdId]!) {
        try {
          waiter.completer.completeError(reason);
        } catch (e) {
          Logger.error('$logTag error occurred at canceling oneshot waiter with error', e);
        }
      }
    }
    _oneShotWaiters.clear();

    for (final Completer<void> waiter in _appAutorizationWaiters) {
      try {
        waiter.completeError(reason);
      } catch (err) {
        Logger.error('$logTag error occurred at canceling app autorization waiter with error', err);
      }
    }
    _appAutorizationWaiters.clear();
  }

  Future<void> connect() async {
    try {
      Logger.log(() => 'connting to $url:5036');

      try {
        _socket = await SecureSocket.connect(
          url,
          5036,
          onBadCertificate: (X509Certificate certificate) => true,
          timeout: const Duration(seconds: 15),
          keyLog: (String line) => Logger.log(() => '$logTag $line'),
        );
      } catch (e) {
        Logger.error('Error occurred at connection process', e);
        rethrow;
      }

      Logger.log(() => '$logTag socket connected to $url(${_socket!.remoteAddress.host})');

      _socket!.listen(
        _handleSocketMessage,
        onDone: () {
          Logger.log(() => '$logTag socket closed on $url');

          _isAutorized = false;
          _autorizedAccounts.clear();
          _socket?.destroy();
          _socket = null;

          if (shouldReconnect) reconnect();
        },
        onError: (Object err) {
          Logger.error('$logTag unhandled socket error occurred', err);

          _isAutorized = false;
          _autorizedAccounts.clear();
          _socket?.destroy();
          _socket = null;

          if (shouldReconnect) reconnect();
        },
      );

      _socket!.handleError((Object err) => Logger.error('$logTag socket error', err));
    } catch (e) {
      Logger.error('$logTag Error occurred at connection process', e);
      rethrow;
    }

    try {
      await _autorizeApplication();
      _isAutorized = true;
    } catch (err) {
      Logger.error('$logTag Error occurred at aplication authenthification process', err);
      rethrow;
    }
  }

  Future<void> reconnect() async {
    Logger.log(() => '$logTag RECONNECTING');
    await connect();

    try {
      final Iterable<TraderData> traders = isDemo ? GetIt.I<UserState>().demoTraders : GetIt.I<UserState>().liveTraders;
      for (final TraderData account in traders) {
        await autorizeAccount(account.id);
        account.handleTraderResponse(await sendTraderReq(account.id));
        await sendReconcileReq(account.id);
      }
    } catch (err) {
      if (err != 'NO_ACCESS_TOKEN_FOUND') {
        Logger.error('Error occurred at account autorization', err);
        rethrow;
      }
    }
  }

  void disconnect() {
    _cancelAllWaiters('SOCKET_CLOSED');
    _autorizedAccounts.clear();

    shouldReconnect = false;
    _isAutorized = false;

    _socket?.destroy();
    _socket = null;
  }

  void subscribe<T>(void Function(T message) handler) {
    if (!_listeners.containsKey(T)) _listeners[T] = <Function>[];
    _listeners[T]!.add(handler);
  }

  void unsubscribe<T>(Function(T) handler) {
    _listeners[T]?.remove(handler);
  }

  Future<ProtoMessage> waitForResponse(String msgId) {
    if (!_oneShotWaiters.containsKey(msgId)) _oneShotWaiters[msgId] = Queue<RemoteAPIWaiter>();

    final RemoteAPIWaiter waiter = RemoteAPIWaiter(DateTime.now().millisecondsSinceEpoch, Completer<ProtoMessage>());
    _oneShotWaiters[msgId]!.add(waiter);

    return waiter.completer.future;
  }

  Future<void> whenAutorized() {
    if (_isAutorized) return Future<void>.value();

    final Completer<void> completer = Completer<void>();
    _appAutorizationWaiters.add(completer);

    return completer.future;
  }

  Future<void> whenAccountAutorized({required int accountId}) async {
    await whenAutorized();

    if (_autorizedAccounts.contains(accountId)) return Future<void>.value();

    final Completer<void> completer = Completer<void>();
    _accountAutorizationWaiters[accountId] ??= Queue<Completer<void>>();
    _accountAutorizationWaiters[accountId]!.add(completer);

    return completer.future;
  }

  // REQUEST NOT REQUIRING APPLICATION AUTORIZATION
  Future<ProtoOAApplicationAuthRes> _autorizeApplication() async {
    final AppState appState = GetIt.I<AppState>();

    final ProtoOAApplicationAuthRes resp = await _query<ProtoOAApplicationAuthRes>(ProtoOAApplicationAuthReq(appState.clientID, appState.clientSecret));

    while (_appAutorizationWaiters.isNotEmpty) _appAutorizationWaiters.removeFirst().complete();

    return resp;
  }

  // REQUEST REQUIRING APPLICATION AUTORIZATION
  Future<ProtoOAGetAccountListByAccessTokenRes> getAccountListByAccessTokenReq(String token) async {
    await whenAutorized();

    return _query<ProtoOAGetAccountListByAccessTokenRes>(ProtoOAGetAccountListByAccessTokenReq(token));
  }

  Future<ProtoOAAccountAuthRes> autorizeAccount(int accountId) async {
    await whenAutorized();

    final String? token = GetIt.I<UserState>().accountToken;
    if (token == null) return Future<ProtoOAAccountAuthRes>.error('NO_ACCESS_TOKEN_FOUND');

    final ProtoOAAccountAuthRes resp = await _query<ProtoOAAccountAuthRes>(ProtoOAAccountAuthReq(accountId, token));
    _autorizedAccounts.add(accountId);

    final Queue<Completer<void>>? waiters = _accountAutorizationWaiters[accountId];
    if (waiters != null) while (waiters.isNotEmpty) waiters.removeFirst().complete();
    _accountAutorizationWaiters.remove(accountId);

    return resp;
  }

  // REQUEST REQUIRING ACCOUNT AUTORIZATION
  Future<ProtoOAAccountLogoutRes> logoutAccount(int accountId) async {
    await whenAccountAutorized(accountId: accountId);

    return _query<ProtoOAAccountLogoutRes>(ProtoOAAccountLogoutReq(accountId));
  }

  Future<ProtoOATraderRes> sendTraderReq(int accountId) async {
    await whenAccountAutorized(accountId: accountId);

    return _query<ProtoOATraderRes>(ProtoOATraderReq(accountId));
  }

  Future<ProtoOAAssetListRes> sendAssetListReq(int accountId) async {
    await whenAccountAutorized(accountId: accountId);

    return _query<ProtoOAAssetListRes>(ProtoOAAssetListReq(accountId));
  }

  Future<ProtoOAAssetClassListRes> sendAssetClassListReq(int accountId) async {
    await whenAccountAutorized(accountId: accountId);

    return _query<ProtoOAAssetClassListRes>(ProtoOAAssetClassListReq(accountId));
  }

  Future<ProtoOASymbolsListRes> sendSymbolsListReq(int accountId) async {
    await whenAccountAutorized(accountId: accountId);

    return _query<ProtoOASymbolsListRes>(ProtoOASymbolsListReq(accountId));
  }

  Future<ProtoOASymbolCategoryListRes> sendSymbolCategoryListReq(int accountId) async {
    await whenAccountAutorized(accountId: accountId);

    return _query<ProtoOASymbolCategoryListRes>(ProtoOASymbolCategoryListReq(accountId));
  }

  Future<ProtoOAReconcileRes> sendReconcileReq(int accountId) async {
    await whenAccountAutorized(accountId: accountId);

    return _query<ProtoOAReconcileRes>(ProtoOAReconcileReq(accountId));
  }

  Future<ProtoOASymbolByIdRes> sendSymbolById(int accountId, List<int> symbolIds) async {
    await whenAccountAutorized(accountId: accountId);

    return _query<ProtoOASymbolByIdRes>(ProtoOASymbolByIdReq(accountId, symbolIds));
  }

  Future<ProtoOAGetDynamicLeverageByIDRes> sendLeverageById(int accountId, int leverageId) async {
    await whenAccountAutorized(accountId: accountId);

    return _query<ProtoOAGetDynamicLeverageByIDRes>(ProtoOAGetDynamicLeverageByIDReq(accountId, leverageId));
  }

  Future<ProtoOAGetTrendbarsRes> sendGetTrendbars(int accountId, int symbolId, int count, ProtoOATrendbarPeriod period, int fromTsMs, int toTsMs) async {
    await whenAccountAutorized(accountId: accountId);

    return _query<ProtoOAGetTrendbarsRes>(ProtoOAGetTrendbarsReq(accountId, fromTsMs, toTsMs, period, symbolId, count));
  }

  Future<ProtoOASubscribeSpotsRes> subscribeForSpots(int accountId, List<int> symbolsIds) async {
    await whenAccountAutorized(accountId: accountId);

    return _query<ProtoOASubscribeSpotsRes>(ProtoOASubscribeSpotsReq(accountId, symbolsIds));
  }

  Future<ProtoOAUnsubscribeSpotsRes> unsubscribeFromSpots(int accountId, List<int> symbolsIds) async {
    await whenAccountAutorized(accountId: accountId);

    return _query(ProtoOAUnsubscribeSpotsReq(accountId, symbolsIds));
  }

  Future<ProtoOASubscribeLiveTrendbarRes> subscribeForLiveTrendbars(int accountId, int symbolId, ProtoOATrendbarPeriod period) async {
    await whenAccountAutorized(accountId: accountId);

    return _query<ProtoOASubscribeLiveTrendbarRes>(ProtoOASubscribeLiveTrendbarReq(accountId, period, symbolId));
  }

  Future<ProtoOAUnsubscribeLiveTrendbarRes> unsubscribeFromLiveTrendbars(int accountId, int symbolId, ProtoOATrendbarPeriod period) async {
    await whenAccountAutorized(accountId: accountId);

    return _query<ProtoOAUnsubscribeLiveTrendbarRes>(ProtoOAUnsubscribeLiveTrendbarReq(accountId, period, symbolId));
  }

  Future<ProtoOAExpectedMarginRes> sendExpectedMargin(int accountId, int symbolId, List<int> volumes) async {
    await whenAccountAutorized(accountId: accountId);

    return _query<ProtoOAExpectedMarginRes>(ProtoOAExpectedMarginReq(accountId, symbolId, volumes));
  }

  Future<ProtoMessage> sendNewOrderForPosition(
    int accountId,
    int symbolId,
    bool isBuy,
    int volume, {
    int? takeProfit,
    int? stopLoss,
    bool? trailingStop,
    bool? guaranteedStopLoss,
  }) async {
    await whenAccountAutorized(accountId: accountId);

    final ProtoOANewOrderReq req = ProtoOANewOrderReq(
      accountId,
      symbolId,
      isBuy ? ProtoOATradeSide.buy : ProtoOATradeSide.sell,
      volume,
      orderType: ProtoOAOrderType.market,
      timeInForce: ProtoOATimeInForce.immediateOrCancel,
    );
    req.relativeTakeProfit = takeProfit;
    req.relativeStopLoss = stopLoss;
    req.trailingStopLoss = trailingStop == true ? true : null;
    req.guaranteedStopLoss = guaranteedStopLoss == true ? true : null;

    return _query(req);
  }

  Future<ProtoMessage> sendNewOrderForOrder(
    int accountId,
    int symbolId,
    bool isBuy,
    int volume,
    bool isLimit,
    double price, {
    int? takeProfit,
    int? stopLoss,
    bool? trailingStop,
    int? expirationTimestamp,
    bool? guaranteedStopLoss,
  }) async {
    await whenAccountAutorized(accountId: accountId);

    final ProtoOANewOrderReq req = ProtoOANewOrderReq(
      accountId,
      symbolId,
      isBuy ? ProtoOATradeSide.buy : ProtoOATradeSide.sell,
      volume,
      orderType: isLimit ? ProtoOAOrderType.limit : ProtoOAOrderType.stop,
      timeInForce: ProtoOATimeInForce.goodTillCancel,
    );

    if (isLimit) {
      req.limitPrice = price;
    } else {
      req.stopPrice = price;
    }

    req.relativeTakeProfit = takeProfit;
    req.relativeStopLoss = stopLoss;
    req.trailingStopLoss = trailingStop == true ? true : null;
    req.expirationTimestamp = expirationTimestamp;
    req.guaranteedStopLoss = guaranteedStopLoss == true ? true : null;

    return _query(req);
  }

  Future<ProtoOAGetPositionUnrealizedPnLRes> sendGetPositionsPnl(int accountId) async {
    await whenAccountAutorized(accountId: accountId);

    return _query<ProtoOAGetPositionUnrealizedPnLRes>(ProtoOAGetPositionUnrealizedPnLReq(accountId));
  }

  Future<ProtoMessage> sendClosePosition(int accountId, int positionId, int volume) async {
    await whenAccountAutorized(accountId: accountId);

    return _query(ProtoOAClosePositionReq(accountId, positionId, volume));
  }

  Future<ProtoMessage> sendCancelOrder(int accountId, int orderId) async {
    await whenAccountAutorized(accountId: accountId);

    return _query(ProtoOACancelOrderReq(accountId, orderId));
  }

  Future<ProtoMessage> sendEditPosition(
    int accountId,
    int positionId, {
    double? stopLoss,
    double? takeProfit,
    bool? trailingStop,
    bool? guaranteedStopLoss,
  }) async {
    await whenAccountAutorized(accountId: accountId);

    return _query(ProtoOAAmendPositionSLTPReq(accountId, positionId)
      ..takeProfit = (takeProfit ?? 0) > 0 ? takeProfit : null
      ..stopLoss = (stopLoss ?? 0) > 0 ? stopLoss : null
      ..trailingStopLoss = trailingStop == true ? true : null
      ..guaranteedStopLoss = guaranteedStopLoss == true ? true : null);
  }

  Future<ProtoMessage> sendEditOrder(
    int accountId,
    int orderId,
    int volume,
    double price,
    bool isLimit, {
    int? relativeTP,
    int? relativeSL,
    bool? trailingStop,
    int? expireAtTs,
    bool? guaranteedStopLoss,
  }) async {
    await whenAccountAutorized(accountId: accountId);

    final ProtoOAAmendOrderReq req = ProtoOAAmendOrderReq(accountId, orderId, volume)
      ..limitPrice = isLimit ? price : null
      ..stopPrice = isLimit ? null : price
      ..expirationTimestamp = (expireAtTs ?? 0) > 0 ? expireAtTs : null
      ..relativeTakeProfit = (relativeTP ?? 0) > 0 ? relativeTP : null
      ..relativeStopLoss = (relativeSL ?? 0) > 0 ? relativeSL : null
      ..trailingStopLoss = trailingStop == true ? true : null
      ..guaranteedStopLoss = guaranteedStopLoss == true ? true : null;

    return _query(req);
  }

  Future<ProtoOADealListRes> sendDealList(int accountId, int fromTsSec, int toTsSec) async {
    await whenAccountAutorized(accountId: accountId);

    return _query<ProtoOADealListRes>(ProtoOADealListReq(accountId, fromTsSec, toTsSec));
  }

  Future<ProtoOADealOffsetListRes> sendDealOffsetList(int accountId, int dealId) async {
    await whenAccountAutorized(accountId: accountId);

    return _query<ProtoOADealOffsetListRes>(ProtoOADealOffsetListReq(accountId, dealId));
  }

  Future<ProtoOASymbolsForConversionRes> sendSymbolsForConversion(int accountId, int firstAssetId, int lastAssetId) {
    return _query(ProtoOASymbolsForConversionReq(accountId, firstAssetId, lastAssetId));
  }
}
