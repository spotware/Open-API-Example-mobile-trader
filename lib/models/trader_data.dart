import 'dart:math' as math;

import 'package:ctrader_example_app/extensions.dart';
import 'package:ctrader_example_app/models/activity_manager.dart';
import 'package:ctrader_example_app/models/asset_data.dart';
import 'package:ctrader_example_app/models/order_data.dart';
import 'package:ctrader_example_app/models/position_data.dart';
import 'package:ctrader_example_app/models/symbols_tree.dart';
import 'package:ctrader_example_app/remote/proto.dart' as proto;
import 'package:ctrader_example_app/remote/remote_api.dart';
import 'package:ctrader_example_app/remote/remote_api_manager.dart';
import 'package:ctrader_example_app/remote/spot_sub_manager.dart';
import 'package:get_it/get_it.dart';

class TraderData {
  TraderData.parseResponse(this.demo, proto.ProtoOATrader trader)
      : id = trader.ctidTraderAccountId,
        login = trader.traderLogin,
        name = trader.brokerName {
    _respTrader = trader;

    tree = SymbolsTree(this);

    _balance = trader.balance;
    _balanceVersion = trader.balanceVersion ?? _balanceVersion;

    decimals = trader.moneyDigits ?? decimals;
    swapFree = trader.swapFree == true;

    currencyId = trader.depositAssetId ?? -1;

    managerBonus = trader.managerBonus ?? managerBonus;
    ibBonus = trader.ibBonus ?? ibBonus;
    nonWithdrawableBonus = trader.nonWithdrawableBonus ?? nonWithdrawableBonus;

    frenchRisk = trader.frenchRisk == true;
    isLimitedRisk = trader.isLimitedRisk == true;
  }

  late proto.ProtoOATrader _respTrader;

  late SymbolsTree tree;

  final bool demo;
  final int id;
  final int login;
  int _balance = 0;
  int _balanceVersion = 0;
  String name;
  int decimals = 2;
  int currencyId = -1;
  bool swapFree = false;
  int pnl = 0;

  bool frenchRisk = false;
  bool isLimitedRisk = false;

  int managerBonus = 0;
  int ibBonus = 0;
  int nonWithdrawableBonus = 0;

  int margin = 0;

  final ActivityManager<PositionData> positionsManager = ActivityManager<PositionData>();
  final ActivityManager<OrderData> ordersManager = ActivityManager<OrderData>();

  proto.ProtoOAAccountType get accountType => _respTrader.accountType ?? proto.ProtoOAAccountType.spreadBetting;
  proto.ProtoOAAccessRights get accessRights => _respTrader.accessRights;
  proto.ProtoOALimitedRiskMarginCalculationStrategy? get limitedRiskMarginCalculationStrategy => _respTrader.limitedRiskMarginCalculationStrategy;
  int get registretionTs => _respTrader.registrationTimestamp ?? 0;
  int get levelrageInCents => _respTrader.leverageInCents;

  int get balance => _balance;

// Update it to calculations of pnl updates
  int get equity {
    final int bonuses = managerBonus + ibBonus + nonWithdrawableBonus;
    final int pnlBalance = _balance + pnl;

    if (bonuses > pnlBalance) {
      return pnlBalance * 2;
    } else {
      return bonuses + pnlBalance;
    }
  }

  int get freeMargin => equity - margin;

  double get marginLevel => equity / margin * 100;

  AssetData? get currencyAsset => tree.asset(currencyId);
  String get currencySign => currencyAsset?.displayName ?? '??';

  double toMoney(int value) => value / math.pow(10, decimals);
  String formattedMoney({int? cents, double? money}) => (money ?? toMoney(cents ?? 0)).toComaSeparated(decimals: decimals);
  String formattedMoneyWithCurrency({int? cents, double? money}) => formattedMoney(cents: cents, money: money) + ' $currencySign';

  String get formattedMarginLevel => margin != 0 ? marginLevel.toComaSeparated(decimals: 2) : '----';

