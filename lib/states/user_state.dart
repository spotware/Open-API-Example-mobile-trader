import 'dart:convert';
import 'dart:math';

import 'package:ctrader_example_app/models/order_data.dart';
import 'package:ctrader_example_app/models/position_data.dart';
import 'package:ctrader_example_app/models/symbol_data.dart';
import 'package:ctrader_example_app/models/trader_data.dart';
import 'package:ctrader_example_app/models/trailing_stop_values.dart';
import 'package:ctrader_example_app/remote/proto.dart' as proto;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum UserStatePrefKeys { dontShowReversOrderPopup, dontShowSimulTradingOpenPopup, dontShowSimulTradingEdfitPopup, trailingStopValues }

class UserState extends ChangeNotifier {
  final FlutterSecureStorage _secure = const FlutterSecureStorage();

  Future<void> init() async {
    _at = await _secure.read(
      key: 'secure_at',
      aOptions: const AndroidOptions(encryptedSharedPreferences: true),
      iOptions: IOSOptions.defaultOptions,
    );
    _restoreBlockedAccountsState();
    _resotreState();

    _trailingStopValues.addListener(() => _saveState());
  }

  Future<void> _saveState() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(UserStatePrefKeys.dontShowReversOrderPopup.toString(), _dontShowReversOrderPopup);
    prefs.setBool(UserStatePrefKeys.dontShowSimulTradingOpenPopup.toString(), _dontShowSimulTradingOpenPopup);
    prefs.setBool(UserStatePrefKeys.dontShowSimulTradingEdfitPopup.toString(), _dontShowSimulTradingEditPopup);
    prefs.setString(UserStatePrefKeys.trailingStopValues.toString(), jsonEncode(_trailingStopValues));
  }

  Future<void> _resotreState() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _dontShowReversOrderPopup = prefs.getBool(UserStatePrefKeys.dontShowReversOrderPopup.toString()) == true;
    _dontShowSimulTradingOpenPopup = prefs.getBool(UserStatePrefKeys.dontShowSimulTradingOpenPopup.toString()) == true;
    _dontShowSimulTradingEditPopup = prefs.getBool(UserStatePrefKeys.dontShowSimulTradingEdfitPopup.toString()) == true;
    if (prefs.containsKey(UserStatePrefKeys.trailingStopValues.toString())) {
      final String json = prefs.getString(UserStatePrefKeys.trailingStopValues.toString())!;
      _trailingStopValues.fromJSON(jsonDecode(json) as Map<String, dynamic>);
    }
  }

  String? _at;
  String? get atJSONString => _at;
  Future<void> cacheATJSONString(String? json) async {
    _at = json;

    if (json == null) {
      await _secure.delete(
        key: 'secure_at',
        aOptions: const AndroidOptions(encryptedSharedPreferences: true),
        iOptions: IOSOptions.defaultOptions,
      );
    } else {
      await _secure.write(
        key: 'secure_at',
        value: json,
        aOptions: const AndroidOptions(encryptedSharedPreferences: true),
        iOptions: IOSOptions.defaultOptions,
      );
    }
  }

  String? _accToken;
  String? get accountToken => _accToken;
  void cacheAccountToken(String token) {
    _accToken = token;
  }

  bool isLogining = false;

  bool _dontShowReversOrderPopup = false;
  bool get dontShowReversOrderPopup => _dontShowReversOrderPopup;
  void setDontShowReversOrderPopup() {
    _dontShowReversOrderPopup = true;

    _saveState();
    notifyListeners();
  }

  bool _dontShowSimulTradingOpenPopup = false;
  bool get dontShowSimultaneousTradingPopupForNew => _dontShowSimulTradingOpenPopup;
  void setDontShowSimultaneousTradingPopupForNew() {
    _dontShowSimulTradingOpenPopup = true;
    _saveState();

    notifyListeners();
  }

  bool _dontShowSimulTradingEditPopup = false;
  bool get dontShowSimultaneousTradingPopupForEdit => _dontShowSimulTradingEditPopup;
  void setDontShowSimultaneousTradingPopupForEdit() {
    _dontShowSimulTradingEditPopup = true;
    _saveState();

    notifyListeners();
  }

  int _marketCategoryId = -999;
  int _marketSymbolId = -999;
  int get marketCategoryId => _marketCategoryId;
  int get marketSymbolId => _marketSymbolId;
  void setMarketSelects(int categoryId, int symbolId) {
    _marketCategoryId = categoryId;
    _marketSymbolId = symbolId;
  }

  final Map<int, TraderData> _traders = <int, TraderData>{};
  Iterable<TraderData> get traders => _traders.values;
  Iterable<TraderData> get demoTraders => _traders.values.where((TraderData trader) => trader.demo);
  Iterable<TraderData> get liveTraders => _traders.values.where((TraderData trader) => !trader.demo);
  TraderData? trader(int id) => _traders[id];
  void addTrader(bool isLive, proto.ProtoOATrader trader) {
    _traders[trader.ctidTraderAccountId] = TraderData.parseResponse(!isLive, trader);
    notifyListeners();
  }

  int _selectedTrader = -1;
  int get selectedTraderId => _selectedTrader;
  bool get isTraderSelected => _selectedTrader > 0;
  TraderData get selectedTrader => _traders[_selectedTrader]!;
  void selectTrader(int? traderId) {
    traderId ??= _traders.keys.fold(0, (int? previousValue, int element) => max(previousValue ?? 0, element));

    if (_traders.containsKey(traderId)) {
      _selectedTrader = traderId!;
      _marketCategoryId = -999;
      _marketSymbolId = -999;

      _saveSelectedTrader();
      notifyListeners();
    }
  }

  final List<proto.ProtoOACtidTraderAccount> _blockedAccounts = <proto.ProtoOACtidTraderAccount>[];
  bool get hasBlockedAccounts => _blockedAccounts.isNotEmpty;
  Iterable<proto.ProtoOACtidTraderAccount> get blockedAccounts => _blockedAccounts;
  void addBlockedAccount(proto.ProtoOACtidTraderAccount acc) {
    _blockedAccounts.add(acc);
  }

  bool _blockedAccountsWarningPopup = false;
  bool get blockedAccountsWarningPopup => _blockedAccountsWarningPopup;
  void setBlockedAccountsWarningPopup() {
    _blockedAccountsWarningPopup = true;
    _saveBlockedAccountsState();
  }

  final TrailingStopValues _trailingStopValues = TrailingStopValues();
  TrailingStopValues get trailingStopValues => _trailingStopValues;

  Future<void> _saveBlockedAccountsState() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('blockedAccountsWarningPopup', _blockedAccountsWarningPopup);
  }

  Future<void> _restoreBlockedAccountsState() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _blockedAccountsWarningPopup = prefs.getBool('blockedAccountsWarningPopup') == true;
  }

  Future<void> onLogedOut() async {
    await cacheATJSONString(null);

    _selectedTrader = -1;
    _traders.clear();
    _blockedAccounts.clear();

    await _saveSelectedTrader();
  }

  void addTraderPosition(int traderId, PositionData position) {
    if (_traders.containsKey(traderId)) {
      _traders[traderId]!.addPosition(position);
      notifyListeners();
    }
  }

  void handleSpotEvent(proto.ProtoOASpotEvent event) {
    trader(event.ctidTraderAccountId)?.tree.symbol(event.symbolId)?.handleSpotEvent(event);
    notifyListeners();
  }

  void handlePnlEvent(proto.ProtoOAGetPositionUnrealizedPnLRes event) {
    bool hasUpdates = false;
    final TraderData? trader = this.trader(event.ctidTraderAccountId);
    if (trader == null) return;

    for (final proto.ProtoOAPositionUnrealizedPnL p in event.positionUnrealizedPnL) {
      final PositionData? position = trader.positionsManager.activityBy(id: p.positionId);
      if (position != null && position.updatePnl(p.grossUnrealizedPnL, p.netUnrealizedPnL)) {
        hasUpdates = true;
        trader.positionsManager.dispatchActivityUpdatedEvent(position);
      }
    }

    if (hasUpdates) {
      trader.recalculateFields();
      notifyListeners();
    }
  }

  void handleSymbolDetailsResponse(proto.ProtoOASymbolByIdRes resp) {
    final TraderData? trader = this.trader(resp.ctidTraderAccountId);
    if (trader == null) return;

    for (final proto.ProtoOASymbol s in resp.symbol) {
      final SymbolData? symbol = trader.tree.symbol(s.symbolId);
      symbol?.details = SymbolDetailsData(symbol, s);
    }

    notifyListeners();
  }

  void handleExecutionEvent(proto.ProtoOAExecutionEvent event) {
    final TraderData? trader = this.trader(event.ctidTraderAccountId);
    if (trader == null) return;

    final bool isMarket = event.order?.orderType == proto.ProtoOAOrderType.market;
    final bool isSLTP = event.order?.orderType == proto.ProtoOAOrderType.stopLossTakeProfit;
    final bool isOrder = event.order?.orderType == proto.ProtoOAOrderType.limit || event.order?.orderType == proto.ProtoOAOrderType.stop;

    if (event.executionType == proto.ProtoOAExecutionType.depositWithdraw) {
      _handleDepositWithdrawEvent(trader, event);
    } else if (event.executionType == proto.ProtoOAExecutionType.bonusDepositWithdraw) {
      _handleBonusDepositWithdrawEvent(trader, event);
    } else if (isSLTP) {
      _handleSLTPExecutionEvent(trader, event);
    } else if (isMarket) {
      _handleMarketExecutionEvent(trader, event);
    } else if (isOrder &&
        (event.executionType == proto.ProtoOAExecutionType.orderFilled || event.executionType == proto.ProtoOAExecutionType.orderPartialFill)) {
      _handlePendingOrderExecuteEvent(trader, event);
    } else if (isOrder) {
      _handleOrderExecutionEvent(trader, event);
    }

    notifyListeners();
  }

  void handleReconcileResponse(proto.ProtoOAReconcileRes message) {
    trader(message.ctidTraderAccountId)?.handleReconcileResponse(message);

    notifyListeners();
  }

  Future<void> handleSymbolChangedEvent(proto.ProtoOASymbolChangedEvent event) async {
    final TraderData? trader = this.trader(event.ctidTraderAccountId);
    if (trader == null) return;

    for (final int id in event.symbolId) {
      final SymbolData? symbol = trader.tree.symbol(id);
      if (symbol != null && symbol.details != null) {
        symbol.details = null;
        await symbol.getDetailsData();
      }
    }

    notifyListeners();
  }

  void handleTraderUpdatedEvent(proto.ProtoOATraderUpdatedEvent event) {
    trader(event.ctidTraderAccountId)?.handleTraderUpdateEvent(event.trader);

    notifyListeners();
  }

  void handleMarginChangedEvent(proto.ProtoOAMarginChangedEvent event) {
    trader(event.ctidTraderAccountId)?.handleMarginChangedEvent(event);

    notifyListeners();
  }

  void _handleDepositWithdrawEvent(TraderData trader, proto.ProtoOAExecutionEvent event) {
    final proto.ProtoOADepositWithdraw oaDepositWithdraw = event.depositWithdraw!;
    if (trader.updateBalance(oaDepositWithdraw.balanceVersion ?? 0, oaDepositWithdraw.balance)) notifyListeners();
  }

  void _handleBonusDepositWithdrawEvent(TraderData trader, proto.ProtoOAExecutionEvent event) {
    final proto.ProtoOABonusDepositWithdraw oaBonusDepositWithdraw = event.bonusDepositWithdraw!;
    trader.updateBonuses(oaBonusDepositWithdraw.ibBonus, oaBonusDepositWithdraw.managerBonus);
    notifyListeners();
  }

  void _handleMarketExecutionEvent(TraderData trader, proto.ProtoOAExecutionEvent event) {
    final proto.ProtoOAOrder oaOrder = event.order!;
    final proto.ProtoOAPosition oaPosition = event.position!;
    final bool isPartial = event.executionType == proto.ProtoOAExecutionType.orderPartialFill;

    if (event.executionType == proto.ProtoOAExecutionType.orderAccepted || event.executionType == proto.ProtoOAExecutionType.orderCancelled) {
      return;
    } else if (oaOrder.isStopOut == true) {
      if (oaPosition.tradeData.volume == 0) {
        trader.removePosition(oaPosition.positionId, event.deal?.closePositionDetail);
      } else {
        trader.updatePosition(oaPosition);
      }
    } else if (oaOrder.closingOrder == true) {
      trader.removePosition(oaPosition.positionId, event.deal?.closePositionDetail);
    } else if (event.executionType == proto.ProtoOAExecutionType.orderFilled || event.executionType == proto.ProtoOAExecutionType.orderPartialFill) {
      if (trader.accountType == proto.ProtoOAAccountType.hedged) {
        trader.addPosition(PositionData.parseResponse(trader, oaPosition));
      } else if (oaPosition.tradeData.volume == 0 && !isPartial) {
        trader.removePosition(oaPosition.positionId, event.deal?.closePositionDetail);
      } else if (oaOrder.executedVolume == oaPosition.tradeData.volume && oaOrder.tradeData.tradeSide == oaPosition.tradeData.tradeSide) {
        trader.addPosition(PositionData.parseResponse(trader, oaPosition));
      } else {
        trader.updatePosition(oaPosition);
      }
    }
  }

  void _handleSLTPExecutionEvent(TraderData trader, proto.ProtoOAExecutionEvent event) {
    final proto.ProtoOAPosition oaPosition = event.position!;

    if (oaPosition.tradeData.volume == 0) {
      trader.removePosition(oaPosition.positionId, event.deal?.closePositionDetail);
    } else {
      trader.updatePosition(oaPosition);
    }
  }

  void _handlePendingOrderExecuteEvent(TraderData trader, proto.ProtoOAExecutionEvent event) {
    _handleMarketExecutionEvent(trader, event);

    final proto.ProtoOAOrder oaOrder = event.order!;

    if (event.executionType == proto.ProtoOAExecutionType.orderFilled) {
      trader.ordersManager.removeActivity(oaOrder.orderId);
    } else {
      trader.ordersManager.updateActivity(oaOrder.orderId, event.order);
    }
  }

  void _handleOrderExecutionEvent(TraderData trader, proto.ProtoOAExecutionEvent event) {
    final proto.ProtoOAOrder oaOrder = event.order!;

    if (event.executionType == proto.ProtoOAExecutionType.orderCancelled ||
        event.executionType == proto.ProtoOAExecutionType.orderExpired ||
        event.executionType == proto.ProtoOAExecutionType.orderRejected) {
      trader.ordersManager.removeActivity(oaOrder.orderId);
    } else if (event.executionType == proto.ProtoOAExecutionType.orderAccepted) {
      trader.ordersManager.addActivity(OrderData.parseResponse(trader, oaOrder));
    } else {
      trader.ordersManager.updateActivity(oaOrder.orderId, oaOrder);
    }
  }

  void handlePositionTrailingStopEvent(proto.ProtoOATrailingSLChangedEvent event) {
    trader(event.ctidTraderAccountId)?.updatePositionTrailingStop(event);
    notifyListeners();
  }

  void toggleFavoriteSymbol(int symbolId) {
    selectedTrader.tree.toggleFavoriteSymbol(symbolId);
    _saveTraderFavorites(selectedTraderId);
    notifyListeners();
  }

  bool isSymbolFavorite(int symbolId) => selectedTrader.tree.isFavorite(symbolId);

  void toggleCategoryCollapse(int? id) {
    selectedTrader.tree.toggleCategory(id);
    _saveCollapsedCategories(selectedTraderId);
    notifyListeners();
  }

  Future<void> _saveSelectedTrader() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('selectedTrader', _selectedTrader);
  }

  Future<int?> restoreSelectedTrader() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('selectedTrader');
  }

  Future<void> _saveTraderFavorites(int traderId) async {
    final TraderData? trader = this.trader(traderId);
    if (trader == null) return;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('${traderId}_favorites', jsonEncode(trader.tree.favoriteSymbolIds.toList()));
  }

  Future<void> restoreTraderFavorites(int traderId) async {
    final TraderData? trader = this.trader(traderId);
    if (trader == null) throw 'Trader not exist';

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final dynamic idsJson = jsonDecode(prefs.getString('${traderId}_favorites') ?? '[]');
    final List<int> ids = List.castFrom<dynamic, int>(idsJson as List<dynamic>);
    trader.tree.restoreFavoriteSymbols(ids);
  }

  Future<void> _saveCollapsedCategories(int traderId) async {
    final TraderData? trader = this.trader(traderId);
    if (trader == null) return;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('${traderId}_collapsedCategories', jsonEncode(trader.tree.collapsedCategories.toList()));
  }

  Future<void> restoreCollapsedCategories(int traderId) async {
    final TraderData? trader = this.trader(traderId);
    if (trader == null) throw 'Trader not exist';

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final dynamic idsJson = jsonDecode(prefs.getString('${traderId}_collapsedCategories') ?? '[]');
    final List<int> ids = List.castFrom<dynamic, int>(idsJson as List<dynamic>);
    trader.tree.restoreCollapsedCategories(ids);
  }

  Future<void> saveSymbolVolume({required int traderId, required int symbolId, required int volume}) {
    return SharedPreferences.getInstance().then((SharedPreferences prefs) => prefs.setInt('volume_${traderId}_$symbolId', volume));
  }

  Future<int?> resotreSymbolVolume({required int traderId, required int symbolId}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('volume_${traderId}_$symbolId');
  }
}
