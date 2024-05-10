// const PAYLOAD_TYPES = <String, int>{
//   "PROTO_OA_APPLICATION_AUTH_REQ": 2100,
//   "PROTO_OA_APPLICATION_AUTH_RES": 2101,
//   "PROTO_OA_ACCOUNT_AUTH_REQ": 2102,
//   "PROTO_OA_ACCOUNT_AUTH_RES": 2103,
//   "PROTO_OA_VERSION_REQ": 2104,
//   "PROTO_OA_VERSION_RES": 2105,
//   "PROTO_OA_NEW_ORDER_REQ": 2106,
//   "PROTO_OA_TRAILING_SL_CHANGED_EVENT": 2107,
//   "PROTO_OA_CANCEL_ORDER_REQ": 2108,
//   "PROTO_OA_AMEND_ORDER_REQ": 2109,
//   "PROTO_OA_AMEND_POSITION_SLTP_REQ": 2110,
//   "PROTO_OA_CLOSE_POSITION_REQ": 2111,
//   "PROTO_OA_ASSET_LIST_REQ": 2112,
//   "PROTO_OA_ASSET_LIST_RES": 2113,
//   "PROTO_OA_SYMBOLS_LIST_REQ": 2114,
//   "PROTO_OA_SYMBOLS_LIST_RES": 2115,
//   "PROTO_OA_SYMBOL_BY_ID_REQ": 2116,
//   "PROTO_OA_SYMBOL_BY_ID_RES": 2117,
//   "PROTO_OA_SYMBOLS_FOR_CONVERSION_REQ": 2118,
//   "PROTO_OA_SYMBOLS_FOR_CONVERSION_RES": 2119,
//   "PROTO_OA_SYMBOL_CHANGED_EVENT": 2120,
//   "PROTO_OA_TRADER_REQ": 2121,
//   "PROTO_OA_TRADER_RES": 2122,
//   "PROTO_OA_TRADER_UPDATE_EVENT": 2123,
//   "PROTO_OA_RECONCILE_REQ": 2124,
//   "PROTO_OA_RECONCILE_RES": 2125,
//   "PROTO_OA_EXECUTION_EVENT": 2126,
//   "PROTO_OA_SUBSCRIBE_SPOTS_REQ": 2127,
//   "PROTO_OA_SUBSCRIBE_SPOTS_RES": 2128,
//   "PROTO_OA_UNSUBSCRIBE_SPOTS_REQ": 2129,
//   "PROTO_OA_UNSUBSCRIBE_SPOTS_RES": 2130,
//   "PROTO_OA_SPOT_EVENT": 2131,
//   "PROTO_OA_ORDER_ERROR_EVENT": 2132,
//   "PROTO_OA_DEAL_LIST_REQ": 2133,
//   "PROTO_OA_DEAL_LIST_RES": 2134,
//   "PROTO_OA_SUBSCRIBE_LIVE_TRENDBAR_REQ": 2135,
//   "PROTO_OA_UNSUBSCRIBE_LIVE_TRENDBAR_REQ": 2136,
//   "PROTO_OA_GET_TRENDBARS_REQ": 2137,
//   "PROTO_OA_GET_TRENDBARS_RES": 2138,
//   "PROTO_OA_EXPECTED_MARGIN_REQ": 2139,
//   "PROTO_OA_EXPECTED_MARGIN_RES": 2140,
//   "PROTO_OA_MARGIN_CHANGED_EVENT": 2141,
//   "PROTO_OA_ERROR_RES": 2142,
//   "PROTO_OA_CASH_FLOW_HISTORY_LIST_REQ": 2143,
//   "PROTO_OA_CASH_FLOW_HISTORY_LIST_RES": 2144,
//   "PROTO_OA_GET_TICKDATA_REQ": 2145,
//   "PROTO_OA_GET_TICKDATA_RES": 2146,
//   "PROTO_OA_ACCOUNTS_TOKEN_INVALIDATED_EVENT": 2147,
//   "PROTO_OA_CLIENT_DISCONNECT_EVENT": 2148,
//   "PROTO_OA_GET_ACCOUNTS_BY_ACCESS_TOKEN_REQ": 2149,
//   "PROTO_OA_GET_ACCOUNTS_BY_ACCESS_TOKEN_RES": 2150,
//   "PROTO_OA_GET_CTID_PROFILE_BY_TOKEN_REQ": 2151,
//   "PROTO_OA_GET_CTID_PROFILE_BY_TOKEN_RES": 2152,
//   "PROTO_OA_ASSET_CLASS_LIST_REQ": 2153,
//   "PROTO_OA_ASSET_CLASS_LIST_RES": 2154,
//   "PROTO_OA_DEPTH_EVENT": 2155,
//   "PROTO_OA_SUBSCRIBE_DEPTH_QUOTES_REQ": 2156,
//   "PROTO_OA_SUBSCRIBE_DEPTH_QUOTES_RES": 2157,
//   "PROTO_OA_UNSUBSCRIBE_DEPTH_QUOTES_REQ": 2158,
//   "PROTO_OA_UNSUBSCRIBE_DEPTH_QUOTES_RES": 2159,
//   "PROTO_OA_SYMBOL_CATEGORY_REQ": 2160,
//   "PROTO_OA_SYMBOL_CATEGORY_RES": 2161,
//   "PROTO_OA_ACCOUNT_LOGOUT_REQ": 2162,
//   "PROTO_OA_ACCOUNT_LOGOUT_RES": 2163,
//   "PROTO_OA_ACCOUNT_DISCONNECT_EVENT": 2164,
//   "PROTO_OA_SUBSCRIBE_LIVE_TRENDBAR_RES": 2165,
//   "PROTO_OA_UNSUBSCRIBE_LIVE_TRENDBAR_RES": 2166,
//   "PROTO_OA_MARGIN_CALL_LIST_REQ": 2167,
//   "PROTO_OA_MARGIN_CALL_LIST_RES": 2168,
//   "PROTO_OA_MARGIN_CALL_UPDATE_REQ": 2169,
//   "PROTO_OA_MARGIN_CALL_UPDATE_RES": 2170,
//   "PROTO_OA_MARGIN_CALL_UPDATE_EVENT": 2171,
//   "PROTO_OA_MARGIN_CALL_TRIGGER_EVENT": 2172,
//   "PROTO_OA_REFRESH_TOKEN_REQ": 2173,
//   "PROTO_OA_REFRESH_TOKEN_RES": 2174,
//   "PROTO_OA_ORDER_LIST_REQ": 2175,
//   "PROTO_OA_ORDER_LIST_RES": 2176,
//   "PROTO_OA_GET_DYNAMIC_LEVERAGE_REQ": 2177,
//   "PROTO_OA_GET_DYNAMIC_LEVERAGE_RES": 2178,
//   "PROTO_OA_DEAL_LIST_BY_POSITION_ID_REQ": 2179,
//   "PROTO_OA_DEAL_LIST_BY_POSITION_ID_RES": 2180,
//   "PROTO_OA_ORDER_DETAILS_REQ": 2181,
//   "PROTO_OA_ORDER_DETAILS_RES": 2182,
//   "PROTO_OA_ORDER_LIST_BY_POSITION_ID_REQ": 2183,
//   "PROTO_OA_ORDER_LIST_BY_POSITION_ID_RES": 2184,
//   "PROTO_OA_DEAL_OFFSET_LIST_REQ": 2185,
//   "PROTO_OA_DEAL_OFFSET_LIST_RES": 2186,
// };

// ignore_for_file: always_specify_types

// ENUMES of the protocol
enum ProtoOAClientPermissionScope { scopeView, scopeTrade }

enum ProtoOAAccessRights { fullAccess, closeOnly, noTrading, noLogin }

enum ProtoOATotalMarginCalculationType { max, sum, net }

enum ProtoOAAccountType { hedged, netted, spreadBetting }

enum ProtoOALimitedRiskMarginCalculationStrategy { accordingToLeverage, accordingToGsl, accordingToGslAndLeverage }

enum ProtoOATradeSide { undefined, buy, sell }

enum ProtoOAPositionStatus { undefined, open, closed, created, error }

enum ProtoOAOrderTriggerMethod { undefined, trade, opposite, doubleTrade, doubleOpposite }

enum ProtoOAOrderType { undefined, market, limit, stop, stopLossTakeProfit, marketRange, stopLimit }

enum ProtoOAOrderStatus { udefined, accepted, filled, rejected, expired, cancelled }

enum ProtoOATimeInForce { undefined, goodTillDate, goodTillCancel, immediateOrCancel, fillOrKill, marketOnOpen }

enum ProtoOAExecutionType {
  undefined,
  undefined2,
  orderAccepted,
  orderFilled,
  orderReplaced,
  orderCancelled,
  orderExpired,
  orderRejected,
  orderCancelRejected,
  swap,
  depositWithdraw,
  orderPartialFill,
  bonusDepositWithdraw
}

enum ProtoOADealStatus { undefined, undefined2, filled, partiallyFilled, rejected, internallyRejected, error, missed }

enum ProtoOAChangeBonusType { bonusDeposit, bonusWithdraw }

enum ProtoOAChangeBalanceType {
  deposit,
  withdraw,
  depositStrategyCommissionInner,
  withdrawStrategyCommissionInner,
  depositIbCommissions,
  withdrawIbSharedPercentage,
  depositIbSharedPercentageFromSubIb,
  depositIbSharedPercentageFromBroker,
  depositRebate,
  withdrawRebate,
  depositStrategyCommissionOuter,
  withdrawStrategyCommissionOuter,
  withdrawBonusCompensation,
  withdrawIbSharedPercentageToBroker,
  depositDividends,
  withdrawDividends,
  withdrawGslCharge,
  withdrawRollover,
  depositNonwithdrawableBonus,
  withdrawNonwithdrawableBonus,
  depositSwap,
  withdrawSwap,
  depositManagementFee,
  withdrawManagementFee,
  depositPerformanceFee,
  withdrawForSubaccount,
  depositToSubaccount,
  withdrawFromSubaccount,
  depositFromSubaccount,
  withdrawCopyFee,
  withdrawInactivityFee,
  depositTransfer,
  withdrawTransfer,
  depositConvertedBonus,
  depositNegativeBalanceProtection,
}

enum ProtoOADayOfWeek { none, monday, tuesday, wednesday, thursday, friday, saturday, sunday }

enum ProtoOACommissionType { undefined, usdPerMillionUsd, usdPerLot, percentageOfValue, quoteCcyPerLot }

enum ProtoOASymbolDistanceType { undefined, symbolDistanceInPoints, symbolDistanceInPercentage }

enum ProtoOAMinCommissionType { undefined, currency, quoteCurrency }

enum ProtoOATradingMode { enabled, disabledWithoutPendingsExecution, disabledWithPendingsExecution, closeOnlyMode }

enum ProtoOASwapCalculationType { pips, percentage }

enum ProtoOATrendbarPeriod { undefined, m1, m2, m3, m4, m5, m10, m15, m30, h1, h4, h12, d1, w1, mn1 }

// Basic classes for model and message of protocol
abstract class ProtoModel {
  Map<String, dynamic> $payload();
  void $parse(Map<String, dynamic> data);
}

abstract class ProtoMessage {
  int get payloadType;
  String? cmdId;

  Map<String, dynamic> $payload();
  void $parse(Map<String, dynamic>? payload);
}

// MODELS of protocol
class ProtoOACtidTraderAccount extends ProtoModel {
  ProtoOACtidTraderAccount({
    required this.ctidTraderAccountId,
    this.isLive,
    this.traderLogin,
    this.lastClosingDealTimestamp,
    this.lastBalanceUpdateTimestamp,
  });
  ProtoOACtidTraderAccount.$parse(Map<String, dynamic> data) {
    $parse(data);
  }