  RemoteApi get remoteApi => GetIt.I<RemoteAPIManager>().getAPI(demo: demo);
  SpotSubscriptionManager get subscriptionManagerApi => GetIt.I<RemoteAPIManager>().getSpotSubscriptionManager(demo: demo);

  void recalculateFields() {
    margin = 0;
    pnl = 0;

    final Map<int, List<int>> marginsBySymbol = <int, List<int>>{};
    for (final PositionData position in positionsManager.activities) {
      marginsBySymbol[position.symbolId] ??= <int>[0, 0];
      marginsBySymbol[position.symbolId]![position.isBuy ? 0 : 1] += position.usedMargin;

      pnl += position.netPnl;
    }

    if (isLimitedRisk && limitedRiskMarginCalculationStrategy != proto.ProtoOALimitedRiskMarginCalculationStrategy.accordingToLeverage) {
      margin = marginsBySymbol.values.fold(0, (int total, List<int> margins) => total + margins[0] + margins[1]);
    } else {
      margin = switch (_respTrader.totalMarginCalculationType) {
        proto.ProtoOATotalMarginCalculationType.max =>
          marginsBySymbol.values.fold(0, (int total, List<int> margins) => total + math.max(margins[0], margins[1])),
        proto.ProtoOATotalMarginCalculationType.sum => marginsBySymbol.values.fold(0, (int total, List<int> margins) => total + margins[0] + margins[1]),
        proto.ProtoOATotalMarginCalculationType.net =>
          marginsBySymbol.values.fold(0, (int total, List<int> margins) => total + (margins[0] - margins[1]).abs()),
      };
    }
  }

  void handleReconcileResponse(proto.ProtoOAReconcileRes resp) {
    positionsManager.clear();
    for (final proto.ProtoOAPosition position in resp.position) {
      positionsManager.addActivity(PositionData.parseResponse(this, position));
    }

    ordersManager.clear();
    for (final proto.ProtoOAOrder order in resp.order) {
      ordersManager.addActivity(OrderData.parseResponse(this, order));
    }

    recalculateFields();
  }

  void handleTraderResponse(proto.ProtoOATraderRes resp) {
    updateBalance(resp.trader.balanceVersion ?? 0, resp.trader.balance);
  }

  void handleTraderUpdateEvent(proto.ProtoOATrader data) {
    _respTrader = data;
    updateBalance(data.balanceVersion ?? 0, data.balance);

    managerBonus = data.managerBonus ?? managerBonus;
    ibBonus = data.ibBonus ?? ibBonus;
    nonWithdrawableBonus = data.nonWithdrawableBonus ?? nonWithdrawableBonus;
    swapFree = data.swapFree ?? swapFree;
    frenchRisk = data.frenchRisk == true;
    isLimitedRisk = data.isLimitedRisk == true;
  }

  void handleMarginChangedEvent(proto.ProtoOAMarginChangedEvent event) {
    positionsManager.activityBy(id: event.positionId)?.usedMargin = event.usedMargin;

    recalculateFields();
  }

  void removePosition(int id, proto.ProtoOAClosePositionDetail? details) {
    if (positionsManager.removeActivity(id)) {
      if (details != null) updateBalance(details.balanceVersion ?? 0, details.balance);
      recalculateFields();
    }
  }

  void addPosition(PositionData position) {
    positionsManager.addActivity(position);
    recalculateFields();
  }

  void updatePosition(proto.ProtoOAPosition oaPosition) {
    positionsManager.updateActivity(oaPosition.positionId, oaPosition);
  }

  void updatePositionTrailingStop(proto.ProtoOATrailingSLChangedEvent event) {
    positionsManager.activityBy(id: event.positionId)?.updateTrailingStopValue(event.stopPrice);
  }

  bool updateBalance(int balanceVersion, int balance) {
    if (balanceVersion <= _balanceVersion) return false;

    _balance = balance;
    _balanceVersion = balanceVersion;

    return true;
  }

  void updateBonuses(int ibBonus, int managerBonus) {
    this.ibBonus = ibBonus;
    this.managerBonus = managerBonus;
  }
}
