import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'localizations_en.dart';

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en')
  ];

  /// No description provided for @sourcesAndDetails.
  ///
  /// In en, this message translates to:
  /// **'Sources and Details'**
  String get sourcesAndDetails;

  /// No description provided for @openAPI.
  ///
  /// In en, this message translates to:
  /// **'Open API'**
  String get openAPI;

  /// No description provided for @loginSignInLable.
  ///
  /// In en, this message translates to:
  /// **'To experience all the features offered by this app, please'**
  String get loginSignInLable;

  /// No description provided for @loginSignInButton.
  ///
  /// In en, this message translates to:
  /// **'Log In with cTrader Demo Account'**
  String get loginSignInButton;

  /// No description provided for @dontHaveAnAccoutnYet.
  ///
  /// In en, this message translates to:
  /// **'Do not have an account yet?'**
  String get dontHaveAnAccoutnYet;

  /// No description provided for @chooseBrokerFromFeaturesList.
  ///
  /// In en, this message translates to:
  /// **'Choose any broker from our \'\'Featured Brokers\'\' list.'**
  String get chooseBrokerFromFeaturesList;

  /// No description provided for @continueWithBroker.
  ///
  /// In en, this message translates to:
  /// **'Continue with {broker}'**
  String continueWithBroker(String broker);

  /// No description provided for @menu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// No description provided for @helloTrader.
  ///
  /// In en, this message translates to:
  /// **'Hello, Trader'**
  String get helloTrader;

  /// No description provided for @markets.
  ///
  /// In en, this message translates to:
  /// **'Markets'**
  String get markets;

  /// No description provided for @myAccound.
  ///
  /// In en, this message translates to:
  /// **'My Accounts'**
  String get myAccound;

  /// No description provided for @myActivity.
  ///
  /// In en, this message translates to:
  /// **'My Activity'**
  String get myActivity;

  /// No description provided for @manageAccount.
  ///
  /// In en, this message translates to:
  /// **'Manage Accounts'**
  String get manageAccount;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logOut;

  /// No description provided for @openApiSupport.
  ///
  /// In en, this message translates to:
  /// **'Open API Support'**
  String get openApiSupport;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @balanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get balanceLabel;

  /// No description provided for @equityLabel.
  ///
  /// In en, this message translates to:
  /// **'Equity'**
  String get equityLabel;

  /// No description provided for @marginLabel.
  ///
  /// In en, this message translates to:
  /// **'Margin'**
  String get marginLabel;

  /// No description provided for @freeMarginLabel.
  ///
  /// In en, this message translates to:
  /// **'Free margin'**
  String get freeMarginLabel;

  /// No description provided for @marginLevelLabel.
  ///
  /// In en, this message translates to:
  /// **'Margin level'**
  String get marginLevelLabel;

  /// No description provided for @unrNetPnlLabel.
  ///
  /// In en, this message translates to:
  /// **'Unrealised net P&L'**
  String get unrNetPnlLabel;

  /// No description provided for @darkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark theme'**
  String get darkTheme;

  /// No description provided for @showOpenPositionsOrdersInMarketScreen.
  ///
  /// In en, this message translates to:
  /// **'Show open positions or limit orders on the Market screens'**
  String get showOpenPositionsOrdersInMarketScreen;

  /// No description provided for @allowSimultaneousTradingForAccounts.
  ///
  /// In en, this message translates to:
  /// **'Allow simultaneous trading on multiple accounts'**
  String get allowSimultaneousTradingForAccounts;

  /// No description provided for @canYouCreateBetterApp.
  ///
  /// In en, this message translates to:
  /// **'You can create a better app?'**
  String get canYouCreateBetterApp;

  /// No description provided for @reuseOurCode.
  ///
  /// In en, this message translates to:
  /// **'Reuse our code to save time.'**
  String get reuseOurCode;

  /// No description provided for @buy.
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get buy;

  /// No description provided for @sell.
  ///
  /// In en, this message translates to:
  /// **'Sell'**
  String get sell;

  /// No description provided for @placeholderFavoritesListEmpty.
  ///
  /// In en, this message translates to:
  /// **'You still do not have any symbols in your \"Favourites\" list. Tap on the star icon on any symbol to add it to Favourites.'**
  String get placeholderFavoritesListEmpty;

  /// No description provided for @units.
  ///
  /// In en, this message translates to:
  /// **'Units'**
  String get units;

  /// No description provided for @pipPosition.
  ///
  /// In en, this message translates to:
  /// **'Pip position'**
  String get pipPosition;

  /// No description provided for @shortSelling.
  ///
  /// In en, this message translates to:
  /// **'Short selling'**
  String get shortSelling;

  /// No description provided for @notAllowed.
  ///
  /// In en, this message translates to:
  /// **'Not allowed'**
  String get notAllowed;

  /// No description provided for @leverage.
  ///
  /// In en, this message translates to:
  /// **'Leverage'**
  String get leverage;

  /// No description provided for @leverageTiers.
  ///
  /// In en, this message translates to:
  /// **'Leverage Tiers'**
  String get leverageTiers;

  /// No description provided for @volumeUsd.
  ///
  /// In en, this message translates to:
  /// **'Volume (in USD)'**
  String get volumeUsd;

  /// No description provided for @dayOfWeek.
  ///
  /// In en, this message translates to:
  /// **'{name, select, monday{Monday} tuesday{Tuesday} wednesday{Wednesday} thursday{Thursday} friday{Friday} saturday{Saturday} sunday{Sunday} other{n/a}}'**
  String dayOfWeek(String name);

  /// No description provided for @dayOfWeekByNum.
  ///
  /// In en, this message translates to:
  /// **'{weekDay, select, 1{Monday} 2{Tuesday} 3{Wednesday} 4{Thursday} 5{Friday} 6{Saturday} 7{Sunday} other{n/a}}'**
  String dayOfWeekByNum(String weekDay);

  /// No description provided for @swap3Days.
  ///
  /// In en, this message translates to:
  /// **'3 days swap'**
  String get swap3Days;

  /// No description provided for @swapPerLot.
  ///
  /// In en, this message translates to:
  /// **'Swap per {value} {measerments} ({type, select, long{long} other{short}})'**
  String swapPerLot(String value, String measerments, String type);

  /// No description provided for @pips.
  ///
  /// In en, this message translates to:
  /// **'pip(s)'**
  String get pips;

  /// No description provided for @rolloverCommission3Days.
  ///
  /// In en, this message translates to:
  /// **'3-day rollover commission'**
  String get rolloverCommission3Days;

  /// No description provided for @rolloverCommission.
  ///
  /// In en, this message translates to:
  /// **'Rollover commission'**
  String get rolloverCommission;

  /// No description provided for @minOrder.
  ///
  /// In en, this message translates to:
  /// **'Minimum order'**
  String get minOrder;

  /// No description provided for @maxOrder.
  ///
  /// In en, this message translates to:
  /// **'Maximum order'**
  String get maxOrder;

  /// No description provided for @commission.
  ///
  /// In en, this message translates to:
  /// **'Commission'**
  String get commission;

  /// No description provided for @minCommission.
  ///
  /// In en, this message translates to:
  /// **'Minimum commission'**
  String get minCommission;

  /// No description provided for @commissionUsdPerMillionUsd.
  ///
  /// In en, this message translates to:
  /// **'USD per million USD volume'**
  String get commissionUsdPerMillionUsd;

  /// No description provided for @commissionPercentageOfValue.
  ///
  /// In en, this message translates to:
  /// **'{value}% of trading volume'**
  String commissionPercentageOfValue(String value);

  /// No description provided for @commissionUsdPerLot.
  ///
  /// In en, this message translates to:
  /// **'{amount} USD per {value} {units}'**
  String commissionUsdPerLot(String amount, String value, String units);

  /// No description provided for @commissionQuoteCcyPerLot.
  ///
  /// In en, this message translates to:
  /// **'{amount} {currency} per {lot} {units}'**
  String commissionQuoteCcyPerLot(String amount, String currency, String lot, String units);

  /// No description provided for @tradingHours.
  ///
  /// In en, this message translates to:
  /// **'Trading Hours'**
  String get tradingHours;

  /// No description provided for @tradingSchedule.
  ///
  /// In en, this message translates to:
  /// **'Trading Schedule'**
  String get tradingSchedule;

  /// No description provided for @holidays.
  ///
  /// In en, this message translates to:
  /// **'Holidays'**
  String get holidays;

  /// No description provided for @holiday.
  ///
  /// In en, this message translates to:
  /// **'Holiday'**
  String get holiday;

  /// No description provided for @nextHoliday.
  ///
  /// In en, this message translates to:
  /// **'Next holiday'**
  String get nextHoliday;

  /// No description provided for @from.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get from;

  /// No description provided for @to.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get to;

  /// No description provided for @fromDate.
  ///
  /// In en, this message translates to:
  /// **'From date'**
  String get fromDate;

  /// No description provided for @toDate.
  ///
  /// In en, this message translates to:
  /// **'To date'**
  String get toDate;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @dateFrom.
  ///
  /// In en, this message translates to:
  /// **'Date from'**
  String get dateFrom;

  /// No description provided for @dateTo.
  ///
  /// In en, this message translates to:
  /// **'Date to'**
  String get dateTo;

  /// No description provided for @holidayDate.
  ///
  /// In en, this message translates to:
  /// **'{day} of {month, select, 1{Jan} 2{Feb} 3{Mar} 4{Apr} 5{May} 6{Jun} 7{Jul} 8{Aug} 9{Sep} 10{Oct} 11{Nov} 12{Dec} other{???}}'**
  String holidayDate(int day, String month);

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @expectedMargin.
  ///
  /// In en, this message translates to:
  /// **'Expected margin'**
  String get expectedMargin;

  /// No description provided for @chartRotateTip.
  ///
  /// In en, this message translates to:
  /// **'To see a full-screen chart with the menu, rotate the device'**
  String get chartRotateTip;

  /// No description provided for @buySellWhenRateIs.
  ///
  /// In en, this message translates to:
  /// **'{name} when rate is'**
  String buySellWhenRateIs(String name);

  /// No description provided for @takeProfit.
  ///
  /// In en, this message translates to:
  /// **'Take profit'**
  String get takeProfit;

  /// No description provided for @stopLoss.
  ///
  /// In en, this message translates to:
  /// **'Stop loss'**
  String get stopLoss;

  /// No description provided for @trailingStop.
  ///
  /// In en, this message translates to:
  /// **'Trailing stop'**
  String get trailingStop;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'Error occurred'**
  String get errorOccurred;

  /// No description provided for @someErrorOccurred.
  ///
  /// In en, this message translates to:
  /// **'Action failed. Please try again later.'**
  String get someErrorOccurred;

  /// No description provided for @errorDescription.
  ///
  /// In en, this message translates to:
  /// **'Error description:'**
  String get errorDescription;

  /// No description provided for @buySellSymbolPositionWas.
  ///
  /// In en, this message translates to:
  /// **'{direction, select, buy{Buy} sell{Sell} other{Your}} {symbol} position was {action, select, opened{opened} increased{increased} decreased{decreased} reversed{reversed} closed{closed} closedPartially{partially closed} rejected{rejected by market} cancelled{cancelled by market} updated{updated} other{???}}.'**
  String buySellSymbolPositionWas(String direction, String symbol, String action);

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @positionId.
  ///
  /// In en, this message translates to:
  /// **'Position ID'**
  String get positionId;

  /// No description provided for @expectedProfit.
  ///
  /// In en, this message translates to:
  /// **'Expected profit'**
  String get expectedProfit;

  /// No description provided for @expectedLoss.
  ///
  /// In en, this message translates to:
  /// **'Expected loss'**
  String get expectedLoss;

  /// No description provided for @noLoginAccessPopupTitle.
  ///
  /// In en, this message translates to:
  /// **'No Access'**
  String get noLoginAccessPopupTitle;

  /// No description provided for @noLoginAccessPopupBody.
  ///
  /// In en, this message translates to:
  /// **'Your account has no access to live trading. Please contact your broker for details.'**
  String get noLoginAccessPopupBody;

  /// No description provided for @limitedAccessPopupTitle.
  ///
  /// In en, this message translates to:
  /// **'Limited Access'**
  String get limitedAccessPopupTitle;

  /// No description provided for @noTradingAccessPopupuBody.
  ///
  /// In en, this message translates to:
  /// **'Your account has a view-only access. Please contact your broker for more details.'**
  String get noTradingAccessPopupuBody;

  /// No description provided for @closeOnlyAccessPopupBody.
  ///
  /// In en, this message translates to:
  /// **'Your account has limited access. You cannot create new orders, only close existing ones. Please contact your broker for more details.'**
  String get closeOnlyAccessPopupBody;

  /// No description provided for @spreadBettingPopupTitle.
  ///
  /// In en, this message translates to:
  /// **'Unavailable Account Tpe'**
  String get spreadBettingPopupTitle;

  /// No description provided for @spreadBettingPopupBody.
  ///
  /// In en, this message translates to:
  /// **'You have a spread-betting account. This app allows trading activities only for hedging or netting accounts. To continue, please open a suitable account with one of our partners.'**
  String get spreadBettingPopupBody;

  /// No description provided for @successLoginPopupTitle.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get successLoginPopupTitle;

  /// No description provided for @successLoginPopupBody.
  ///
  /// In en, this message translates to:
  /// **'You have successfully logged in.'**
  String get successLoginPopupBody;

  /// No description provided for @yourAccount.
  ///
  /// In en, this message translates to:
  /// **'Your account'**
  String get yourAccount;

  /// No description provided for @yourBroker.
  ///
  /// In en, this message translates to:
  /// **'Your broker'**
  String get yourBroker;

  /// No description provided for @moreAccountAvailableInTab.
  ///
  /// In en, this message translates to:
  /// **'Manage your accounts in the \"My Accounts\" section.'**
  String get moreAccountAvailableInTab;

  /// No description provided for @demo.
  ///
  /// In en, this message translates to:
  /// **'Demo'**
  String get demo;

  /// No description provided for @live.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get live;

  /// No description provided for @orderExecutionFailed.
  ///
  /// In en, this message translates to:
  /// **'Order Execution Failed'**
  String get orderExecutionFailed;

  /// No description provided for @orderFillError.
  ///
  /// In en, this message translates to:
  /// **'Your order {orderId} could not be filled by the market. Please try again.'**
  String orderFillError(Object orderId);

  /// No description provided for @positionAction.
  ///
  /// In en, this message translates to:
  /// **'Position {action, select, increased{increased} decreased{decreased} reversed{reversed} other{???}}'**
  String positionAction(String action);

  /// No description provided for @positionWas.
  ///
  /// In en, this message translates to:
  /// **'Position was {action, select, opened{opened} changed{changed} closed{closed} rejected{rejected} cancelled{cancelled} updated{updated} other{???}}'**
  String positionWas(String action);

  /// No description provided for @filledAmount.
  ///
  /// In en, this message translates to:
  /// **'Fill amount'**
  String get filledAmount;

  /// No description provided for @totalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total amount'**
  String get totalAmount;

  /// No description provided for @realizedPnl.
  ///
  /// In en, this message translates to:
  /// **'Realized P&L'**
  String get realizedPnl;

  /// No description provided for @orderId.
  ///
  /// In en, this message translates to:
  /// **'Order ID'**
  String get orderId;

  /// No description provided for @distance.
  ///
  /// In en, this message translates to:
  /// **'Distance:'**
  String get distance;

  /// No description provided for @cancelOrderBy.
  ///
  /// In en, this message translates to:
  /// **'Cancel your order by'**
  String get cancelOrderBy;

  /// No description provided for @pendingOrderState.
  ///
  /// In en, this message translates to:
  /// **'Pending order {state, select, created{created} cancelled{cancelled} cancelledPartially{cancelled partially} rejected{rejected} updated{updated} expired{expired} executed{executed} executedPartially{partially executed} other{???}}'**
  String pendingOrderState(String state);

  /// No description provided for @buySellSymbolOrderState.
  ///
  /// In en, this message translates to:
  /// **'{direction, select, buy{Buy} sell{Sell} other{???}} {symbol} pending order was {state, select, created{created} cancelled{cancelled} cancelledPartially{cancelled partially} rejected{rejected by the broker} updated{updated} expired{expired} other{???}}.'**
  String buySellSymbolOrderState(String direction, String symbol, String state);

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// No description provided for @positions.
  ///
  /// In en, this message translates to:
  /// **'Positions'**
  String get positions;

  /// No description provided for @orders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get orders;

  /// No description provided for @closed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get closed;

  /// No description provided for @guaranteedStopLoss.
  ///
  /// In en, this message translates to:
  /// **'Guaranteed stop loss'**
  String get guaranteedStopLoss;

  /// No description provided for @openTime.
  ///
  /// In en, this message translates to:
  /// **'Opening time'**
  String get openTime;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @goodTill.
  ///
  /// In en, this message translates to:
  /// **'Good till'**
  String get goodTill;

  /// No description provided for @creationTime.
  ///
  /// In en, this message translates to:
  /// **'Creation time'**
  String get creationTime;

  /// No description provided for @tradingForSymbolClosed.
  ///
  /// In en, this message translates to:
  /// **'Trading for this symbol is closed'**
  String get tradingForSymbolClosed;

  /// No description provided for @transactionId.
  ///
  /// In en, this message translates to:
  /// **'Transaction (deal) ID'**
  String get transactionId;

  /// No description provided for @relatedId.
  ///
  /// In en, this message translates to:
  /// **'Related position ID'**
  String get relatedId;

  /// No description provided for @grossPnl.
  ///
  /// In en, this message translates to:
  /// **'Gross P&L'**
  String get grossPnl;

  /// No description provided for @swapCommission.
  ///
  /// In en, this message translates to:
  /// **'Swap commission'**
  String get swapCommission;

  /// No description provided for @closingTime.
  ///
  /// In en, this message translates to:
  /// **'Closing time'**
  String get closingTime;

  /// No description provided for @showMore.
  ///
  /// In en, this message translates to:
  /// **'Show More'**
  String get showMore;

  /// No description provided for @closingPosition.
  ///
  /// In en, this message translates to:
  /// **'Closing position'**
  String get closingPosition;

  /// No description provided for @reallyWantClosePosition.
  ///
  /// In en, this message translates to:
  /// **'Do you want to close the {id} position?'**
  String reallyWantClosePosition(int id);

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @cancelingOrder.
  ///
  /// In en, this message translates to:
  /// **'Pending Order Cancellation'**
  String get cancelingOrder;

  /// No description provided for @reallyWantCancelOrder.
  ///
  /// In en, this message translates to:
  /// **'Do you want to cancel the {id} pending order?'**
  String reallyWantCancelOrder(int id);

  /// No description provided for @editPosition.
  ///
  /// In en, this message translates to:
  /// **'Edit Position'**
  String get editPosition;

  /// No description provided for @editOrder.
  ///
  /// In en, this message translates to:
  /// **'Edit Pending Order'**
  String get editOrder;

  /// No description provided for @currentRate.
  ///
  /// In en, this message translates to:
  /// **'Current rate'**
  String get currentRate;

  /// No description provided for @created.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get created;

  /// No description provided for @rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejected;

  /// No description provided for @updated.
  ///
  /// In en, this message translates to:
  /// **'Updated'**
  String get updated;

  /// No description provided for @expired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get expired;

  /// No description provided for @opened.
  ///
  /// In en, this message translates to:
  /// **'Opened'**
  String get opened;

  /// No description provided for @openingPrice.
  ///
  /// In en, this message translates to:
  /// **'Opening price'**
  String get openingPrice;

  /// No description provided for @closingPrice.
  ///
  /// In en, this message translates to:
  /// **'Closing price'**
  String get closingPrice;

  /// No description provided for @eitherSLorTPRejected.
  ///
  /// In en, this message translates to:
  /// **'Stop loss or take profit was rejected. Please try to set it up again.'**
  String get eitherSLorTPRejected;

  /// No description provided for @positionTemporaryClose.
  ///
  /// In en, this message translates to:
  /// **'{direction, select, buy{Buy} sell{Sell} other{???}} {symbol} position was closed, but you still have pending orders related to this position.'**
  String positionTemporaryClose(String direction, String symbol);

  /// No description provided for @closedAmount.
  ///
  /// In en, this message translates to:
  /// **'Closed amount'**
  String get closedAmount;

  /// No description provided for @pendingAmount.
  ///
  /// In en, this message translates to:
  /// **'Pending amount'**
  String get pendingAmount;

  /// No description provided for @stopOutClosure.
  ///
  /// In en, this message translates to:
  /// **'Stop out closure'**
  String get stopOutClosure;

  /// No description provided for @buySellSymbolStopOut.
  ///
  /// In en, this message translates to:
  /// **'{direction, select, buy{Buy} sell{Sell} other{}} {symbol} position was {partially, select, true{partially} other{}} closed by market, because you\'\'ve reached stop out level.'**
  String buySellSymbolStopOut(String direction, String symbol, String partially);

  /// No description provided for @attention.
  ///
  /// In en, this message translates to:
  /// **'Attention'**
  String get attention;

  /// No description provided for @orderWillBeCanceledBeforeNewOne.
  ///
  /// In en, this message translates to:
  /// **'You need to create a new order. It will be sent to the market only after the pending order {orderId} is cancelled.'**
  String orderWillBeCanceledBeforeNewOne(int orderId);

  /// No description provided for @positionExecutionRejected.
  ///
  /// In en, this message translates to:
  /// **'Position Execution Rejected'**
  String get positionExecutionRejected;

  /// No description provided for @buySellSymbolPositionCantExecute.
  ///
  /// In en, this message translates to:
  /// **'{direction, select, buy{Buy} sell{Sell} other{}} {symbol} position could not be executed by the market.'**
  String buySellSymbolPositionCantExecute(String direction, String symbol);

  /// No description provided for @closingPendingOrder.
  ///
  /// In en, this message translates to:
  /// **'Pending Order Cancellation'**
  String get closingPendingOrder;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @noAccess.
  ///
  /// In en, this message translates to:
  /// **'No access'**
  String get noAccess;

  /// No description provided for @noAccessToTradingContactBroker.
  ///
  /// In en, this message translates to:
  /// **'Your account has no access to live trading. Please contact your broker for details.'**
  String get noAccessToTradingContactBroker;

  /// No description provided for @limitedTradingAccess.
  ///
  /// In en, this message translates to:
  /// **'Limited Trading Access'**
  String get limitedTradingAccess;

  /// No description provided for @limitedTradingAccessDescription.
  ///
  /// In en, this message translates to:
  /// **'To activate the option of simultaneous trading, you should have at least two accounts with full trading access. You can open a new trading account with any broker from our \'\'Featured Brokers\'\' list.'**
  String get limitedTradingAccessDescription;

  /// No description provided for @accountsHasNoAccessToTradingContactBroker.
  ///
  /// In en, this message translates to:
  /// **'The following number of your accounts have no access to live trading: {amount}. Please contact your broker for details.'**
  String accountsHasNoAccessToTradingContactBroker(Object amount);

  /// No description provided for @changeAccount.
  ///
  /// In en, this message translates to:
  /// **'Account Change Requered'**
  String get changeAccount;

  /// No description provided for @accountNotSutableForSultaneousTrading.
  ///
  /// In en, this message translates to:
  /// **'This account is not suitable for simultaneous trading. Please choose an account with full access to trading.'**
  String get accountNotSutableForSultaneousTrading;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @simultaniousTradingTooltip.
  ///
  /// In en, this message translates to:
  /// **'Any orders created on the chosen account will be sent to other accounts chosen from this list. In case of rejection or cancellation, you will be notified.'**
  String get simultaniousTradingTooltip;

  /// No description provided for @simultaniousTradingTooltipNote.
  ///
  /// In en, this message translates to:
  /// **'Please note that only accounts with full access to trading are suitable for simultaneous trading. Accounts with any limitations will not appear on the list for simultaneous trading.'**
  String get simultaniousTradingTooltipNote;

  /// No description provided for @allowdForAmountAccounts.
  ///
  /// In en, this message translates to:
  /// **'Allowed for: {amount} accounts'**
  String allowdForAmountAccounts(int amount);

  /// No description provided for @simultaneousTrading.
  ///
  /// In en, this message translates to:
  /// **'Simultaneous Trading'**
  String get simultaneousTrading;

  /// No description provided for @buySellSymbolSimultaneousActivity.
  ///
  /// In en, this message translates to:
  /// **'{direction, select, buy{Buy} sell{Sell} other{}} {symbol} {type, select, deal{deal} order{order} other{}} will be executed for following accounts:'**
  String buySellSymbolSimultaneousActivity(String direction, String symbol, String type);

  /// No description provided for @dontShowAgain.
  ///
  /// In en, this message translates to:
  /// **'Do not show again'**
  String get dontShowAgain;

  /// No description provided for @forYesOnly.
  ///
  /// In en, this message translates to:
  /// **'for \"Yes\" only'**
  String get forYesOnly;

  /// No description provided for @incompleteMatching.
  ///
  /// In en, this message translates to:
  /// **'Match Incomplete'**
  String get incompleteMatching;

  /// No description provided for @symbolNotFoundForAccounts.
  ///
  /// In en, this message translates to:
  /// **'{symbol} was not found on the following accounts:'**
  String symbolNotFoundForAccounts(String symbol);

  /// No description provided for @simultaneousApplyChanges.
  ///
  /// In en, this message translates to:
  /// **'{type, select, position{A position} order{An order} other{???}} with the same details was previously opened for other accounts:'**
  String simultaneousApplyChanges(String type);

  /// No description provided for @applyChangesOnOtherAccounts.
  ///
  /// In en, this message translates to:
  /// **'Would you like to apply these changes to other accounts?'**
  String get applyChangesOnOtherAccounts;

  /// No description provided for @onlyForThisAccount.
  ///
  /// In en, this message translates to:
  /// **'No, only for this account'**
  String get onlyForThisAccount;

  /// No description provided for @nowYourPositinBuySellSymbol.
  ///
  /// In en, this message translates to:
  /// **'Now your position is {type, select, buy{Buy} sell{Sell} other{}} {symbol}'**
  String nowYourPositinBuySellSymbol(String type, String symbol);

  /// No description provided for @incorrectChoice.
  ///
  /// In en, this message translates to:
  /// **'Choose Accounts'**
  String get incorrectChoice;

  /// No description provided for @simultaneousChoose2Accounts.
  ///
  /// In en, this message translates to:
  /// **'To activate the option of simultaneous trading, please choose at least 2 accounts.'**
  String get simultaneousChoose2Accounts;

  /// No description provided for @simultaneousDisablingAllLinksWillBeDeleted.
  ///
  /// In en, this message translates to:
  /// **'You still have linked positions or pending orders from previous simultaneous trading activity. If you disable this option, all links will be deleted. Do you want to continue?'**
  String get simultaneousDisablingAllLinksWillBeDeleted;

  /// No description provided for @noActivePositions.
  ///
  /// In en, this message translates to:
  /// **'There are no active positions on this account.'**
  String get noActivePositions;

  /// No description provided for @noActiveOrders.
  ///
  /// In en, this message translates to:
  /// **'There are no active orders on this account.'**
  String get noActiveOrders;

  /// No description provided for @swipeLeftTutorial.
  ///
  /// In en, this message translates to:
  /// **'Swipe left for quicker navigation between screens'**
  String get swipeLeftTutorial;

  /// No description provided for @swipeRightTutorial.
  ///
  /// In en, this message translates to:
  /// **'Swipe right for quicker access to the menu'**
  String get swipeRightTutorial;

  /// No description provided for @expected.
  ///
  /// In en, this message translates to:
  /// **'Expected:'**
  String get expected;

  /// No description provided for @currently.
  ///
  /// In en, this message translates to:
  /// **'Currently'**
  String get currently;

  /// No description provided for @tradingDisableForSymbolWithDescription.
  ///
  /// In en, this message translates to:
  /// **'Trading is disabled for this symbol. It is in a view-only mode. Please contact your broker for more details.'**
  String get tradingDisableForSymbolWithDescription;

  /// No description provided for @symbolHasLimitedAccessWithDescription.
  ///
  /// In en, this message translates to:
  /// **'This symbol has limited access: you cannot create new orders, but only close or edit existing ones. Please contact your broker for more details.'**
  String get symbolHasLimitedAccessWithDescription;

  /// No description provided for @symbolDisabledForShortTrading.
  ///
  /// In en, this message translates to:
  /// **'This symbol is disabled for short trading.'**
  String get symbolDisabledForShortTrading;

  /// No description provided for @broker.
  ///
  /// In en, this message translates to:
  /// **'Broker'**
  String get broker;

  /// No description provided for @someErrorOccuredTryLater.
  ///
  /// In en, this message translates to:
  /// **'Action failed. Please try again later.'**
  String get someErrorOccuredTryLater;

  /// No description provided for @executionFailedForBroker.
  ///
  /// In en, this message translates to:
  /// **'Execution Failed for {broker}'**
  String executionFailedForBroker(String broker);

  /// No description provided for @tradingConditionsPlaformNotAllowExecuteOrder.
  ///
  /// In en, this message translates to:
  /// **'Trading conditions for {symbol} with the {broker} platform did not allow execution of the given order.'**
  String tradingConditionsPlaformNotAllowExecuteOrder(String symbol, String broker);

  /// No description provided for @tradingRoom.
  ///
  /// In en, this message translates to:
  /// **'Trading Room'**
  String get tradingRoom;

  /// No description provided for @warning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// No description provided for @simultaneousIncludeBothAccountTypes.
  ///
  /// In en, this message translates to:
  /// **'You included both hedging and netting account types. Having more than one order for a symbol at any given moment might lead to different outcomes.'**
  String get simultaneousIncludeBothAccountTypes;

  /// No description provided for @specialThanks.
  ///
  /// In en, this message translates to:
  /// **'Special Recognition'**
  String get specialThanks;

  /// No description provided for @tradingHistory.
  ///
  /// In en, this message translates to:
  /// **'Trading History'**
  String get tradingHistory;

  /// No description provided for @noRecentHistory.
  ///
  /// In en, this message translates to:
  /// **'No recent trading activity was found. Choose \"Load More\" to get trading history for a longer period.'**
  String get noRecentHistory;

  /// No description provided for @allHistoryLoaded.
  ///
  /// In en, this message translates to:
  /// **'All history was loaded'**
  String get allHistoryLoaded;

  /// No description provided for @serverErrorNoQuotes.
  ///
  /// In en, this message translates to:
  /// **'Trading cannot be done since no quotes are available.'**
  String get serverErrorNoQuotes;

  /// No description provided for @serverErrorNotEnoughMoney.
  ///
  /// In en, this message translates to:
  /// **'There is not enough funds on your account to execute this order.'**
  String get serverErrorNotEnoughMoney;

  /// No description provided for @serverErrorPositionLocked.
  ///
  /// In en, this message translates to:
  /// **'Position is locked and cannot be modified or closed. Please contact your broker for details.'**
  String get serverErrorPositionLocked;

  /// No description provided for @serverErrorTradingBadVolume.
  ///
  /// In en, this message translates to:
  /// **'Order cannot be executed with the specified volume.'**
  String get serverErrorTradingBadVolume;

  /// No description provided for @serverErrorProtectionIsTooCloseToMarket.
  ///
  /// In en, this message translates to:
  /// **'Stop loss cannot be set for this order. Please try to set it at a different rate.'**
  String get serverErrorProtectionIsTooCloseToMarket;

  /// No description provided for @serverErrorTradingDisabled.
  ///
  /// In en, this message translates to:
  /// **'Trading was disabled for this account. Please contact your broker for more details.'**
  String get serverErrorTradingDisabled;

  /// No description provided for @serverErrorUnableToCancelOrder.
  ///
  /// In en, this message translates to:
  /// **'Order cannot be cancelled. Please try later.'**
  String get serverErrorUnableToCancelOrder;

  /// No description provided for @serverErrorUnabkeToAmendOrder.
  ///
  /// In en, this message translates to:
  /// **'Order cannot be edited. Please try later.'**
  String get serverErrorUnabkeToAmendOrder;

  /// No description provided for @noTermsFound.
  ///
  /// In en, this message translates to:
  /// **'No terms found'**
  String get noTermsFound;

  /// No description provided for @waitPlease.
  ///
  /// In en, this message translates to:
  /// **'Please wait'**
  String get waitPlease;

  /// No description provided for @pnl.
  ///
  /// In en, this message translates to:
  /// **'P&L'**
  String get pnl;

  /// No description provided for @cantGetSymbolDetails.
  ///
  /// In en, this message translates to:
  /// **'Cannot get symbol details.'**
  String get cantGetSymbolDetails;

  /// No description provided for @favourites.
  ///
  /// In en, this message translates to:
  /// **'Favourites'**
  String get favourites;

  /// No description provided for @loadingDataForAcc.
  ///
  /// In en, this message translates to:
  /// **'Loading data for {account}'**
  String loadingDataForAcc(int account);

  /// No description provided for @demoAccountRequired.
  ///
  /// In en, this message translates to:
  /// **'Demo account required'**
  String get demoAccountRequired;

  /// No description provided for @loginWithDemoAccount.
  ///
  /// In en, this message translates to:
  /// **'No trading accounts found. Please check that you have at least one cTrader account for the email address provided.\n\nIf you have just registered with cTrader, please open a verification email and follow the instructions to open a demo account.'**
  String get loginWithDemoAccount;

  /// No description provided for @toContinue.
  ///
  /// In en, this message translates to:
  /// **'To continue'**
  String get toContinue;

  /// No description provided for @readAndAgreeTermsFirst.
  ///
  /// In en, this message translates to:
  /// **'To continue, please accept our #link.'**
  String get readAndAgreeTermsFirst;

  /// No description provided for @readAndAgreeLinkName.
  ///
  /// In en, this message translates to:
  /// **'Terms and Conditions'**
  String get readAndAgreeLinkName;

  /// No description provided for @agree.
  ///
  /// In en, this message translates to:
  /// **'Agree'**
  String get agree;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @contactCtraderSupportForQuestions.
  ///
  /// In en, this message translates to:
  /// **'Contact cTrader Open API\nsupport for questions'**
  String get contactCtraderSupportForQuestions;

  /// No description provided for @noAccounts.
  ///
  /// In en, this message translates to:
  /// **'No Accounts'**
  String get noAccounts;

  /// No description provided for @noAccountsFoundVerifyEmail.
  ///
  /// In en, this message translates to:
  /// **'No trading accounts were found. Please verify that you have at least one cTrader account for provided email.\n\nIf you have just registered with cTrader, please open a verification email and follow the instructions to open a demo account.'**
  String get noAccountsFoundVerifyEmail;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