  late final int ctidTraderAccountId;
  bool? isLive;
  int? traderLogin;
  int? lastClosingDealTimestamp;
  int? lastBalanceUpdateTimestamp;
  String brokerTitleShort = 'Broker Name';

  @override
  void $parse(Map<String, dynamic> data) {
    ctidTraderAccountId = data['ctidTraderAccountId'] as int;
    isLive = data['isLive'] as bool?;
    traderLogin = data['traderLogin'] as int?;
    lastClosingDealTimestamp = data['lastClosingDealTimestamp'] as int?;
    lastBalanceUpdateTimestamp = data['lastBalanceUpdateTimestamp'] as int?;
    brokerTitleShort = (data['brokerTitleShort'] as String?) ?? brokerTitleShort;
  }

  @override
  Map<String, dynamic> $payload() => <String, dynamic>{};
}

class ProtoOATrader extends ProtoModel {
  ProtoOATrader.$parse(Map<String, dynamic> data) {
    $parse(data);
  }

  late final int ctidTraderAccountId;
  late final int balance;
  int? balanceVersion;
  int? managerBonus;
  int? ibBonus;
  int? nonWithdrawableBonus;

  /// Probably required
  ProtoOAAccessRights accessRights = ProtoOAAccessRights.noTrading;
  int? depositAssetId;
  bool? swapFree;

  /// Probably required
  int leverageInCents = 100;

  /// Probably required
  ProtoOATotalMarginCalculationType totalMarginCalculationType = ProtoOATotalMarginCalculationType.max;
  int? maxLeverage;
  bool? frenchRisk;

  /// Probably required
  int traderLogin = 0;
  ProtoOAAccountType? accountType;

  /// Probably required
  String brokerName = 'Broker Name';
  int? registrationTimestamp;
  bool? isLimitedRisk;
  ProtoOALimitedRiskMarginCalculationStrategy? limitedRiskMarginCalculationStrategy;
  int? moneyDigits;
  bool? fairStopOut;

  @override
  Map<String, dynamic> $payload() => <String, dynamic>{};

  @override
  void $parse(Map<String, dynamic> data) {
    ctidTraderAccountId = data['ctidTraderAccountId'] as int;
    balance = data['balance'] as int;
    balanceVersion = data['balanceVersion'] as int?;
    managerBonus = data['managerBonus'] as int?;
    ibBonus = data['ibBonus'] as int?;
    nonWithdrawableBonus = data['nonWithdrawableBonus'] as int?;
    if (data['accessRights'] != null) {
      accessRights = ProtoOAAccessRights.values[data['accessRights'] as int];
    }
    depositAssetId = data['depositAssetId'] as int?;
    swapFree = data['swapFree'] as bool?;
    leverageInCents = data['leverageInCents'] as int? ?? leverageInCents;
    if (data['totalMarginCalculationType'] != null) {
      totalMarginCalculationType = ProtoOATotalMarginCalculationType.values[data['totalMarginCalculationType'] as int];
    }
    frenchRisk = data['frenchRisk'] as bool?;
    traderLogin = data['traderLogin'] as int? ?? traderLogin;
    if (data['accountType'] != null) {
      accountType = ProtoOAAccountType.values[data['accountType'] as int];
    }
    brokerName = data['brokerName'] as String? ?? brokerName;
    registrationTimestamp = data['registrationTimestamp'] as int;
    isLimitedRisk = data['isLimitedRisk'] as bool?;

    if (data['limitedRiskMarginCalculationStrategy'] != null) {
      limitedRiskMarginCalculationStrategy = ProtoOALimitedRiskMarginCalculationStrategy.values[data['limitedRiskMarginCalculationStrategy'] as int];
    }
    moneyDigits = data['moneyDigits'] as int?;
    fairStopOut = data['fairStopOut'] as bool?;
  }
}

class ProtoOATradeData extends ProtoModel {
  ProtoOATradeData.$parse(Map<String, dynamic> data) {
    $parse(data);
  }

  late final int symbolId;
  late final int volume;
  late final ProtoOATradeSide tradeSide;
  int? openTimestamp;
  String? label;
  bool? guaranteedStopLoss;
  String? comment;
  String? measurementUnits;

  @override
  Map<String, dynamic> $payload() => <String, dynamic>{};

  @override
  void $parse(Map<String, dynamic> data) {
    symbolId = data['symbolId'] as int;
    volume = data['volume'] as int;
    tradeSide = ProtoOATradeSide.values[data['tradeSide'] as int];
    openTimestamp = data['openTimestamp'] as int?;
    label = data['label'] as String?;
    guaranteedStopLoss = data['guaranteedStopLoss'] as bool?;
    comment = data['comment'] as String?;
    measurementUnits = data['measurementUnits'] as String?;
  }
}

class ProtoOAPosition extends ProtoModel {
  ProtoOAPosition.$parse(Map<String, dynamic> data) {
    $parse(data);
  }

  late final int positionId;
  late final ProtoOATradeData tradeData;
  late final ProtoOAPositionStatus positionStatus;
  late final int swap;
  late final double price;
  double? stopLoss;
  double? takeProfit;
  int? utcLastUpdateTimestamp;
  int? commission;
  double? marginRate;
  int? mirroringCommission;
  bool? guaranteedStopLoss;
  int? usedMargin;
  ProtoOAOrderTriggerMethod? stopLossTriggerMethod;
  int? moneyDigits;
  bool? trailingStopLoss;

  @override
  Map<String, dynamic> $payload() => <String, dynamic>{};

  @override
  void $parse(Map<String, dynamic> data) {
    positionId = data['positionId'] as int;
    tradeData = ProtoOATradeData.$parse(data['tradeData'] as Map<String, dynamic>);
    positionStatus = ProtoOAPositionStatus.values[data['positionStatus'] as int];
    swap = data['swap'] as int;
    price = data['price'] as double;

    stopLoss = data['stopLoss'] as double?;
    takeProfit = data['takeProfit'] as double?;
    utcLastUpdateTimestamp = data['utcLastUpdateTimestamp'] as int?;
    commission = data['commission'] as int?;
    marginRate = data['marginRate'] as double?;
    mirroringCommission = data['mirroringCommission'] as int?;
    guaranteedStopLoss = data['guaranteedStopLoss'] as bool?;
    usedMargin = data['usedMargin'] as int?;
    if (data['stopLossTriggerMethod'] != null) {
      stopLossTriggerMethod = ProtoOAOrderTriggerMethod.values[data['stopLossTriggerMethod'] as int];
    }
    moneyDigits = data['moneyDigits'] as int?;
    trailingStopLoss = data['trailingStopLoss'] as bool?;
  }
}

class ProtoOAOrder extends ProtoModel {
  ProtoOAOrder.$parse(Map<String, dynamic> data) {
    $parse(data);
  }

  late final int orderId;
  late final ProtoOATradeData tradeData;
  late final ProtoOAOrderType orderType;
  late final ProtoOAOrderStatus orderStatus;
  int? expirationTimestamp;
  double? executionPrice;
  int? executedVolume;
  int? utcLastUpdateTimestamp;
  double? baseSlippagePrice;
  int? slippageInPoints;
  bool? closingOrder;
  double? limitPrice;
  double? stopPrice;
  double? stopLoss;
  double? takeProfit;
  String? clientOrderId;
  ProtoOATimeInForce? timeInForce;
  int? positionId;
  int? relativeStopLoss;
  int? relativeTakeProfit;
  bool? isStopOut;
  bool? trailingStopLoss;
  ProtoOAOrderTriggerMethod? stopTriggerMethod;

  @override
  Map<String, dynamic> $payload() => <String, dynamic>{};

  @override
  void $parse(Map<String, dynamic> data) {
    orderId = data['orderId'] as int;
    tradeData = ProtoOATradeData.$parse(data['tradeData'] as Map<String, dynamic>);
    orderType = ProtoOAOrderType.values[data['orderType'] as int];
    orderStatus = ProtoOAOrderStatus.values[data['orderStatus'] as int];

    expirationTimestamp = data['expirationTimestamp'] as int?;
    executionPrice = data['executionPrice'] as double?;
    executedVolume = data['executedVolume'] as int?;
    utcLastUpdateTimestamp = data['utcLastUpdateTimestamp'] as int?;
    baseSlippagePrice = data['baseSlippagePrice'] as double?;
    slippageInPoints = data['slippageInPoints'] as int?;
    closingOrder = data['closingOrder'] as bool?;
    limitPrice = data['limitPrice'] as double?;
    stopPrice = data['stopPrice'] as double?;
    stopLoss = data['stopLoss'] as double?;
    takeProfit = data['takeProfit'] as double?;
    clientOrderId = data['clientOrderId'] as String?;
    if (data['timeInForce'] != null) timeInForce = ProtoOATimeInForce.values[data['timeInForce'] as int];
    positionId = data['positionId'] as int?;
    relativeStopLoss = data['relativeStopLoss'] as int?;
    relativeTakeProfit = data['relativeTakeProfit'] as int?;
    isStopOut = data['isStopOut'] as bool?;
    trailingStopLoss = data['trailingStopLoss'] as bool?;
    if (data['stopTriggerMethod'] != null) {
      stopTriggerMethod = ProtoOAOrderTriggerMethod.values[data['stopTriggerMethod'] as int];
    }
  }
}

class ProtoOADeal extends ProtoModel {
  ProtoOADeal.$parse(Map<String, dynamic> data) {
    $parse(data);
  }

  late final int dealId;
  late final int orderId;
  late final int positionId;
  late final int volume;
  late final int filledVolume;
  late final int symbolId;
  late final int createTimestamp;
  late final int executionTimestamp;
  int? utcLastUpdateTimestamp;
  double? executionPrice;
  late final ProtoOATradeSide tradeSide;
  late final ProtoOADealStatus dealStatus;
  double? marginRate;
  int? commission;
  double? baseToUsdConversionRate;
  ProtoOAClosePositionDetail? closePositionDetail;
  int? moneyDigits;

  @override
  Map<String, dynamic> $payload() => <String, dynamic>{};

  @override
  void $parse(Map<String, dynamic> data) {
    dealId = data['dealId'] as int;
    orderId = data['orderId'] as int;
    positionId = data['positionId'] as int;
    volume = data['volume'] as int;
    filledVolume = data['filledVolume'] as int;
    symbolId = data['symbolId'] as int;
    createTimestamp = data['createTimestamp'] as int;
    executionTimestamp = data['executionTimestamp'] as int;
    utcLastUpdateTimestamp = data['utcLastUpdateTimestamp'] as int?;
    executionPrice = data['executionPrice'] as double?;
    tradeSide = ProtoOATradeSide.values[data['tradeSide'] as int];
    dealStatus = ProtoOADealStatus.values[data['dealStatus'] as int];
    marginRate = data['marginRate'] as double?;
    commission = data['commission'] as int?;
    baseToUsdConversionRate = data['baseToUsdConversionRate'] as double?;
    if (data['closePositionDetail'] != null) {
      closePositionDetail = ProtoOAClosePositionDetail.$parse(data['closePositionDetail'] as Map<String, dynamic>);
    }
    moneyDigits = data['moneyDigits'] as int?;
  }
}

class ProtoOAClosePositionDetail extends ProtoModel {
  ProtoOAClosePositionDetail.$parse(Map<String, dynamic> data) {
    $parse(data);
  }

  late final double entryPrice;
  late final int grossProfit;
  late final int swap;
  late final int commission;
  late final int balance;
  double? quoteToDepositConversionRate;
  int? closedVolume;
  int? balanceVersion;
  int? moneyDigits;
  int? pnlConversionFee;

  @override
  Map<String, dynamic> $payload() => <String, dynamic>{};

