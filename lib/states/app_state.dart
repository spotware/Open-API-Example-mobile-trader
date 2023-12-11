import 'dart:convert';
import 'dart:math';

import 'package:ctrader_example_app/main.dart';
import 'package:ctrader_example_app/widgets/floating_pnl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppStateKeys { language, theme, pnlState, chartRotated, showOrders, chartHeight, moreAccountsWarnPopup, swipeTutorialStep, termsChecked, trTermsChecked }

enum AppStatus { ACTIVE, SLEEP }

class AppState extends ChangeNotifier {
  AppState() {
    _restoreState();
  }

  late final String remoteURL;
  late final String loginURL;
  late final String socketDemoURL;
  late final String socketLiveURL;
  late final String clientID;
  late final String clientSecret;

  Future<void> loadConfigs(String from) async {
    final String jsonStr = await rootBundle.loadString(from);
    final dynamic json = jsonDecode(jsonStr);

    clientID = json['id'] as String;
    clientSecret = json['secret'] as String;
    remoteURL = json['url'] as String;
    loginURL = json['login_url'] as String;
    socketDemoURL = json['socket_demo'] as String;
    socketLiveURL = json['socket_live'] as String;
  }

  ThemeType _themeType = ThemeType.dark;
  ThemeType get themeType => _themeType;
  void selectTheme(ThemeType type) {
    _themeType = type;

    _saveState();
    notifyListeners();
  }

  Locale _locale = const Locale('en');
  Locale get locale => _locale;
  void selectLang(Locale locale) {
    _locale = locale;
    _saveState();
    notifyListeners();
  }

  AppStatus _appStatus = AppStatus.ACTIVE;
  AppStatus get appStatus => _appStatus;
  void changeAppStatus(AppStatus status) {
    _appStatus = status;

    notifyListeners();
  }

  bool _isUIBlocked = false;
  bool get isUIBlocked => _isUIBlocked;
  void setUIBlocked(bool value) {
    _isUIBlocked = value;

    notifyListeners();
  }

  FloatingPnlState _floatingPnl = FloatingPnlState.small;
  FloatingPnlState get floatingPnlState => _floatingPnl;
  void setFloatingPnlState(FloatingPnlState state) {
    _floatingPnl = state;
    _saveState();
    notifyListeners();
  }

  bool _isChartRotated = false;
  bool get isChartRotated => _isChartRotated;
  void setChartRotated() {
    _isChartRotated = true;
    _saveState();
    notifyListeners();
  }

  bool _showOrdersInMarket = true;
  bool get showOrdersInMarket => _showOrdersInMarket;
  void setShowOrdersInMarkets(bool value) {
    _showOrdersInMarket = value;
    _saveState();
    notifyListeners();
  }

  double _chartHeight = 0;
  double get chartHeight => _chartHeight;
  void setChartHeight(double height) {
    _chartHeight = max(120, height);

    _saveState();
    notifyListeners();
  }

  bool _moreAccountsWarnPopupShowed = false;
  bool get moreAccountsWarnPopupShowed => _moreAccountsWarnPopupShowed;
  void setMoreAccountsWarnPopupShowed() {
    _moreAccountsWarnPopupShowed = true;
    _saveState();
  }

  int _swipeTutorialStep = -1;
  int get swipeTutorialStep => _swipeTutorialStep;
  void incrementSwipeTutorialStep([int? steps]) {
    _swipeTutorialStep += steps ?? 1;
    _saveState();

    notifyListeners();
  }

  bool _termsChecked = false;
  bool get isTermsChecked => _termsChecked;
  void markTermsChecked() {
    _termsChecked = true;
    _saveState();
    notifyListeners();
  }

  bool _trTermsChecked = false;
  bool get isTrTermsChecked => _trTermsChecked;
  void markTrTermsChecked() {
    _trTermsChecked = true;
    _saveState();
    notifyListeners();
  }

  Future<void> _saveState() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(AppStateKeys.language.toString(), _locale.languageCode);
    prefs.setInt(AppStateKeys.theme.toString(), _themeType.index);
    prefs.setInt(AppStateKeys.pnlState.toString(), _floatingPnl.index);
    prefs.setBool(AppStateKeys.chartRotated.toString(), _isChartRotated);
    prefs.setBool(AppStateKeys.showOrders.toString(), _showOrdersInMarket);
    prefs.setDouble(AppStateKeys.chartHeight.toString(), _chartHeight);
    prefs.setBool(AppStateKeys.moreAccountsWarnPopup.toString(), _moreAccountsWarnPopupShowed);
    prefs.setInt(AppStateKeys.swipeTutorialStep.toString(), _swipeTutorialStep);
    prefs.setBool(AppStateKeys.termsChecked.toString(), _termsChecked);
    prefs.setBool(AppStateKeys.trTermsChecked.toString(), _trTermsChecked);

  }

  Future<void> _restoreState() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _locale = Locale(prefs.getString(AppStateKeys.language.toString()) ?? 'en');
    _themeType = ThemeType.values.elementAt(prefs.getInt(AppStateKeys.theme.toString()) ?? _themeType.index);
    _floatingPnl = FloatingPnlState.values.elementAt(prefs.getInt(AppStateKeys.pnlState.toString()) ?? _floatingPnl.index);
    _isChartRotated = prefs.getBool(AppStateKeys.chartRotated.toString()) == true;
    _showOrdersInMarket = prefs.getBool(AppStateKeys.showOrders.toString()) ?? _showOrdersInMarket;
    _chartHeight = prefs.getDouble(AppStateKeys.chartHeight.toString()) ?? _chartHeight;
    _moreAccountsWarnPopupShowed = prefs.getBool(AppStateKeys.moreAccountsWarnPopup.toString()) == true;
    _swipeTutorialStep = prefs.getInt(AppStateKeys.swipeTutorialStep.toString()) ?? _swipeTutorialStep;
    _termsChecked = prefs.getBool(AppStateKeys.termsChecked.toString()) == true;
    _trTermsChecked = prefs.getBool(AppStateKeys.trTermsChecked.toString()) == true;

    notifyListeners();
  }
}
