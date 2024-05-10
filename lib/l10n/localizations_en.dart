import 'package:intl/intl.dart' as intl;

import 'localizations.dart';

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get sourcesAndDetails => 'Sources and Details';

  @override
  String get openAPI => 'Open API';

  @override
  String get loginSignInLable => 'To experience all the features offered by this app, please';

  @override
  String get loginSignInButton => 'Log In with cTrader Demo Account';

  @override
  String get dontHaveAnAccoutnYet => 'Do not have an account yet?';

  @override
  String get chooseBrokerFromFeaturesList => 'Choose any broker from our \'Featured Brokers\' list.';

  @override
  String continueWithBroker(String broker) {
    return 'Continue with $broker';
  }

  @override
  String get menu => 'Menu';

  @override
  String get helloTrader => 'Hello, Trader';

  @override
  String get markets => 'Markets';

  @override
  String get myAccound => 'My Accounts';

  @override
  String get myActivity => 'My Activity';

  @override
  String get manageAccount => 'Manage Accounts';

  @override
  String get logOut => 'Log Out';

  @override
  String get openApiSupport => 'Open API Support';

  @override
  String get account => 'Account';

  @override
  String get balanceLabel => 'Balance';

  @override
  String get equityLabel => 'Equity';

  @override
  String get marginLabel => 'Margin';

  @override
  String get freeMarginLabel => 'Free margin';

  @override
  String get marginLevelLabel => 'Margin level';

  @override
  String get unrNetPnlLabel => 'Unrealised net P&L';

  @override
  String get darkTheme => 'Dark theme';

  @override
  String get showOpenPositionsOrdersInMarketScreen => 'Show open positions or limit orders on the Market screens';

  @override
  String get allowSimultaneousTradingForAccounts => 'Allow simultaneous trading on multiple accounts';

  @override
  String get canYouCreateBetterApp => 'You can create a better app?';

  @override
  String get reuseOurCode => 'Reuse our code to save time.';

  @override
  String get buy => 'Buy';

  @override
  String get sell => 'Sell';

  @override
  String get placeholderFavoritesListEmpty => 'You still do not have any symbols in your \"Favourites\" list. Tap on the star icon on any symbol to add it to Favourites.';

  @override
  String get units => 'Units';

  @override
  String get pipPosition => 'Pip position';

  @override
  String get shortSelling => 'Short selling';

  @override
  String get notAllowed => 'Not allowed';

  @override
  String get leverage => 'Leverage';

  @override
  String get leverageTiers => 'Leverage Tiers';

  @override
  String get volumeUsd => 'Volume (in USD)';

  @override
  String dayOfWeek(String name) {
    String _temp0 = intl.Intl.selectLogic(
      name,
      {
        'monday': 'Monday',
        'tuesday': 'Tuesday',
        'wednesday': 'Wednesday',
        'thursday': 'Thursday',
        'friday': 'Friday',
        'saturday': 'Saturday',
        'sunday': 'Sunday',
        'other': 'n/a',
      },
    );
    return '$_temp0';
  }

  @override
  String dayOfWeekByNum(String weekDay) {
    String _temp0 = intl.Intl.selectLogic(
      weekDay,
      {
        '1': 'Monday',
        '2': 'Tuesday',
        '3': 'Wednesday',
        '4': 'Thursday',
        '5': 'Friday',
        '6': 'Saturday',
        '7': 'Sunday',
        'other': 'n/a',
      },
    );
    return '$_temp0';
  }

  @override
  String get swap3Days => '3 days swap';

  @override
  String swapPerLot(String value, String measerments, String type) {
    String _temp0 = intl.Intl.selectLogic(
      type,
      {
        'long': 'long',
        'other': 'short',
      },
    );
    return 'Swap per $value $measerments ($_temp0)';
  }

  @override
  String get pips => 'pip(s)';

  @override
  String get rolloverCommission3Days => '3-day rollover commission';

  @override
  String get rolloverCommission => 'Rollover commission';

  @override
  String get minOrder => 'Minimum order';

  @override
  String get maxOrder => 'Maximum order';

  @override
  String get commission => 'Commission';

  @override
  String get minCommission => 'Minimum commission';

  @override
  String get commissionUsdPerMillionUsd => 'USD per million USD volume';

  @override
  String commissionPercentageOfValue(String value) {
    return '$value% of trading volume';
  }

  @override
  String commissionUsdPerLot(String amount, String value, String units) {
    return '$amount USD per $value $units';
  }

  @override
  String commissionQuoteCcyPerLot(String amount, String currency, String lot, String units) {
    return '$amount $currency per $lot $units';
  }

  @override
  String get tradingHours => 'Trading Hours';

  @override
  String get tradingSchedule => 'Trading Schedule';

  @override
  String get holidays => 'Holidays';

  @override
  String get holiday => 'Holiday';

  @override
  String get nextHoliday => 'Next holiday';

  @override
  String get from => 'From';

  @override
  String get to => 'To';

  @override
  String get fromDate => 'From date';

  @override
  String get toDate => 'To date';

  @override
  String get date => 'Date';

  @override
  String get dateFrom => 'Date from';

  @override
  String get dateTo => 'Date to';

  @override
  String holidayDate(int day, String month) {
    String _temp0 = intl.Intl.selectLogic(
      month,
      {
        '1': 'Jan',
        '2': 'Feb',
        '3': 'Mar',
        '4': 'Apr',
        '5': 'May',
        '6': 'Jun',
        '7': 'Jul',
        '8': 'Aug',
        '9': 'Sep',
        '10': 'Oct',
        '11': 'Nov',
        '12': 'Dec',
        'other': '???',
      },
    );
    return '$day of $_temp0';
  }

  @override
  String get back => 'Back';

  @override
  String get expectedMargin => 'Expected margin';

  @override
  String get chartRotateTip => 'To see a full-screen chart with the menu, rotate the device';

  @override
  String buySellWhenRateIs(String name) {
    return '$name when rate is';
  }

  @override
  String get takeProfit => 'Take profit';

  @override
  String get stopLoss => 'Stop loss';

  @override
  String get trailingStop => 'Trailing stop';

  @override
  String get errorOccurred => 'Error occurred';

  @override
  String get someErrorOccurred => 'Action failed. Please try again later.';

  @override
  String get errorDescription => 'Error description:';

  @override
  String buySellSymbolPositionWas(String direction, String symbol, String action) {
    String _temp0 = intl.Intl.selectLogic(
      direction,
      {
        'buy': 'Buy',
        'sell': 'Sell',
        'other': 'Your',
      },
    );
    String _temp1 = intl.Intl.selectLogic(
      action,
      {
        'opened': 'opened',
        'increased': 'increased',
        'decreased': 'decreased',
        'reversed': 'reversed',
        'closed': 'closed',
        'closedPartially': 'partially closed',
        'rejected': 'rejected by market',
        'cancelled': 'cancelled by market',
        'updated': 'updated',
        'other': '???',
      },
    );
    return '$_temp0 $symbol position was $_temp1.';
  }

  @override
  String get amount => 'Amount';

  @override
  String get price => 'Price';

  @override
  String get positionId => 'Position ID';

  @override
  String get expectedProfit => 'Expected profit';

  @override
  String get expectedLoss => 'Expected loss';

  @override
  String get noLoginAccessPopupTitle => 'No Access';

  @override
  String get noLoginAccessPopupBody => 'Your account has no access to live trading. Please contact your broker for details.';

  @override
  String get limitedAccessPopupTitle => 'Limited Access';

  @override
  String get noTradingAccessPopupuBody => 'Your account has a view-only access. Please contact your broker for more details.';

  @override
  String get closeOnlyAccessPopupBody => 'Your account has limited access. You cannot create new orders, only close existing ones. Please contact your broker for more details.';

  @override
  String get spreadBettingPopupTitle => 'Unavailable Account Tpe';

  @override
  String get spreadBettingPopupBody => 'You have a spread-betting account. This app allows trading activities only for hedging or netting accounts. To continue, please open a suitable account with one of our partners.';

  @override
  String get successLoginPopupTitle => 'Success';

  @override
  String get successLoginPopupBody => 'You have successfully logged in.';

  @override
  String get yourAccount => 'Your account';

  @override
  String get yourBroker => 'Your broker';

  @override
  String get moreAccountAvailableInTab => 'Manage your accounts in the \"My Accounts\" section.';

  @override
  String get demo => 'Demo';

  @override
  String get live => 'Live';

  @override
  String get orderExecutionFailed => 'Order Execution Failed';

  @override
  String orderFillError(Object orderId) {
    return 'Your order $orderId could not be filled by the market. Please try again.';
  }

  @override
  String positionAction(String action) {
    String _temp0 = intl.Intl.selectLogic(
      action,
      {
        'increased': 'increased',
        'decreased': 'decreased',
        'reversed': 'reversed',
        'other': '???',
      },
    );
    return 'Position $_temp0';
  }

  @override
  String positionWas(String action) {
    String _temp0 = intl.Intl.selectLogic(
      action,
      {
        'opened': 'opened',
        'changed': 'changed',
        'closed': 'closed',
        'rejected': 'rejected',
        'cancelled': 'cancelled',
        'updated': 'updated',
        'other': '???',
      },
    );
    return 'Position was $_temp0';
  }

  @override
  String get filledAmount => 'Fill amount';

  @override
  String get totalAmount => 'Total amount';

  @override
  String get realizedPnl => 'Realized P&L';

  @override
  String get orderId => 'Order ID';

  @override
  String get distance => 'Distance:';

  @override
  String get cancelOrderBy => 'Cancel your order by';

  @override
  String pendingOrderState(String state) {
    String _temp0 = intl.Intl.selectLogic(
      state,
      {
        'created': 'created',
        'cancelled': 'cancelled',
        'cancelledPartially': 'cancelled partially',
        'rejected': 'rejected',
        'updated': 'updated',
        'expired': 'expired',
        'executed': 'executed',
        'executedPartially': 'partially executed',
        'other': '???',
      },
    );
    return 'Pending order $_temp0';
  }

  @override
  String buySellSymbolOrderState(String direction, String symbol, String state) {
    String _temp0 = intl.Intl.selectLogic(
      direction,
      {
        'buy': 'Buy',
        'sell': 'Sell',
        'other': '???',
      },
    );
    String _temp1 = intl.Intl.selectLogic(
      state,
      {
        'created': 'created',
        'cancelled': 'cancelled',
        'cancelledPartially': 'cancelled partially',
        'rejected': 'rejected by the broker',
        'updated': 'updated',
        'expired': 'expired',
        'other': '???',
      },
    );
    return '$_temp0 $symbol pending order was $_temp1.';
  }

  @override
  String get cancelled => 'Cancelled';

  @override
  String get positions => 'Positions';

  @override
  String get orders => 'Orders';

  @override
  String get closed => 'Closed';

  @override
  String get guaranteedStopLoss => 'Guaranteed stop loss';

  @override
  String get openTime => 'Opening time';

  @override
  String get edit => 'Edit';

  @override
  String get goodTill => 'Good till';

  @override
  String get creationTime => 'Creation time';

  @override
  String get tradingForSymbolClosed => 'Trading for this symbol is closed';

  @override
  String get transactionId => 'Transaction (deal) ID';

  @override
  String get relatedId => 'Related position ID';

  @override
  String get grossPnl => 'Gross P&L';

  @override
  String get swapCommission => 'Swap commission';

  @override
  String get closingTime => 'Closing time';

  @override
  String get showMore => 'Show More';

  @override
  String get closingPosition => 'Closing position';

  @override
  String reallyWantClosePosition(int id) {
    return 'Do you want to close the $id position?';
  }

  @override
  String get no => 'No';

  @override
  String get yes => 'Yes';

  @override
  String get cancelingOrder => 'Pending Order Cancellation';

  @override
  String reallyWantCancelOrder(int id) {
    return 'Do you want to cancel the $id pending order?';
  }

  @override
  String get editPosition => 'Edit Position';

  @override
  String get editOrder => 'Edit Pending Order';

  @override
  String get currentRate => 'Current rate';

  @override
  String get created => 'Created';

  @override
  String get rejected => 'Rejected';

  @override
  String get updated => 'Updated';

  @override
  String get expired => 'Expired';

  @override
  String get opened => 'Opened';

  @override
  String get openingPrice => 'Opening price';

  @override
  String get closingPrice => 'Closing price';

  @override
  String get eitherSLorTPRejected => 'Stop loss or take profit was rejected. Please try to set it up again.';

  @override
  String positionTemporaryClose(String direction, String symbol) {
    String _temp0 = intl.Intl.selectLogic(
      direction,
      {
        'buy': 'Buy',
        'sell': 'Sell',
        'other': '???',
      },
    );
    return '$_temp0 $symbol position was closed, but you still have pending orders related to this position.';
  }

  @override
  String get closedAmount => 'Closed amount';

  @override
  String get pendingAmount => 'Pending amount';

  @override
  String get stopOutClosure => 'Stop out closure';

  @override
  String buySellSymbolStopOut(String direction, String symbol, String partially) {
    String _temp0 = intl.Intl.selectLogic(
      direction,
      {
        'buy': 'Buy',
        'sell': 'Sell',
        'other': '',
      },
    );
    String _temp1 = intl.Intl.selectLogic(
      partially,
      {
        'true': 'partially',
        'other': '',
      },
    );
    return '$_temp0 $symbol position was $_temp1 closed by market, because you\'ve reached stop out level.';
  }

  @override
  String get attention => 'Attention';

  @override
  String orderWillBeCanceledBeforeNewOne(int orderId) {
    return 'You need to create a new order. It will be sent to the market only after the pending order $orderId is cancelled.';
  }

  @override
  String get positionExecutionRejected => 'Position Execution Rejected';

  @override
  String buySellSymbolPositionCantExecute(String direction, String symbol) {
    String _temp0 = intl.Intl.selectLogic(
      direction,
      {
        'buy': 'Buy',
        'sell': 'Sell',
        'other': '',
      },
    );
    return '$_temp0 $symbol position could not be executed by the market.';
  }

  @override
  String get closingPendingOrder => 'Pending Order Cancellation';

  @override
  String get close => 'Close';

  @override
  String get cancel => 'Cancel';

  @override
  String get noAccess => 'No access';

  @override
  String get noAccessToTradingContactBroker => 'Your account has no access to live trading. Please contact your broker for details.';

  @override
  String get limitedTradingAccess => 'Limited Trading Access';

  @override
  String get limitedTradingAccessDescription => 'To activate the option of simultaneous trading, you should have at least two accounts with full trading access. You can open a new trading account with any broker from our \'Featured Brokers\' list.';

  @override
  String accountsHasNoAccessToTradingContactBroker(Object amount) {
    return 'The following number of your accounts have no access to live trading: $amount. Please contact your broker for details.';
  }

  @override
  String get changeAccount => 'Account Change Requered';

  @override
  String get accountNotSutableForSultaneousTrading => 'This account is not suitable for simultaneous trading. Please choose an account with full access to trading.';

  @override
  String get save => 'Save';

  @override
  String get simultaniousTradingTooltip => 'Any orders created on the chosen account will be sent to other accounts chosen from this list. In case of rejection or cancellation, you will be notified.';

  @override
  String get simultaniousTradingTooltipNote => 'Please note that only accounts with full access to trading are suitable for simultaneous trading. Accounts with any limitations will not appear on the list for simultaneous trading.';

  @override
  String allowdForAmountAccounts(int amount) {
    return 'Allowed for: $amount accounts';
  }

  @override
  String get simultaneousTrading => 'Simultaneous Trading';

  @override
  String buySellSymbolSimultaneousActivity(String direction, String symbol, String type) {
    String _temp0 = intl.Intl.selectLogic(
      direction,
      {
        'buy': 'Buy',
        'sell': 'Sell',
        'other': '',
      },
    );
    String _temp1 = intl.Intl.selectLogic(
      type,
      {
        'deal': 'deal',
        'order': 'order',
        'other': '',
      },
    );
    return '$_temp0 $symbol $_temp1 will be executed for following accounts:';
  }

  @override
  String get dontShowAgain => 'Do not show again';

  @override
  String get forYesOnly => 'for \"Yes\" only';

  @override
  String get incompleteMatching => 'Match Incomplete';

  @override
  String symbolNotFoundForAccounts(String symbol) {
    return '$symbol was not found on the following accounts:';
  }

  @override
  String simultaneousApplyChanges(String type) {
    String _temp0 = intl.Intl.selectLogic(
      type,
      {
        'position': 'A position',
        'order': 'An order',
        'other': '???',
      },
    );
    return '$_temp0 with the same details was previously opened for other accounts:';
  }

  @override
  String get applyChangesOnOtherAccounts => 'Would you like to apply these changes to other accounts?';

  @override
  String get onlyForThisAccount => 'No, only for this account';

  @override
  String nowYourPositinBuySellSymbol(String type, String symbol) {
    String _temp0 = intl.Intl.selectLogic(
      type,
      {
        'buy': 'Buy',
        'sell': 'Sell',
        'other': '',
      },
    );
    return 'Now your position is $_temp0 $symbol';
  }

  @override
  String get incorrectChoice => 'Choose Accounts';

  @override
  String get simultaneousChoose2Accounts => 'To activate the option of simultaneous trading, please choose at least 2 accounts.';

  @override
  String get simultaneousDisablingAllLinksWillBeDeleted => 'You still have linked positions or pending orders from previous simultaneous trading activity. If you disable this option, all links will be deleted. Do you want to continue?';

  @override
  String get noActivePositions => 'There are no active positions on this account.';

  @override
  String get noActiveOrders => 'There are no active orders on this account.';

  @override
  String get swipeLeftTutorial => 'Swipe left for quicker navigation between screens';

  @override
  String get swipeRightTutorial => 'Swipe right for quicker access to the menu';

  @override
  String get expected => 'Expected:';

  @override
  String get currently => 'Currently';

  @override
  String get tradingDisableForSymbolWithDescription => 'Trading is disabled for this symbol. It is in a view-only mode. Please contact your broker for more details.';

  @override
  String get symbolHasLimitedAccessWithDescription => 'This symbol has limited access: you cannot create new orders, but only close or edit existing ones. Please contact your broker for more details.';

  @override
  String get symbolDisabledForShortTrading => 'This symbol is disabled for short trading.';

  @override
  String get broker => 'Broker';

  @override
  String get someErrorOccuredTryLater => 'Action failed. Please try again later.';

  @override
  String executionFailedForBroker(String broker) {
    return 'Execution Failed for $broker';
  }

  @override
  String tradingConditionsPlaformNotAllowExecuteOrder(String symbol, String broker) {
    return 'Trading conditions for $symbol with the $broker platform did not allow execution of the given order.';
  }

  @override
  String get tradingRoom => 'Trading Room';

  @override
  String get warning => 'Warning';

  @override
  String get simultaneousIncludeBothAccountTypes => 'You included both hedging and netting account types. Having more than one order for a symbol at any given moment might lead to different outcomes.';

  @override
  String get specialThanks => 'Special Recognition';

  @override
  String get tradingHistory => 'Trading History';

  @override
  String get noRecentHistory => 'No recent trading activity was found. Choose \"Load More\" to get trading history for a longer period.';

  @override
  String get allHistoryLoaded => 'All history was loaded';

  @override
  String get serverErrorNoQuotes => 'Trading cannot be done since no quotes are available.';

  @override
  String get serverErrorNotEnoughMoney => 'There is not enough funds on your account to execute this order.';

  @override
  String get serverErrorPositionLocked => 'Position is locked and cannot be modified or closed. Please contact your broker for details.';

  @override
  String get serverErrorTradingBadVolume => 'Order cannot be executed with the specified volume.';

  @override
  String get serverErrorProtectionIsTooCloseToMarket => 'Stop loss cannot be set for this order. Please try to set it at a different rate.';

  @override
  String get serverErrorTradingDisabled => 'Trading was disabled for this account. Please contact your broker for more details.';

  @override
  String get serverErrorUnableToCancelOrder => 'Order cannot be cancelled. Please try later.';

  @override
  String get serverErrorUnabkeToAmendOrder => 'Order cannot be edited. Please try later.';

  @override
  String get noTermsFound => 'No terms found';

  @override
  String get waitPlease => 'Please wait';

  @override
  String get pnl => 'P&L';

  @override
  String get cantGetSymbolDetails => 'Cannot get symbol details.';

  @override
  String get favourites => 'Favourites';

  @override
  String loadingDataForAcc(int account) {
    return 'Loading data for $account';
  }

  @override
  String get demoAccountRequired => 'Demo account required';

  @override
  String get loginWithDemoAccount => 'No trading accounts found. Please check that you have at least one cTrader account for the email address provided.\n\nIf you have just registered with cTrader, please open a verification email and follow the instructions to open a demo account.';

  @override
  String get toContinue => 'To continue';

  @override
  String get readAndAgreeTermsFirst => 'To continue, please accept our #link.';

  @override
  String get readAndAgreeLinkName => 'Terms and Conditions';

  @override
  String get agree => 'Agree';

  @override
  String get reject => 'Reject';

  @override
  String get contactCtraderSupportForQuestions => 'Contact cTrader Open API\nsupport for questions';

  @override
  String get noAccounts => 'No Accounts';

  @override
  String get noAccountsFoundVerifyEmail => 'No trading accounts were found. Please verify that you have at least one cTrader account for provided email.\n\nIf you have just registered with cTrader, please open a verification email and follow the instructions to open a demo account.';
}