  @override
  void $parse(Map<String, dynamic> data) {
    entryPrice = data['entryPrice'] as double;
    grossProfit = data['grossProfit'] as int;
    swap = data['swap'] as int;
    commission = data['commission'] as int;
    balance = data['balance'] as int;
    quoteToDepositConversionRate = data['quoteToDepositConversionRate'] as double?;
    closedVolume = data['closedVolume'] as int?;
    balanceVersion = data['balanceVersion'] as int?;
    moneyDigits = data['moneyDigits'] as int?;
    pnlConversionFee = data['pnlConversionFee'] as int?;
  }
}

class ProtoOABonusDepositWithdraw extends ProtoModel {
  ProtoOABonusDepositWithdraw.$parse(Map<String, dynamic> data) {
    $parse(data);
  }

  late final ProtoOAChangeBonusType operationType;
  late final int bonusHistoryId;
  late final int managerBonus;
  late final int managerDelta;
  late final int ibBonus;
  late final int ibDelta;
  late final int changeBonusTimestamp;
  String? externalNote;
  int? introducingBrokerId;
  int? moneyDigits;

  @override
  Map<String, dynamic> $payload() => <String, dynamic>{};

  @override
  void $parse(Map<String, dynamic> data) {
    operationType = ProtoOAChangeBonusType.values[data['operationType'] as int];
    bonusHistoryId = data['bonusHistoryId'] as int;
    managerBonus = data['managerBonus'] as int;
    managerDelta = data['managerDelta'] as int;
    ibBonus = data['ibBonus'] as int;
    ibDelta = data['ibDelta'] as int;
    changeBonusTimestamp = data['changeBonusTimestamp'] as int;
    externalNote = data['externalNote'] as String?;
    introducingBrokerId = data['introducingBrokerId'] as int?;
    moneyDigits = data['moneyDigits'] as int?;
  }
}

class ProtoOADepositWithdraw extends ProtoModel {
  ProtoOADepositWithdraw.$parse(Map<String, dynamic> data) {
    $parse(data);
  }

  late final ProtoOAChangeBalanceType operationType;
  late final int balanceHistoryId;
  late final int balance;
  late final int delta;
  late final int changeBalanceTimestamp;
  String? externalNote;
  int? balanceVersion;
  int? equity;
  int? moneyDigits;

  @override
  Map<String, dynamic> $payload() => <String, dynamic>{};

  @override
  void $parse(Map<String, dynamic> data) {
    operationType = ProtoOAChangeBalanceType.values[data['operationType'] as int];
    balanceHistoryId = data['balanceHistoryId'] as int;
    balance = data['balance'] as int;
    delta = data['delta'] as int;
    changeBalanceTimestamp = data['changeBalanceTimestamp'] as int;
    externalNote = data['externalNote'] as String?;
    balanceVersion = data['balanceVersion'] as int?;
    equity = data['equity'] as int?;
    moneyDigits = data['moneyDigits'] as int?;
  }
}

class ProtoOALightSymbol extends ProtoModel {
  ProtoOALightSymbol(this.symbolId);
  ProtoOALightSymbol.$parse(Map<String, dynamic> data) {
    $parse(data);
  }

  late final int symbolId;
  String? symbolName;
  bool? enabled;
  int? baseAssetId;
  int? quoteAssetId;
  int? symbolCategoryId;
  String? description;

  @override
  Map<String, dynamic> $payload() => <String, dynamic>{};

  @override
  void $parse(Map<String, dynamic> data) {
    symbolId = data['symbolId'] as int;
    symbolName = data['symbolName'] as String?;
    enabled = data['enabled'] as bool?;
    baseAssetId = data['baseAssetId'] as int?;
    quoteAssetId = data['quoteAssetId'] as int?;
    symbolCategoryId = data['symbolCategoryId'] as int?;
    description = data['description'] as String?;
  }
}

class ProtoOAArchivedSymbol extends ProtoModel {
  ProtoOAArchivedSymbol(this.symbolId, this.name, this.utcLastUpdateTimestamp);
  ProtoOAArchivedSymbol.$parse(Map<String, dynamic> data) {
    $parse(data);
  }

  late final int symbolId;
  late final String name;
  late final int utcLastUpdateTimestamp;
  String? description;

  @override
  Map<String, dynamic> $payload() => <String, dynamic>{};

  @override
  void $parse(Map<String, dynamic> data) {
    symbolId = data['symbolId'] as int;
    name = data['name'] as String;
    utcLastUpdateTimestamp = data['utcLastUpdateTimestamp'] as int;
    description = data['description'] as String?;
  }
}

class ProtoOAAsset extends ProtoModel {
  ProtoOAAsset(this.assetId, this.name);
  ProtoOAAsset.$parse(Map<String, dynamic> data) {
    $parse(data);
  }

  late final int assetId;
  late final String name;
  String? displayName;
  int? digits;

  @override
  Map<String, dynamic> $payload() => <String, dynamic>{};

  @override
  void $parse(Map<String, dynamic> data) {
    assetId = data['assetId'] as int;
    name = data['name'] as String;
    displayName = data['displayName'] as String?;
    digits = data['digits'] as int?;
  }
}

class ProtoOASymbolCategory extends ProtoModel {
  ProtoOASymbolCategory(this.id, this.assetClassId, this.name);
  ProtoOASymbolCategory.$parse(Map<String, dynamic> data) {
    $parse(data);
  }

  late final int id;
  late final int assetClassId;
  late final String name;
  late final double? sortingNumber;

  @override
  Map<String, dynamic> $payload() => <String, dynamic>{};

  @override
  void $parse(Map<String, dynamic> data) {
    id = data['id'] as int;
    assetClassId = data['assetClassId'] as int;
    name = data['name'] as String;
    sortingNumber = data['sortingNumber'] as double?;
  }
}

class ProtoOAAssetClass extends ProtoModel {
  ProtoOAAssetClass(this.id);
  ProtoOAAssetClass.$parse(Map<String, dynamic> data) {
    $parse(data);
  }

  late final int id;
  String? name;

  @override
  Map<String, dynamic> $payload() => <String, dynamic>{};

  @override
  void $parse(Map<String, dynamic> data) {
    id = data['id'] as int;
    name = data['name'] as String?;
  }
}

class ProtoOASymbol extends ProtoModel {
  ProtoOASymbol(this.symbolId, this.digits, this.pipPosition);
  ProtoOASymbol.$parse(Map<String, dynamic> data) {
    $parse(data);
  }

  late final int symbolId;
  late final int digits;
  late final int pipPosition;
  bool? enableShortSelling;
  bool? guaranteedStopLoss;
  ProtoOADayOfWeek? swapRollover3Days;
  double? swapLong;
  double? swapShort;
  late final int maxVolume;
  late final int minVolume;
  late final int stepVolume;
  int? maxExposure;
  List<ProtoOAInterval>? schedule;
  int? commission;
  ProtoOACommissionType? commissionType;
  int? slDistance;
  int? tpDistance;
  int? gslDistance;
  int? gslCharge;
  ProtoOASymbolDistanceType? distanceSetIn;
  int? minCommission;
  ProtoOAMinCommissionType? minCommissionType;
  String? minCommissionAsset;
  int? rolloverCommission;
  int? skipRolloverDays;
  String? scheduleTimeZone;
  ProtoOATradingMode? tradingMode;
  ProtoOADayOfWeek? rolloverCommission3Days;
  ProtoOASwapCalculationType? swapCalculationType;
  int? lotSize;
  int? preciseTradingCommissionRate;
  int? preciseMinCommission;
  List<ProtoOAHoliday>? holiday;
  int? pnlConversionFeeRate;
  int? leverageId;
  int? swapPeriod;
  int? swapTime;
  int? skipSWAPPeriods;
  bool? chargeSwapAtWeekends;
  String? measurementUnits;

  @override
  Map<String, dynamic> $payload() => <String, dynamic>{};

  @override
  void $parse(Map<String, dynamic> data) {
    symbolId = data['symbolId'] as int;
    digits = data['digits'] as int;
    pipPosition = data['pipPosition'] as int;
    enableShortSelling = data['enableShortSelling'] as bool?;
    guaranteedStopLoss = data['guaranteedStopLoss'] as bool?;
    if (data['swapRollover3Days'] != null) {
      swapRollover3Days = ProtoOADayOfWeek.values[data['swapRollover3Days'] as int];
    }
    swapLong = data['swapLong'] as double?;
    swapShort = data['swapShort'] as double?;
    maxVolume = data['maxVolume'] as int;
    minVolume = data['minVolume'] as int;
    stepVolume = data['stepVolume'] as int;
    maxExposure = data['maxExposure'] as int;
    if (data['schedule'] != null) {
      schedule = <ProtoOAInterval>[];
      for (final Map<String, dynamic> i in data['schedule']) {
        schedule!.add(ProtoOAInterval.$parse(i));
      }
    }
    commission = data['commission'] as int?;
    if (data['commissionType'] != null) commissionType = ProtoOACommissionType.values[data['commissionType'] as int];
    slDistance = data['slDistance'] as int?;
    tpDistance = data['tpDistance'] as int?;
    gslDistance = data['gslDistance'] as int?;
    gslCharge = data['gslCharge'] as int?;
    if (data['distanceSetIn'] != null) distanceSetIn = ProtoOASymbolDistanceType.values[data['distanceSetIn'] as int];
    minCommission = data['minCommission'] as int?;
    if (data['minCommissionType'] != null) {
      minCommissionType = ProtoOAMinCommissionType.values[data['minCommissionType'] as int];
    }
    minCommissionAsset = data['minCommissionAsset'] as String?;
    rolloverCommission = data['rolloverCommission'] as int?;
    skipRolloverDays = data['skipRolloverDays'] as int?;
    scheduleTimeZone = data['scheduleTimeZone'] as String?;
    if (data['tradingMode'] != null) {
      tradingMode = ProtoOATradingMode.values[data['tradingMode'] as int];
    }
    if (data['rolloverCommission3Days'] != null) {
      rolloverCommission3Days = ProtoOADayOfWeek.values[data['rolloverCommission3Days'] as int];
    }
    if (data['swapCalculationType'] != null) {
      swapCalculationType = ProtoOASwapCalculationType.values[data['swapCalculationType'] as int];
    }
    lotSize = data['lotSize'] as int?;
    preciseTradingCommissionRate = data['preciseTradingCommissionRate'] as int?;
    preciseMinCommission = data['preciseMinCommission'] as int?;
    if (data['holiday'] != null) {
      holiday = <ProtoOAHoliday>[];
      for (final Map<String, dynamic> i in data['holiday']) {
        holiday!.add(ProtoOAHoliday.$parse(i));
      }
    }
    pnlConversionFeeRate = data['pnlConversionFeeRate'] as int?;
    leverageId = data['leverageId'] as int?;
    swapPeriod = data['swapPeriod'] as int;
    swapTime = data['swapTime'] as int?;
    skipSWAPPeriods = data['skipSWAPPeriods'] as int?;
    chargeSwapAtWeekends = data['chargeSwapAtWeekends'] as bool?;
    measurementUnits = data['measurementUnits'] as String?;
  }
}

class ProtoOAInterval extends ProtoModel {
  ProtoOAInterval(this.startSecond, this.endSecond);
  ProtoOAInterval.$parse(Map<String, dynamic> data) {
    $parse(data);
  }

  late final int startSecond;
  late final int endSecond;

  @override
  Map<String, dynamic> $payload() => <String, dynamic>{};

  @override
  void $parse(Map<String, dynamic> data) {
    startSecond = data['startSecond'] as int;
    endSecond = data['endSecond'] as int;
  }
}

class ProtoOAHoliday extends ProtoModel {
  ProtoOAHoliday(this.holidayId, this.name, this.scheduleTimeZone, this.holidayDate, this.isRecurring);
  ProtoOAHoliday.$parse(Map<String, dynamic> data) {
    $parse(data);
  }

  late final int holidayId;
  late final String name;
  String? description;
  late final String scheduleTimeZone;
  late int holidayDate;
  late final bool isRecurring;
  int? startSecond;
  int? endSecond;

  @override
  Map<String, dynamic> $payload() => <String, dynamic>{};

  @override
  void $parse(Map<String, dynamic> data) {
    holidayId = data['holidayId'] as int;
    name = data['name'] as String;
    description = data['description'] as String?;
    scheduleTimeZone = data['scheduleTimeZone'] as String;
    holidayDate = data['holidayDate'] as int;
    isRecurring = data['isRecurring'] as bool;
    startSecond = data['startSecond'] as int?;
    endSecond = data['endSecond'] as int?;
  }
}

class ProtoOATrendbar extends ProtoModel {
  ProtoOATrendbar(this.volume);
  ProtoOATrendbar.$parse(Map<String, dynamic> data) {
    $parse(data);
  }

  late final int volume;
  ProtoOATrendbarPeriod? period;
  int? low;
  int? deltaOpen;
  int? deltaClose;
  int? deltaHigh;
  int? utcTimestampInMinutes;

  @override
  Map<String, dynamic> $payload() => <String, dynamic>{
        'volume': volume,
        'period': period?.index,
        'low': low,
        'deltaOpen': deltaOpen,
        'deltaClose': deltaClose,
        'deltaHigh': deltaHigh,
        'utcTimestampInMinutes': utcTimestampInMinutes,
      };

  @override
  void $parse(Map<String, dynamic> data) {
    volume = data['volume'] as int;
    if (data['period'] != null) period = ProtoOATrendbarPeriod.values[data['period'] as int];
    low = data['low'] as int?;
    deltaOpen = data['deltaOpen'] as int?;
    deltaClose = data['deltaClose'] as int?;
    deltaHigh = data['deltaHigh'] as int?;
    utcTimestampInMinutes = data['utcTimestampInMinutes'] as int?;
  }
}

class ProtoOADynamicLeverage extends ProtoModel {
  ProtoOADynamicLeverage(this.leverageId, this.tiers);
  ProtoOADynamicLeverage.$parse(Map<String, dynamic> data) {
    $parse(data);
  }

  late final int leverageId;
  late final List<ProtoOADynamicLeverageTier> tiers;

  @override
  Map<String, dynamic> $payload() => <String, dynamic>{};

  @override
  void $parse(Map<String, dynamic> data) {
    leverageId = data['leverageId'] as int;
    tiers = <ProtoOADynamicLeverageTier>[];
    for (final Map<String, dynamic> elem in data['tiers']) {
      tiers.add(ProtoOADynamicLeverageTier.$parse(elem));
    }
  }
}

class ProtoOADynamicLeverageTier extends ProtoModel {
  ProtoOADynamicLeverageTier(this.volume, this.leverage);
  ProtoOADynamicLeverageTier.$parse(Map<String, dynamic> data) {
    $parse(data);
  }

  late final int volume;
  late final int leverage;

  @override
  Map<String, dynamic> $payload() => <String, dynamic>{};

  @override
  void $parse(Map<String, dynamic> data) {
    volume = data['volume'] as int;
    leverage = data['leverage'] as int;
  }
}

class ProtoOAExpectedMargin extends ProtoModel {
  ProtoOAExpectedMargin(this.volume, this.buyMargin, this.sellMargin);
  ProtoOAExpectedMargin.$parse(Map<String, dynamic> data) {
    $parse(data);
  }

  late final int volume;
  late final int buyMargin;
  late final int sellMargin;

  @override
  Map<String, dynamic> $payload() => <String, dynamic>{};

  @override
  void $parse(Map<String, dynamic> data) {
    volume = data['volume'] as int;
    buyMargin = data['buyMargin'] as int;
    sellMargin = data['sellMargin'] as int;
  }
}

class ProtoOAPositionUnrealizedPnL extends ProtoModel {
  ProtoOAPositionUnrealizedPnL(this.positionId, this.grossUnrealizedPnL, this.netUnrealizedPnL);
  ProtoOAPositionUnrealizedPnL.$parse(Map<String, dynamic> data) {
    $parse(data);
  }

  late final int positionId;
  late final int grossUnrealizedPnL;
  late final int netUnrealizedPnL;

  @override
  Map<String, dynamic> $payload() => <String, dynamic>{};

  @override
  void $parse(Map<String, dynamic> data) {
    positionId = data['positionId'] as int;
    grossUnrealizedPnL = data['grossUnrealizedPnL'] as int;
    netUnrealizedPnL = data['netUnrealizedPnL'] as int;
  }
}

class ProtoOADealOffset extends ProtoModel {
  ProtoOADealOffset.$parse(Map<String, dynamic> data) {
    $parse(data);
  }

  late final int dealId;
  late final int volume;
  int? executionTimestamp;
  double? executionPrice;

  @override
  Map<String, dynamic> $payload() => <String, dynamic>{};

  @override
  void $parse(Map<String, dynamic> data) {
    dealId = data['dealId'] as int;
    volume = data['volume'] as int;
    executionTimestamp = data['executionTimestamp'] as int?;
    executionPrice = data['executionPrice'] as double?;
  }
}

// MESSAGES of protocol
class ProtoHeartbeatEvent extends ProtoMessage {
  ProtoHeartbeatEvent();
  ProtoHeartbeatEvent.$empty();

  static const int type = 51;

  @override
  int get payloadType => type;

  @override
  Map<String, dynamic> $payload() => <String, dynamic>{};

  @override
  void $parse(Map<String, dynamic>? payload) {}
}

class ProtoOAErrorRes extends ProtoMessage {
  ProtoOAErrorRes({
    this.ctidTraderAccountId,
    required this.errorCode,
    this.description,
    this.maintenanceEndTimestamp,
  });
  ProtoOAErrorRes.$empty();

  static const int type = 2142;

  int? ctidTraderAccountId;
  late final String errorCode;
  String? description;
  int? maintenanceEndTimestamp;

  @override
  int get payloadType => type;

  @override
  Map<String, dynamic> $payload() => <String, dynamic>{
        'cmdId': cmdId,
        'ctidTraderAccountId': ctidTraderAccountId,
        'errorCode': errorCode,
        'description': description,
        'maintenanceEndTimestamp': maintenanceEndTimestamp,
      };

  @override
  void $parse(Map<String, dynamic>? payload) {
    if (payload == null) throw "Payload data can't be null";

    ctidTraderAccountId = payload['ctidTraderAccountId'] as int?;
    errorCode = payload['errorCode'] as String;
    description = payload['description'] as String?;
    maintenanceEndTimestamp = payload['maintenanceEndTimestamp'] as int?;
  }
}

class ProtoOAApplicationAuthReq extends ProtoMessage {
  ProtoOAApplicationAuthReq(this.clientId, this.secredKey);
  ProtoOAApplicationAuthReq.$empty();

  static const int type = 2100;

  late final String clientId;
  late final String secredKey;

  @override
  int get payloadType => type;

  @override
  Map<String, dynamic> $payload() => <String, dynamic>{
        'clientId': clientId,
        'clientSecret': secredKey,
      };

  @override
  void $parse(Object? payload) {}
}

class ProtoOAApplicationAuthRes extends ProtoMessage {
  ProtoOAApplicationAuthRes.$empty();

  static const int type = 2101;

  @override
  int get payloadType => type;

  @override
  Map<String, dynamic> $payload() => <String, dynamic>{};

  @override
  void $parse(Object? payload) {}
}

class ProtoOAAccountAuthReq extends ProtoMessage {
  ProtoOAAccountAuthReq(this.ctidTraderAccountId, this.accessToken);
  ProtoOAAccountAuthReq.$empty();

  static const int type = 2102;

  late final int ctidTraderAccountId;
  late final String accessToken;

  @override
  int get payloadType => type;

  @override
  Map<String, dynamic> $payload() => <String, dynamic>{
        'ctidTraderAccountId': ctidTraderAccountId,
        'accessToken': accessToken,
      };

  @override
  void $parse(Map<String, dynamic>? payload) {}
}

class ProtoOAAccountAuthRes extends ProtoMessage {
  ProtoOAAccountAuthRes(this.ctidTraderAccountId);
  ProtoOAAccountAuthRes.$empty();

  static const int type = 2103;

  late final int ctidTraderAccountId;

  @override
  int get payloadType => type;

  @override
  Map<String, dynamic> $payload() => <String, dynamic>{};

  @override
  void $parse(Map<String, dynamic>? payload) {
    if (payload == null || payload.isEmpty) throw "Payload data can't be empy";

    ctidTraderAccountId = payload['ctidTraderAccountId'] as int;
  }
}

class ProtoOAGetAccountListByAccessTokenReq extends ProtoMessage {
  ProtoOAGetAccountListByAccessTokenReq(this.accessToken);
  ProtoOAGetAccountListByAccessTokenReq.$empty();

  static const int type = 2149;

  late final String accessToken;

  @override
  int get payloadType => type;

  @override
  Map<String, dynamic> $payload() => <String, dynamic>{
        'accessToken': accessToken,
      };

  @override
  void $parse(Map<String, dynamic>? payload) {}
}

class ProtoOAGetAccountListByAccessTokenRes extends ProtoMessage {
  ProtoOAGetAccountListByAccessTokenRes(
    this.accessToken,
    List<ProtoOACtidTraderAccount> ctidTraderAccount, [
    this.permissionScope,
  ]) {
    this.ctidTraderAccount.addAll(ctidTraderAccount);
  }
  ProtoOAGetAccountListByAccessTokenRes.$empty();

  static const int type = 2150;

  late final String accessToken;
  final List<ProtoOACtidTraderAccount> ctidTraderAccount = <ProtoOACtidTraderAccount>[];
  ProtoOAClientPermissionScope? permissionScope;

  @override
  int get payloadType => type;

  @override
  Map<String, dynamic> $payload() => <String, dynamic>{};

  @override
  void $parse(Map<String, dynamic>? payload) {
    assert(payload != null, "Payload data can't be null");

    accessToken = payload!['accessToken'] as String;
    if (payload['permissionScope'] != null) {
      permissionScope = ProtoOAClientPermissionScope.values[payload['permissionScope'] as int];
    }
    final List<dynamic> jsonAccountsList = payload['ctidTraderAccount'] as List<dynamic>? ?? <dynamic>[];
    for (final dynamic jsonAccount in jsonAccountsList) {
      ctidTraderAccount.add(ProtoOACtidTraderAccount.$parse(jsonAccount as Map<String, dynamic>));
    }
  }
}

class ProtoOATraderReq extends ProtoMessage {
  ProtoOATraderReq(this.ctidTraderAccountId);
  ProtoOATraderReq.$empty();

  static const int type = 2121;

  late final int ctidTraderAccountId;

  @override
  int get payloadType => type;

  @override
  Map<String, dynamic> $payload() => <String, dynamic>{
        'ctidTraderAccountId': ctidTraderAccountId,
      };

  @override
  void $parse(Map<String, dynamic>? payload) {}
}

class ProtoOATraderRes extends ProtoMessage {
  ProtoOATraderRes(this.ctidTraderAccountId, this.trader);
  ProtoOATraderRes.$empty();

  static const int type = 2122;

  late final int ctidTraderAccountId;
  late final ProtoOATrader trader;

  @override
  int get payloadType => type;

  @override
  Map<String, dynamic> $payload() => <String, dynamic>{};

  @override
  void $parse(Map<String, dynamic>? payload) {
    assert(payload != null, "Payload data can't be null");

    ctidTraderAccountId = payload!['ctidTraderAccountId'] as int;
    trader = ProtoOATrader.$parse(payload['trader'] as Map<String, dynamic>);
  }
}

class ProtoOAReconcileReq extends ProtoMessage {
  ProtoOAReconcileReq(this.ctidTraderAccountId);
  ProtoOAReconcileReq.$empty();

  static const int type = 2124;

  late final int ctidTraderAccountId;

  @override
  int get payloadType => type;

  @override
  Map<String, dynamic> $payload() => <String, dynamic>{
        'ctidTraderAccountId': ctidTraderAccountId,
      };

  @override
  void $parse(Map<String, dynamic>? payload) {}
}

class ProtoOAReconcileRes extends ProtoMessage {
  ProtoOAReconcileRes(this.ctidTraderAccountId, List<ProtoOAPosition> positions, List<ProtoOAOrder> orders) {
    position.addAll(positions);
    order.addAll(orders);
  }
  ProtoOAReconcileRes.$empty();

  static const int type = 2125;

  late final int ctidTraderAccountId;
  final List<ProtoOAPosition> position = <ProtoOAPosition>[];
  final List<ProtoOAOrder> order = <ProtoOAOrder>[];

  @override
  int get payloadType => type;

  @override
  Map<String, dynamic> $payload() => <String, dynamic>{
        'ctidTraderAccountId': ctidTraderAccountId,
      };

  @override
  void $parse(Map<String, dynamic>? payload) {
    if (payload == null || payload.isEmpty) throw "payload data can't be empty";

    ctidTraderAccountId = payload['ctidTraderAccountId'] as int;
    for (final dynamic p in payload['position'] ?? <dynamic>[]) {
      position.add(ProtoOAPosition.$parse(p as Map<String, dynamic>));
    }
    for (final dynamic o in payload['order'] ?? <dynamic>[]) {
      order.add(ProtoOAOrder.$parse(o as Map<String, dynamic>));
    }
  }
}

class ProtoOAExecutionEvent extends ProtoMessage {
  ProtoOAExecutionEvent(this.ctidTraderAccountId, this.executionType, this.order);
  ProtoOAExecutionEvent.$empty();

  static const int type = 2126;

  late final int ctidTraderAccountId;
  late final ProtoOAExecutionType executionType;
  ProtoOAOrder? order;
  ProtoOAPosition? position;
  ProtoOADeal? deal;
  ProtoOABonusDepositWithdraw? bonusDepositWithdraw;
  ProtoOADepositWithdraw? depositWithdraw;
  String? errorCode;
  bool? isServerEvent;

  @override
  int get payloadType => type;

  @override
  Map<String, dynamic> $payload() => <String, dynamic>{};

  @override
  void $parse(Map<String, dynamic>? payload) {
    if (payload == null || payload.isEmpty) throw "Payload can't be empty";

    ctidTraderAccountId = payload['ctidTraderAccountId'] as int;
    executionType = ProtoOAExecutionType.values[payload['executionType'] as int];
    if (payload['order'] != null) order = ProtoOAOrder.$parse(payload['order'] as Map<String, dynamic>);
    if (payload['position'] != null) {
      position = ProtoOAPosition.$parse(payload['position'] as Map<String, dynamic>);
    }
    if (payload['deal'] != null) {
      deal = ProtoOADeal.$parse(payload['deal'] as Map<String, dynamic>);
    }
    if (payload['bonusDepositWithdraw'] != null) {
      bonusDepositWithdraw = ProtoOABonusDepositWithdraw.$parse(payload['bonusDepositWithdraw'] as Map<String, dynamic>);
    }
    if (payload['depositWithdraw'] != null) {
      depositWithdraw = ProtoOADepositWithdraw.$parse(payload['depositWithdraw'] as Map<String, dynamic>);
    }
    errorCode = payload['errorCode'] as String?;
    isServerEvent = payload['isServerEvent'] as bool?;
  }
}

class ProtoOASymbolsListReq extends ProtoMessage {
  ProtoOASymbolsListReq(this.ctidTraderAccountId, [this.includeArchivedSymbols]);
  ProtoOASymbolsListReq.$empty();

  static const int type = 2114;

  late final int ctidTraderAccountId;
  bool? includeArchivedSymbols;

  @override
  int get payloadType => type;

  @override
  Map<String, dynamic> $payload() => <String, dynamic>{
        'ctidTraderAccountId': ctidTraderAccountId,
        'includeArchivedSymbols': includeArchivedSymbols,
      };

  @override
  void $parse(Map<String, dynamic>? payload) {}
}

class ProtoOASymbolsListRes extends ProtoMessage {
  ProtoOASymbolsListRes(this.ctidTraderAccountId, this.symbol, this.archivedSymbol);
  ProtoOASymbolsListRes.$empty();

  static const int type = 2115;

  late final int ctidTraderAccountId;
  late final List<ProtoOALightSymbol> symbol;
  List<ProtoOAArchivedSymbol>? archivedSymbol;

  @override
  int get payloadType => type;

  @override
  Map<String, dynamic> $payload() => <String, dynamic>{};

  @override
  void $parse(Map<String, dynamic>? payload) {
    if (payload == null || payload.isEmpty) throw "Payload data can't be null";

    ctidTraderAccountId = payload['ctidTraderAccountId'] as int;

    symbol = <ProtoOALightSymbol>[];
    for (final dynamic s in payload['symbol']) {
      symbol.add(ProtoOALightSymbol.$parse(s as Map<String, dynamic>));
    }

    if (payload['archivedSymbol'] != null) {
      archivedSymbol = <ProtoOAArchivedSymbol>[];
      for (final dynamic s in payload['archivedSymbol']) {
        archivedSymbol!.add(ProtoOAArchivedSymbol.$parse(s as Map<String, dynamic>));
      }
    }
  }
}

class ProtoOAAssetListReq extends ProtoMessage {
  ProtoOAAssetListReq(this.ctidTraderAccountId);
  ProtoOAAssetListReq.$empty();

  static const int type = 2112;

  late final int ctidTraderAccountId;

  @override
  int get payloadType => type;

  @override
  Map<String, dynamic> $payload() => <String, dynamic>{
        'ctidTraderAccountId': ctidTraderAccountId,
      };

  @override
  void $parse(Map<String, dynamic>? payload) {}
}

class ProtoOAAssetListRes extends ProtoMessage {
  ProtoOAAssetListRes(this.ctidTraderAccountId, this.asset);
  ProtoOAAssetListRes.$empty();

  static const int type = 2113;
  late final int ctidTraderAccountId;
  late final List<ProtoOAAsset> asset;

  @override
  int get payloadType => type;

  @override
  Map<String, dynamic> $payload() => <String, dynamic>{};

  @override
  void $parse(Map<String, dynamic>? payload) {
    if (payload == null || payload.isEmpty) throw "Payload data can't be empty";

    ctidTraderAccountId = payload['ctidTraderAccountId'] as int;

    asset = <ProtoOAAsset>[];
    for (final dynamic a in payload['asset']) {
      asset.add(ProtoOAAsset.$parse(a as Map<String, dynamic>));
    }
  }
}

class ProtoOASymbolCategoryListReq extends ProtoMessage {
  ProtoOASymbolCategoryListReq(this.ctidTraderAccountId);
  ProtoOASymbolCategoryListReq.$empty();

  static const int type = 2160;

  late final int ctidTraderAccountId;

  @override
  int get payloadType => type;

  @override
  Map<String, dynamic> $payload() => <String, dynamic>{
        'ctidTraderAccountId': ctidTraderAccountId,
      };

  @override
  void $parse(Map<String, dynamic>? payload) {}
}

class ProtoOASymbolCategoryListRes extends ProtoMessage {
  ProtoOASymbolCategoryListRes(this.ctidTraderAccountId, this.symbolCategory);
  ProtoOASymbolCategoryListRes.$empty();

  static const int type = 2161;

  late final int ctidTraderAccountId;
  late final List<ProtoOASymbolCategory> symbolCategory;

  @override
  int get payloadType => type;

  @override
  Map<String, dynamic> $payload() => <String, dynamic>{};

  @override
  void $parse(Map<String, dynamic>? payload) {
    if (payload == null || payload.isEmpty) throw "Payload data can't be null";

    ctidTraderAccountId = payload['ctidTraderAccountId'] as int;

    symbolCategory = <ProtoOASymbolCategory>[];
    for (final dynamic sc in payload['symbolCategory']) {
      symbolCategory.add(ProtoOASymbolCategory.$parse(sc as Map<String, dynamic>));
    }
  }
}

class ProtoOAAssetClassListReq extends ProtoMessage {
  ProtoOAAssetClassListReq(this.ctidTraderAccountId);
  ProtoOAAssetClassListReq.$empty();

  static const int type = 2153;

  late final int ctidTraderAccountId;

  @override
  int get payloadType => type;

  @override
  Map<String, dynamic> $payload() => <String, dynamic>{
        'ctidTraderAccountId': ctidTraderAccountId,
      };

  @override
  void $parse(Map<String, dynamic>? payload) {}
}

class ProtoOAAssetClassListRes extends ProtoMessage {
  ProtoOAAssetClassListRes(this.ctidTraderAccountId, this.assetClass);
  ProtoOAAssetClassListRes.$empty();

  static const int type = 2154;

  late final int ctidTraderAccountId;
  late final List<ProtoOAAssetClass> assetClass;

  @override
  int get payloadType => type;

  @override
  Map<String, dynamic> $payload() => <String, dynamic>{};

  @override
  void $parse(Map<String, dynamic>? payload) {
    if (payload == null || payload.isEmpty) throw "Payload data can't be null";

    ctidTraderAccountId = payload['ctidTraderAccountId'] as int;

    assetClass = <ProtoOAAssetClass>[];
    for (final dynamic ac in payload['assetClass']) {
      assetClass.add(ProtoOAAssetClass.$parse(ac as Map<String, dynamic>));
    }
  }
}

class ProtoOASubscribeSpotsReq extends ProtoMessage {
  ProtoOASubscribeSpotsReq(this.ctidTraderAccountId, this.symbolId, [this.subscribeToSpotTimestamp]);
  ProtoOASubscribeSpotsReq.$empty();

  static const int type = 2127;

  late final int ctidTraderAccountId;
  late final List<int> symbolId;
  bool? subscribeToSpotTimestamp;

  @override
  int get payloadType => type;

  @override
  Map<String, dynamic> $payload() => <String, dynamic>{
        'ctidTraderAccountId': ctidTraderAccountId,
        'symbolId': symbolId,
        'subscribeToSpotTimestamp': subscribeToSpotTimestamp,
      };

  @override
  void $parse(Map<String, dynamic>? payload) {}
}

class ProtoOASubscribeSpotsRes extends ProtoMessage {
  ProtoOASubscribeSpotsRes(this.ctidTraderAccountId);
  ProtoOASubscribeSpotsRes.$empty();

  static const int type = 2128;

  late final int ctidTraderAccountId;

  @override
  int get payloadType => type;

  @override
  Map<String, dynamic> $payload() => <String, dynamic>{};

  @override
  void $parse(Map<String, dynamic>? payload) {
    if (payload == null || payload.isEmpty) throw "Payload data can't be null";

    ctidTraderAccountId = payload['ctidTraderAccountId'] as int;
  }
}

class ProtoOAUnsubscribeSpotsReq extends ProtoMessage {
  ProtoOAUnsubscribeSpotsReq(this.ctidTraderAccountId, this.symbolId);
  ProtoOAUnsubscribeSpotsReq.$empty();

  static const int type = 2129;

  late final int ctidTraderAccountId;
  late final List<int> symbolId;

  @override
  int get payloadType => type;

  @override
  Map<String, dynamic> $payload() => <String, dynamic>{
        'ctidTraderAccountId': ctidTraderAccountId,
        'symbolId': symbolId,
      };

  @override
  void $parse(Map<String, dynamic>? payload) {}
}

class ProtoOAUnsubscribeSpotsRes extends ProtoMessage {
  ProtoOAUnsubscribeSpotsRes(this.ctidTraderAccountId);
  ProtoOAUnsubscribeSpotsRes.$empty();

  static const int type = 2130;

  late final int ctidTraderAccountId;

  @override
  int get payloadType => type;

  @override
  Map<String, dynamic> $payload() => <String, dynamic>{};

  @override
  void $parse(Map<String, dynamic>? payload) {
    if (payload == null || payload.isEmpty) throw "Payload data can't be null";

    ctidTraderAccountId = payload['ctidTraderAccountId'] as int;
  }
}

class ProtoOASpotEvent extends ProtoMessage {
  ProtoOASpotEvent.$empty();

  static const int type = 2131;

  late final int ctidTraderAccountId;
  late final int symbolId;
  int? bid;
  int? ask;
  List<ProtoOATrendbar>? trendbar;
  int? sessionClose;
  int? timestamp;

  @override
  int get payloadType => type;

  @override
  Map<String, dynamic> $payload() => <String, dynamic>{};

  @override
  void $parse(Map<String, dynamic>? payload) {
    if (payload == null || payload.isEmpty) throw "Payload data can't be null";

    ctidTraderAccountId = payload['ctidTraderAccountId'] as int;
    symbolId = payload['symbolId'] as int;
    bid = payload['bid'] as int?;
    ask = payload['ask'] as int?;
    if (payload['trendbar'] != null) {
      trendbar = <ProtoOATrendbar>[];
      for (final dynamic bar in payload['trendbar']) {
        trendbar!.add(ProtoOATrendbar.$parse(bar as Map<String, dynamic>));
      }
    }
    sessionClose = payload['sessionClose'] as int?;
    timestamp = payload['timestamp'] as int?;
  }
}

class ProtoOASymbolByIdReq extends ProtoMessage {
  ProtoOASymbolByIdReq(this.ctidTraderAccountId, this.symbolId);
  ProtoOASymbolByIdReq.$empty();

  static const int type = 2116;

  late final int ctidTraderAccountId;
  late final List<int> symbolId;

  @override
  int get payloadType => type;

  @override
  Map<String, dynamic> $payload() => <String, dynamic>{
        'ctidTraderAccountId': ctidTraderAccountId,
        'symbolId': symbolId,
      };

  @override
  void $parse(Map<String, dynamic>? payload) {}
}

class ProtoOASymbolByIdRes extends ProtoMessage {
  ProtoOASymbolByIdRes(this.ctidTraderAccountId, this.symbol);
  ProtoOASymbolByIdRes.$empty();

  static const int type = 2117;

  late final int ctidTraderAccountId;
  late final List<ProtoOASymbol> symbol;
  List<ProtoOAArchivedSymbol>? archivedSymbol;

  @override
  int get payloadType => type;

  @override
  Map<String, dynamic> $payload() => <String, dynamic>{};

  @override
  void $parse(Map<String, dynamic>? payload) {
    if (payload == null || payload.isEmpty) throw "Payload data can't be null";

    ctidTraderAccountId = payload['ctidTraderAccountId'] as int;

    symbol = <ProtoOASymbol>[];
    for (final dynamic s in payload['symbol']) {
      symbol.add(ProtoOASymbol.$parse(s as Map<String, dynamic>));
    }

    if (payload['archivedSymbol'] != null) {
      archivedSymbol = <ProtoOAArchivedSymbol>[];
      for (final dynamic s in payload['archivedSymbol']) {
        archivedSymbol!.add(ProtoOAArchivedSymbol.$parse(s as Map<String, dynamic>));
      }
    }
  }
}

class ProtoOAGetDynamicLeverageByIDReq extends ProtoMessage {
  ProtoOAGetDynamicLeverageByIDReq(this.ctidTraderAccountId, this.leverageId);
  ProtoOAGetDynamicLeverageByIDReq.$empty();

  static const int type = 2177;

  late final int ctidTraderAccountId;
  late final int leverageId;

  @override
  int get payloadType => type;

  @override
  Map<String, dynamic> $payload() => <String, dynamic>{
        'ctidTraderAccountId': ctidTraderAccountId,
        'leverageId': leverageId,
      };

  @override
  void $parse(Map<String, dynamic>? payload) {}
}

class ProtoOAGetDynamicLeverageByIDRes extends ProtoMessage {
  ProtoOAGetDynamicLeverageByIDRes.$empty();

  static const int type = 2178;

  late final int ctidTraderAccountId;
  late final ProtoOADynamicLeverage leverage;

  @override
  int get payloadType => type;

  @override
  Map<String, dynamic> $payload() => <String, dynamic>{};

  @override
  void $parse(Map<String, dynamic>? payload) {
    if (payload == null || payload.isEmpty) throw "Payload data can't be null";

    ctidTraderAccountId = payload['ctidTraderAccountId'] as int;
    leverage = ProtoOADynamicLeverage.$parse(payload['leverage'] as Map<String, dynamic>);
  }
}

class ProtoOAGetTrendbarsReq extends ProtoMessage {
  ProtoOAGetTrendbarsReq(
    this.ctidTraderAccountId,
    this.fromTimestamp,
    this.toTimestamp,
    this.period,
    this.symbolId,
    this.count,
  );
  ProtoOAGetTrendbarsReq.$empty();

  static const int type = 2137;

  late final int ctidTraderAccountId;
  late final int fromTimestamp;
  late final int toTimestamp;
  late final ProtoOATrendbarPeriod period;
  late final int symbolId;
  late final int count;

  @override
  int get payloadType => type;

  @override
  Map<String, dynamic> $payload() => <String, dynamic>{
        'ctidTraderAccountId': ctidTraderAccountId,
        'fromTimestamp': fromTimestamp,
        'toTimestamp': toTimestamp,
        'period': period.index,
        'symbolId': symbolId,
        'count': count,
      };

  @override
  void $parse(Map<String, dynamic>? payload) {}
}

class ProtoOAGetTrendbarsRes extends ProtoMessage {
  ProtoOAGetTrendbarsRes(this.ctidTraderAccountId, this.period, this.timestamp, this.trendbar);
  ProtoOAGetTrendbarsRes.$empty();

  static const int type = 2138;

  late final int ctidTraderAccountId;
  late final ProtoOATrendbarPeriod period;
  late final int timestamp;
  late final List<ProtoOATrendbar> trendbar;
  int? symbolId;

  @override
  int get payloadType => type;

  @override
  Map<String, dynamic> $payload() => <String, dynamic>{
        'ctidTraderAccountId': ctidTraderAccountId,
        'period': period.index,
        'timestamp': timestamp,
        'symbolId': symbolId,
        'trendbar': trendbar.map((e) => e.$payload()).toList(),
      };

  @override
  void $parse(Map<String, dynamic>? payload) {
    if (payload == null || payload.isEmpty) throw "Payload data can't be null";

    ctidTraderAccountId = payload['ctidTraderAccountId'] as int;
    timestamp = payload['timestamp'] as int;
    symbolId = payload['symbolId'] as int?;
    period = ProtoOATrendbarPeriod.values.elementAt(payload['period'] as int);

    trendbar = <ProtoOATrendbar>[];
    if (payload['trendbar'] != null) {
      for (final dynamic b in payload['trendbar']) {
        trendbar.add(ProtoOATrendbar.$parse(b as Map<String, dynamic>));
      }
    }
  }
}

class ProtoOAExpectedMarginReq extends ProtoMessage {
  ProtoOAExpectedMarginReq(this.ctidTraderAccountId, this.symbolId, this.volume);
  ProtoOAExpectedMarginReq.$empty();

  static const int type = 2139;

  late final int ctidTraderAccountId;
  late final int symbolId;
  late final List<int> volume;

  @override
  int get payloadType => type;

  @override
  Map<String, dynamic> $payload() => <String, dynamic>{
        'ctidTraderAccountId': ctidTraderAccountId,
        'symbolId': symbolId,
        'volume': volume,
      };

  @override
  void $parse(Map<String, dynamic>? payload) {}
}

class ProtoOAExpectedMarginRes extends ProtoMessage {
  ProtoOAExpectedMarginRes(this.ctidTraderAccountId, this.margin, this.moneyDigits);
  ProtoOAExpectedMarginRes.$empty();

  static const int type = 2140;

  late final int ctidTraderAccountId;
  late final List<ProtoOAExpectedMargin> margin;
  late final int moneyDigits;

  @override
  int get payloadType => type;

  @override
  Map<String, dynamic> $payload() => <String, dynamic>{};

  @override
  void $parse(Map<String, dynamic>? payload) {
    if (payload == null || payload.isEmpty) throw "Payload data can't be null";

    ctidTraderAccountId = payload['ctidTraderAccountId'] as int;
    moneyDigits = payload['moneyDigits'] as int;

    margin = <ProtoOAExpectedMargin>[];
    for (final dynamic m in payload['margin']) {
      margin.add(ProtoOAExpectedMargin.$parse(m as Map<String, dynamic>));
    }
  }
}

class ProtoOAAccountLogoutReq extends ProtoMessage {
  ProtoOAAccountLogoutReq(this.ctidTraderAccountId);
  ProtoOAAccountLogoutReq.$empty();

  static const int type = 2162;

  late final int ctidTraderAccountId;

  @override
  int get payloadType => type;

  @override
  void $parse(Map<String, dynamic>? payload) {}

  @override
  Map<String, dynamic> $payload() => <String, dynamic>{
        'ctidTraderAccountId': ctidTraderAccountId,
      };
}

class ProtoOAAccountLogoutRes extends ProtoMessage {
  ProtoOAAccountLogoutRes(this.ctidTraderAccountId);
  ProtoOAAccountLogoutRes.$empty();

  static const int type = 2163;

  late final int ctidTraderAccountId;

  @override
  int get payloadType => type;

  @override
  Map<String, dynamic> $payload() => <String, dynamic>{
        'ctidTraderAccountId': ctidTraderAccountId,
      };

  @override
  void $parse(Map<String, dynamic>? payload) {
    if (payload == null || payload.isEmpty) throw "Payload data can't be null";

    ctidTraderAccountId = payload['ctidTraderAccountId'] as int;
  }
}

class ProtoOANewOrderReq extends ProtoMessage {
  ProtoOANewOrderReq(
    this.ctidTraderAccountId,
    this.symbolId,
    this.tradeSide,
    this.volume, {
    required this.orderType,
    this.timeInForce,
  });
  ProtoOANewOrderReq.$empty();

  static const int type = 2106;

  late final int ctidTraderAccountId;
  late final int symbolId;
  late final ProtoOAOrderType orderType;
  late final ProtoOATradeSide tradeSide;
  late final int volume;
  double? limitPrice;
  double? stopPrice;
  ProtoOATimeInForce? timeInForce;
  int? expirationTimestamp;
  double? stopLoss;
  double? takeProfit;
  String? comment;
  double? baseSlippagePrice;
  int? slippageInPoints;
  String? label;
  int? positionId;
  String? clientOrderId;
  int? relativeStopLoss;
  int? relativeTakeProfit;
  bool? guaranteedStopLoss;
  bool? trailingStopLoss;
  ProtoOAOrderTriggerMethod? stopTriggerMethod;

  @override
  int get payloadType => type;

  @override
  Map<String, dynamic> $payload() {
    final Map<String, dynamic> payload = <String, dynamic>{
      'ctidTraderAccountId': ctidTraderAccountId,
      'symbolId': symbolId,
      'volume': volume,
      'orderType': orderType.index,
      'tradeSide': tradeSide.index
    };

    if (limitPrice != null) payload['limitPrice'] = limitPrice;
    if (stopPrice != null) payload['stopPrice'] = stopPrice;
    if (timeInForce != null) payload['timeInForce'] = timeInForce!.index;
    if (expirationTimestamp != null) payload['expirationTimestamp'] = expirationTimestamp;
    if (stopLoss != null) payload['stopLoss'] = stopLoss;
    if (takeProfit != null) payload['takeProfit'] = takeProfit;
    if (comment != null) payload['comment'] = comment;
    if (baseSlippagePrice != null) payload['baseSlippagePrice'] = baseSlippagePrice;
    if (slippageInPoints != null) payload['slippageInPoints'] = slippageInPoints;
    if (label != null) payload['label'] = label;
    if (positionId != null) payload['positionId'] = positionId;
    if (clientOrderId != null) payload['clientOrderId'] = clientOrderId;
    if (relativeStopLoss != null) payload['relativeStopLoss'] = relativeStopLoss;
    if (relativeTakeProfit != null) payload['relativeTakeProfit'] = relativeTakeProfit;
    if (guaranteedStopLoss != null) payload['guaranteedStopLoss'] = guaranteedStopLoss;
    if (trailingStopLoss != null) payload['trailingStopLoss'] = trailingStopLoss;
    if (stopTriggerMethod != null) payload['stopTriggerMethod'] = stopTriggerMethod!.index;

    return payload;
  }

  @override
  void $parse(Map<String, dynamic>? payload) {}
}

class ProtoOAGetPositionUnrealizedPnLReq extends ProtoMessage {
  ProtoOAGetPositionUnrealizedPnLReq(this.ctidTraderAccountId);
  ProtoOAGetPositionUnrealizedPnLReq.$empty();

  static const int type = 2187;

  late final int ctidTraderAccountId;

  @override
  int get payloadType => type;

  @override
  Map<String, dynamic> $payload() => <String, dynamic>{
        'ctidTraderAccountId': ctidTraderAccountId,
      };

  @override
  void $parse(Map<String, dynamic>? payload) {}
}

class ProtoOAGetPositionUnrealizedPnLRes extends ProtoMessage {
  ProtoOAGetPositionUnrealizedPnLRes(this.ctidTraderAccountId, this.positionUnrealizedPnL, this.moneyDigits);
  ProtoOAGetPositionUnrealizedPnLRes.$empty();

  static const int type = 2188;

  late final int ctidTraderAccountId;
  late final List<ProtoOAPositionUnrealizedPnL> positionUnrealizedPnL;
  late final int moneyDigits;

  @override
  int get payloadType => type;

  @override
  Map<String, dynamic> $payload() => <String, dynamic>{};

  @override
  void $parse(Map<String, dynamic>? payload) {
    if (payload == null || payload.isEmpty) throw "Payload data can't be empty";

    ctidTraderAccountId = payload['ctidTraderAccountId'] as int;
    moneyDigits = payload['moneyDigits'] as int;

    positionUnrealizedPnL = <ProtoOAPositionUnrealizedPnL>[];
    for (final dynamic p in payload['positionUnrealizedPnL'] ?? <dynamic>[]) {
      positionUnrealizedPnL.add(ProtoOAPositionUnrealizedPnL.$parse(p as Map<String, dynamic>));
    }
  }
}

class ProtoOASubscribeLiveTrendbarReq extends ProtoMessage {
  ProtoOASubscribeLiveTrendbarReq(this.ctidTraderAccountId, this.period, this.symbolId);
  ProtoOASubscribeLiveTrendbarReq.$empty();

  static const int type = 2135;

  late final int ctidTraderAccountId;
  late final ProtoOATrendbarPeriod period;
  late final int symbolId;

  @override
  int get payloadType => type;

  @override
  Map<String, dynamic> $payload() => <String, dynamic>{
        'ctidTraderAccountId': ctidTraderAccountId,
        'symbolId': symbolId,
        'period': period.index,
      };

  @override
  void $parse(Map<String, dynamic>? payload) {}
}

class ProtoOASubscribeLiveTrendbarRes extends ProtoMessage {
  ProtoOASubscribeLiveTrendbarRes(this.ctidTraderAccountId);
  ProtoOASubscribeLiveTrendbarRes.$empty();

  static const int type = 2165;

  late final int ctidTraderAccountId;

  @override
  int get payloadType => type;

  @override
  Map<String, dynamic> $payload() => <String, dynamic>{};

  @override
  void $parse(Map<String, dynamic>? payload) {
    if (payload == null || payload.isEmpty) throw "Payload data can't be null";

    ctidTraderAccountId = payload['ctidTraderAccountId'] as int;
  }
}

class ProtoOAUnsubscribeLiveTrendbarReq extends ProtoMessage {
  ProtoOAUnsubscribeLiveTrendbarReq(this.ctidTraderAccountId, this.period, this.symbolId);
  ProtoOAUnsubscribeLiveTrendbarReq.$empty();

  static const int type = 2136;

  late final int ctidTraderAccountId;
  late final ProtoOATrendbarPeriod period;
  late final int symbolId;

  @override
  int get payloadType => type;

  @override
  Map<String, dynamic> $payload() => <String, dynamic>{
        'ctidTraderAccountId': ctidTraderAccountId,
        'symbolId': symbolId,
        'period': period.index,
      };

  @override
  void $parse(Map<String, dynamic>? payload) {}
}

class ProtoOAUnsubscribeLiveTrendbarRes extends ProtoMessage {
  ProtoOAUnsubscribeLiveTrendbarRes(this.ctidTraderAccountId);
  ProtoOAUnsubscribeLiveTrendbarRes.$empty();

  static const int type = 2166;

  late final int ctidTraderAccountId;

  @override
  int get payloadType => type;

  @override
  Map<String, dynamic> $payload() => <String, dynamic>{};

  @override
  void $parse(Map<String, dynamic>? payload) {
    if (payload == null || payload.isEmpty) throw "Payload data can't be empty";

    ctidTraderAccountId = payload['ctidTraderAccountId'] as int;
  }
}

class ProtoOADealListReq extends ProtoMessage {
  ProtoOADealListReq(this.ctidTraderAccountId, this.fromTimestamp, this.toTimestamp);
  ProtoOADealListReq.$empty();

  static const int type = 2133;

  late final int ctidTraderAccountId;
  late final int fromTimestamp;
  late final int toTimestamp;
  int? maxRows;

  @override
  int get payloadType => type;

  @override
  Map<String, dynamic> $payload() => <String, dynamic>{
        'ctidTraderAccountId': ctidTraderAccountId,
        'fromTimestamp': fromTimestamp,
        'toTimestamp': toTimestamp,
        'maxRows': maxRows,
      };

  @override
  void $parse(Map<String, dynamic>? payload) {}
}

class ProtoOADealListRes extends ProtoMessage {
  ProtoOADealListRes(this.ctidTraderAccountId, this.deal, this.hasMore);
  ProtoOADealListRes.$empty();

  static const int type = 2134;

  late final int ctidTraderAccountId;
  late final List<ProtoOADeal> deal;
  late final bool hasMore;

  @override
  int get payloadType => type;

  @override
  Map<String, dynamic> $payload() => <String, dynamic>{};

  @override
  void $parse(Map<String, dynamic>? payload) {
    if (payload == null || payload.isEmpty) throw "Payload data can't be empty";

    ctidTraderAccountId = payload['ctidTraderAccountId'] as int;
    hasMore = payload['hasMore'] as bool;

    deal = <ProtoOADeal>[];
    for (final dynamic d in payload['deal'] ?? <dynamic>[]) {
      deal.add(ProtoOADeal.$parse(d as Map<String, dynamic>));
    }
  }
}

class ProtoOAOrderErrorEvent extends ProtoMessage {
  ProtoOAOrderErrorEvent(this.ctidTraderAccountId, this.errorCode);
  ProtoOAOrderErrorEvent.$empty();

  static const int type = 2132;

  late final int ctidTraderAccountId;
  late final String errorCode;
  int? orderId;
  int? positionId;
  String? description;

  @override
  int get payloadType => type;

  @override
  Map<String, dynamic> $payload() => <String, dynamic>{};

  @override
  void $parse(Map<String, dynamic>? payload) {
    if (payload == null || payload.isEmpty) throw "Payload data can't be empty";

    ctidTraderAccountId = payload['ctidTraderAccountId'] as int;
    errorCode = payload['errorCode'] as String;
    orderId = payload['orderId'] as int?;
    positionId = payload['positionId'] as int?;
    description = payload['description'] as String?;
  }
}

class ProtoOADealOffsetListReq extends ProtoMessage {
  ProtoOADealOffsetListReq(this.ctidTraderAccountId, this.dealId);
  ProtoOADealOffsetListReq.$empty();

  static const int type = 2185;

  late final int ctidTraderAccountId;
  late final int dealId;

  @override
  int get payloadType => type;

  @override
  Map<String, dynamic> $payload() => <String, dynamic>{
        'ctidTraderAccountId': ctidTraderAccountId,
        'dealId': dealId,
      };

  @override
  void $parse(Map<String, dynamic>? payload) {}
}

class ProtoOADealOffsetListRes extends ProtoMessage {
  ProtoOADealOffsetListRes.$empty();

  static const int type = 2186;

  late final int ctidTraderAccountId;
  List<ProtoOADealOffset> offsetBy = <ProtoOADealOffset>[];
  List<ProtoOADealOffset> offsetting = <ProtoOADealOffset>[];

  @override
  int get payloadType => type;

  @override
  Map<String, dynamic> $payload() => <String, dynamic>{};

  @override
  void $parse(Map<String, dynamic>? payload) {
    if (payload == null || payload.isEmpty) throw "Payload data can't be empty";

    ctidTraderAccountId = payload['ctidTraderAccountId'] as int;

    if (payload.containsKey('offsetBy')) {
      for (final dynamic o in payload['offsetBy']) {
        offsetBy.add(ProtoOADealOffset.$parse(o as Map<String, dynamic>));
      }
    }

    if (payload.containsKey('offsetting')) {
      for (final dynamic o in payload['offsetting']) {
        offsetting.add(ProtoOADealOffset.$parse(o as Map<String, dynamic>));
      }
    }
  }
}

class ProtoOAClosePositionReq extends ProtoMessage {
  ProtoOAClosePositionReq(this.ctidTraderAccountId, this.positionId, this.volume);
  ProtoOAClosePositionReq.$empty();

  static const int type = 2111;

  late final int ctidTraderAccountId;
  late final int positionId;
  late final int volume;

  @override
  int get payloadType => type;

  @override
  Map<String, dynamic> $payload() => <String, dynamic>{
        'ctidTraderAccountId': ctidTraderAccountId,
        'positionId': positionId,
        'volume': volume,
      };

  @override
  void $parse(Map<String, dynamic>? payload) {}
}

class ProtoOACancelOrderReq extends ProtoMessage {
  ProtoOACancelOrderReq(this.ctidTraderAccountId, this.orderId);
  ProtoOACancelOrderReq.$empty();

  static const int type = 2108;

  late final int ctidTraderAccountId;
  late final int orderId;

  @override
  int get payloadType => type;

  @override
  Map<String, dynamic> $payload() => <String, dynamic>{
        'ctidTraderAccountId': ctidTraderAccountId,
        'orderId': orderId,
      };

  @override
  void $parse(Map<String, dynamic>? payload) {}
}

class ProtoOAAmendPositionSLTPReq extends ProtoMessage {
  ProtoOAAmendPositionSLTPReq(this.ctidTraderAccountId, this.positionId);
  ProtoOAAmendPositionSLTPReq.$empty();

  static const int type = 2110;

  late final int ctidTraderAccountId;
  late final int positionId;
  double? stopLoss;
  double? takeProfit;
  bool? guaranteedStopLoss;
  bool? trailingStopLoss;
  ProtoOAOrderTriggerMethod? stopLossTriggerMethod;

  @override
  int get payloadType => type;

  @override
  Map<String, dynamic> $payload() => <String, dynamic>{
        'ctidTraderAccountId': ctidTraderAccountId,
        'positionId': positionId,
        'stopLoss': stopLoss,
        'takeProfit': takeProfit,
        'guaranteedStopLoss': guaranteedStopLoss,
        'trailingStopLoss': trailingStopLoss,
        'stopLossTriggerMethod': stopLossTriggerMethod,
      };

  @override
  void $parse(Map<String, dynamic>? payload) {}
}

class ProtoOAAmendOrderReq extends ProtoMessage {
  ProtoOAAmendOrderReq(this.ctidTraderAccountId, this.orderId, this.volume);
  ProtoOAAmendOrderReq.$emty();

  static const int type = 2109;

  late final int ctidTraderAccountId;
  late final int orderId;
  int? volume;
  double? limitPrice;
  double? stopPrice;
  int? expirationTimestamp;
  double? stopLoss;
  double? takeProfit;
  int? slippageInPoints;
  int? relativeStopLoss;
  int? relativeTakeProfit;
  bool? guaranteedStopLoss;
  bool? trailingStopLoss;
  ProtoOAOrderTriggerMethod? stopTriggerMethod;

  @override
  int get payloadType => type;

  @override
  Map<String, dynamic> $payload() => <String, dynamic>{
        'ctidTraderAccountId': ctidTraderAccountId,
        'orderId': orderId,
        'volume': volume,
        'limitPrice': limitPrice,
        'stopPrice': stopPrice,
        'expirationTimestamp': expirationTimestamp,
        'stopLoss': stopLoss,
        'takeProfit': takeProfit,
        'slippageInPoints': slippageInPoints,
        'relativeStopLoss': relativeStopLoss,
        'relativeTakeProfit': relativeTakeProfit,
        'guaranteedStopLoss': guaranteedStopLoss,
        'trailingStopLoss': trailingStopLoss,
        'stopTriggerMethod': stopTriggerMethod?.index,
      };

  @override
  void $parse(Map<String, dynamic>? payload) {}
}

class ProtoOATrailingSLChangedEvent extends ProtoMessage {
  ProtoOATrailingSLChangedEvent.$empty();

  static const int type = 2107;

  late final int ctidTraderAccountId;
  late final int positionId;
  late final int orderId;
  late final double stopPrice;
  late final int utcLastUpdateTimestamp;

  @override
  int get payloadType => type;

  @override
  Map<String, dynamic> $payload() => <String, dynamic>{};

  @override
  void $parse(Map<String, dynamic>? payload) {
    if (payload == null || payload.isEmpty) throw "Payload data can't be empty";

    ctidTraderAccountId = payload['ctidTraderAccountId'] as int;
    positionId = payload['positionId'] as int;
    orderId = payload['orderId'] as int;
    stopPrice = payload['stopPrice'] as double;
    utcLastUpdateTimestamp = payload['utcLastUpdateTimestamp'] as int;
  }
}

class ProtoOASymbolChangedEvent extends ProtoMessage {
  ProtoOASymbolChangedEvent.$empty();

  static const int type = 2120;

  late final int ctidTraderAccountId;
  final List<int> symbolId = [];

  @override
  int get payloadType => type;

  @override
  Map<String, dynamic> $payload() => <String, dynamic>{};

  @override
  void $parse(Map<String, dynamic>? payload) {
    if (payload == null) throw "Payload param can't be empty";

    ctidTraderAccountId = payload['ctidTraderAccountId'] as int;
    if (payload['symbolId'] != null) symbolId.addAll(List.from(payload['symbolId'] as List<dynamic>));
  }
}

class ProtoOATraderUpdatedEvent extends ProtoMessage {
  ProtoOATraderUpdatedEvent.$empty();

  static const int type = 2123;

  late final int ctidTraderAccountId;
  late final ProtoOATrader trader;

  @override
  int get payloadType => type;

  @override
  Map<String, dynamic> $payload() => <String, dynamic>{};

  @override
  void $parse(Map<String, dynamic>? payload) {
    if (payload == null) throw "Pyaload param can't be empty";

    ctidTraderAccountId = payload['ctidTraderAccountId'] as int;
    trader = ProtoOATrader.$parse(payload['trader'] as Map<String, dynamic>);
  }
}

class ProtoOAMarginChangedEvent extends ProtoMessage {
  ProtoOAMarginChangedEvent.$empty();

  static const int type = 2141;

  late final int ctidTraderAccountId;
  late final int positionId;
  late final int usedMargin;
  int? moneyDigits;

  @override
  int get payloadType => type;

  @override
  Map<String, dynamic> $payload() => <String, dynamic>{};

  @override
  void $parse(Map<String, dynamic>? payload) {
    if (payload == null) throw "Payload param can't be null";

    ctidTraderAccountId = payload['ctidTraderAccountId'] as int;
    positionId = payload['positionId'] as int;
    usedMargin = payload['usedMargin'] as int;
    moneyDigits = payload['moneyDigits'] as int?;
  }
}

class ProtoOASymbolsForConversionReq extends ProtoMessage {
  ProtoOASymbolsForConversionReq(this.ctidTraderAccountId, this.firstAssetId, this.lastAssetId);
  ProtoOASymbolsForConversionReq.$empty();

  static const int type = 2118;

  late final int ctidTraderAccountId;
  late final int firstAssetId;
  late final int lastAssetId;

  @override
  int get payloadType => type;

  @override
  Map<String, dynamic> $payload() => <String, dynamic>{
        'ctidTraderAccountId': ctidTraderAccountId,
        'firstAssetId': firstAssetId,
        'lastAssetId': lastAssetId,
      };

  @override
  void $parse(Map<String, dynamic>? payload) {}
}

class ProtoOASymbolsForConversionRes extends ProtoMessage {
  ProtoOASymbolsForConversionRes.$empty();

  static const int type = 2119;

  late final int ctidTraderAccountId;
  final List<ProtoOALightSymbol> symbol = [];

  @override
  int get payloadType => type;

  @override
  Map<String, dynamic> $payload() => <String, dynamic>{};

  @override
  void $parse(Map<String, dynamic>? payload) {
    if (payload == null) throw "Payload param can't be null";

    ctidTraderAccountId = payload['ctidTraderAccountId'] as int;
    if (payload['symbol'] != null) {
      symbol.addAll((payload['symbol'] as List<dynamic>).map((dynamic e) => ProtoOALightSymbol.$parse(e as Map<String, dynamic>)));
    }
  }
}

// FACTORY
final Map<int, ProtoMessage Function()> messageFactory = <int, ProtoMessage Function()>{
  ProtoHeartbeatEvent.type: ProtoHeartbeatEvent.$empty,
  ProtoOAErrorRes.type: ProtoOAErrorRes.$empty,
  ProtoOAApplicationAuthReq.type: ProtoOAApplicationAuthReq.$empty,
  ProtoOAApplicationAuthRes.type: ProtoOAApplicationAuthRes.$empty,
  ProtoOAAccountAuthReq.type: ProtoOAAccountAuthReq.$empty,
  ProtoOAAccountAuthRes.type: ProtoOAAccountAuthRes.$empty,
  ProtoOAGetAccountListByAccessTokenReq.type: ProtoOAGetAccountListByAccessTokenReq.$empty,
  ProtoOAGetAccountListByAccessTokenRes.type: ProtoOAGetAccountListByAccessTokenRes.$empty,
  ProtoOATraderReq.type: ProtoOATraderReq.$empty,
  ProtoOATraderRes.type: ProtoOATraderRes.$empty,
  ProtoOAReconcileReq.type: ProtoOAReconcileReq.$empty,
  ProtoOAReconcileRes.type: ProtoOAReconcileRes.$empty,
  ProtoOAExecutionEvent.type: ProtoOAExecutionEvent.$empty,
  ProtoOASymbolsListReq.type: ProtoOASymbolsListReq.$empty,
  ProtoOASymbolsListRes.type: ProtoOASymbolsListRes.$empty,
  ProtoOAAssetListReq.type: ProtoOAAssetListReq.$empty,
  ProtoOAAssetListRes.type: ProtoOAAssetListRes.$empty,
  ProtoOASymbolCategoryListReq.type: ProtoOASymbolCategoryListReq.$empty,
  ProtoOASymbolCategoryListRes.type: ProtoOASymbolCategoryListRes.$empty,
  ProtoOAAssetClassListReq.type: ProtoOAAssetClassListReq.$empty,
  ProtoOAAssetClassListRes.type: ProtoOAAssetClassListRes.$empty,
  ProtoOASubscribeSpotsReq.type: ProtoOASubscribeSpotsReq.$empty,
  ProtoOASubscribeSpotsRes.type: ProtoOASubscribeSpotsRes.$empty,
  ProtoOAUnsubscribeSpotsReq.type: ProtoOAUnsubscribeSpotsReq.$empty,
  ProtoOAUnsubscribeSpotsRes.type: ProtoOAUnsubscribeSpotsRes.$empty,
  ProtoOASpotEvent.type: ProtoOASpotEvent.$empty,
  ProtoOASymbolByIdReq.type: ProtoOASymbolByIdReq.$empty,
  ProtoOASymbolByIdRes.type: ProtoOASymbolByIdRes.$empty,
  ProtoOAGetDynamicLeverageByIDReq.type: ProtoOAGetDynamicLeverageByIDReq.$empty,
  ProtoOAGetDynamicLeverageByIDRes.type: ProtoOAGetDynamicLeverageByIDRes.$empty,
  ProtoOAGetTrendbarsReq.type: ProtoOAGetTrendbarsReq.$empty,
  ProtoOAGetTrendbarsRes.type: ProtoOAGetTrendbarsRes.$empty,
  ProtoOAExpectedMarginReq.type: ProtoOAExpectedMarginReq.$empty,
  ProtoOAExpectedMarginRes.type: ProtoOAExpectedMarginRes.$empty,
  ProtoOAAccountLogoutReq.type: ProtoOAAccountLogoutReq.$empty,
  ProtoOAAccountLogoutRes.type: ProtoOAAccountLogoutRes.$empty,
  ProtoOANewOrderReq.type: ProtoOANewOrderReq.$empty,
  ProtoOAGetPositionUnrealizedPnLReq.type: ProtoOAGetPositionUnrealizedPnLReq.$empty,
  ProtoOAGetPositionUnrealizedPnLRes.type: ProtoOAGetPositionUnrealizedPnLRes.$empty,
  ProtoOASubscribeLiveTrendbarReq.type: ProtoOASubscribeLiveTrendbarReq.$empty,
  ProtoOASubscribeLiveTrendbarRes.type: ProtoOASubscribeLiveTrendbarRes.$empty,
  ProtoOAUnsubscribeLiveTrendbarReq.type: ProtoOAUnsubscribeLiveTrendbarReq.$empty,
  ProtoOAUnsubscribeLiveTrendbarRes.type: ProtoOAUnsubscribeLiveTrendbarRes.$empty,
  ProtoOADealListReq.type: ProtoOADealListReq.$empty,
  ProtoOADealListRes.type: ProtoOADealListRes.$empty,
  ProtoOAOrderErrorEvent.type: ProtoOAOrderErrorEvent.$empty,
  ProtoOADealOffsetListReq.type: ProtoOADealOffsetListReq.$empty,
  ProtoOADealOffsetListRes.type: ProtoOADealOffsetListRes.$empty,
  ProtoOAClosePositionReq.type: ProtoOAClosePositionReq.$empty,
  ProtoOACancelOrderReq.type: ProtoOACancelOrderReq.$empty,
  ProtoOAAmendPositionSLTPReq.type: ProtoOAAmendPositionSLTPReq.$empty,
  ProtoOAAmendOrderReq.type: ProtoOAAmendOrderReq.$emty,
  ProtoOATrailingSLChangedEvent.type: ProtoOATrailingSLChangedEvent.$empty,
  ProtoOASymbolChangedEvent.type: ProtoOASymbolChangedEvent.$empty,
  ProtoOATraderUpdatedEvent.type: ProtoOATraderUpdatedEvent.$empty,
  ProtoOAMarginChangedEvent.type: ProtoOAMarginChangedEvent.$empty,
  ProtoOASymbolsForConversionReq.type: ProtoOASymbolsForConversionReq.$empty,
  ProtoOASymbolsForConversionRes.type: ProtoOASymbolsForConversionRes.$empty,
};
