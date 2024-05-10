import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:ctrader_example_app/extensions.dart';
import 'package:ctrader_example_app/l10n/localizations.dart';
import 'package:ctrader_example_app/logger.dart';
import 'package:ctrader_example_app/main.dart';
import 'package:ctrader_example_app/models/symbol_data.dart';
import 'package:ctrader_example_app/models/symbols_tree.dart';
import 'package:ctrader_example_app/models/trader_data.dart';
import 'package:ctrader_example_app/popups/popup.dart';
import 'package:ctrader_example_app/popups/popup_manager.dart';
import 'package:ctrader_example_app/remote/proto.dart' as proto;
import 'package:ctrader_example_app/remote/remote_api_manager.dart';
import 'package:ctrader_example_app/remote/spot_sub_manager.dart';
import 'package:ctrader_example_app/screens/account_screen.dart';
import 'package:ctrader_example_app/screens/activity_screen.dart';
import 'package:ctrader_example_app/screens/buy_sell_screen.dart';
import 'package:ctrader_example_app/screens/terms_screen.dart';
import 'package:ctrader_example_app/states/app_state.dart';
import 'package:ctrader_example_app/states/tutorial_state.dart';
import 'package:ctrader_example_app/states/user_state.dart';
import 'package:ctrader_example_app/utils.dart';
import 'package:ctrader_example_app/widgets/floating_pnl.dart';
import 'package:ctrader_example_app/widgets/mini_chart.dart';
import 'package:ctrader_example_app/widgets/side_menu.dart';
import 'package:ctrader_example_app/widgets/swipe_tutorial.dart';
import 'package:ctrader_example_app/widgets/symbol_buy_sell.dart';
import 'package:ctrader_example_app/widgets/wrapped_appbar.dart';
import 'package:ctrader_example_app/widgets/wrapped_scoll.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:visibility_detector/visibility_detector.dart';

final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  static const String ROUTE_NAME = '/market';

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  final ScrollController _scrollController = ScrollController();
  final Set<int> _visibleSymbols = <int>{};
  int _selectedClassIndex = 0;
  int _selectedSymbolId = -1;
  bool _isScrolling = false;
  Timer? _subscribeDelay;
  int _visibilityUpdTS = -1;

  @override
  void initState() {
    super.initState();

    final UserState userState = GetIt.I<UserState>();

    if (userState.marketCategoryId < -100) {
      _selectedClassIndex = userState.selectedTrader.tree.favoriteSymbolIds.isNotEmpty ? -1 : 0;
      _selectAssetClass(_selectedClassIndex);
    } else {
      _selectAssetClass(userState.marketCategoryId, userState.marketSymbolId);
      Timer.run(() => _scrollController.jumpTo(_scrollOffsetForSelectedSymbol()));
    }

    final AppState appState = GetIt.I<AppState>();
    if (!appState.isTermsChecked) {
      Timer.run(() async {
        final String jsonStr = await rootBundle.loadString('assets/json/app_terms.json');
        final Iterable<List<String>> terms = (jsonDecode(jsonStr) as List<dynamic>).cast<List<dynamic>>().map((List<dynamic> e) => e.cast<String>());

        bool? agreed;
        while (agreed == null) {
          final PopupResult result = await GetIt.I<PopupManager>().askToAgreeWithTerms(AppLocalizations.of(context)!);
          if (result.agree == true) {
            agreed = true;
          } else if (result.payload['showTerms'] == true) {
            agreed = await Navigator.push<bool?>(
              context,
              MaterialPageRoute<bool?>(builder: (BuildContext context) => TermsScreen(terms: terms)),
            );
          } else {
            agreed = false;
          }
        }

        if (agreed) {
          appState.markTermsChecked();
        } else {
          logout(context);
        }
      });
    }

    _unlockRotation();
  }

  @override
  void dispose() {
    _lockRotation();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final UserState userState = context.watch<UserState>();
    final AppState appState = context.watch<AppState>();
    final TutorialState tutorial = context.watch<TutorialState>();
    final Iterable<AssetClassData> assetClasses = userState.selectedTrader.tree.assetClasses;
    final SymbolData? selectedSymbol = userState.selectedTrader.tree.symbol(_selectedSymbolId);
    final TutorialSteps tutorialStep = tutorial.currentStep;

    if (appState.chartHeight < 120) {
      final double screenHeight = MediaQuery.of(context).size.height;
      Timer.run(() => appState.setChartHeight(screenHeight > 700 ? 250 : 180));
    }

    return WillPopScope(
      onWillPop: () => Future<bool>.value(false),
      child: OrientationBuilder(
        builder: (BuildContext context, Orientation orientation) {
          final bool isLandscape = orientation == Orientation.landscape;

          if (isLandscape) _disableRotationNotification();

          return SwipeTutorial(
            scaffolfKey: _scaffoldKey,
            direction: !isLandscape && appState.isTermsChecked && tutorial.visible
                ? (tutorialStep == TutorialSteps.swipeLeft ? AxisDirection.left : (tutorialStep == TutorialSteps.swipeRight ? AxisDirection.right : null))
                : null,
            child: Scaffold(
              key: _scaffoldKey,
              appBar: isLandscape ? null : WrappedAppBar(title: l10n.markets),
              drawer: isLandscape ? null : const SideMenu(),
              body: SafeArea(
                child: FloatingPnl(
                  child: GestureDetector(
                    onHorizontalDragUpdate: (DragUpdateDetails details) {
                      if (isLandscape) return;

                      if (details.delta.dx < -20) {
                        changePageWithSlideTransition(context, const Offset(1, 0), const AccountScreen());
                      } else if (details.delta.dx > 20) {
                        changePageWithSlideTransition(context, const Offset(-1, 0), const ActivityScreen());
                      }
                    },
                    child: LayoutBuilder(
                      builder: (BuildContext context, BoxConstraints constraints) {
                        return Stack(
                          alignment: Alignment.center,
                          children: <Widget>[
                            Column(
                              children: <Widget>[
                                if (!isLandscape) _assetClassSelector(assetClasses),
                                Flexible(
                                  flex: 1,
                                  fit: FlexFit.tight,
                                  child: WrappedScroll(
                                    controller: _scrollController,
                                    onScrollStarted: _scrollStarted,
                                    onScrollFinished: _scrollFinished,
                                    child: _selectedClassIndex == -1
                                        ? _favoritesList(l10n, userState.selectedTrader.tree.favoriteSymbols)
                                        : _symbolsList(l10n, assetClasses.elementAt(_selectedClassIndex)),
                                  ),
                                ),
                                if (appState.appStatus == AppStatus.ACTIVE)
                                  SizedBox(
                                    height: isLandscape ? constraints.maxHeight : appState.chartHeight,
                                    child: selectedSymbol == null
                                        ? Container()
                                        : MiniChart(
                                            symbol: selectedSymbol,
                                            showToolbar: orientation == Orientation.landscape,
                                            showRotNotif: tutorialStep == TutorialSteps.chartRotation && tutorial.visible,
                                            onTapCloseTip: _disableRotationNotification,
                                          ),
                                  ),
                              ],
                            ),
                            if (!isLandscape) _chartResizeButton(constraints),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _assetClassSelector(Iterable<AssetClassData> classes) {
    return SizedBox(
      height: 36,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: <Widget>[
            _assetClassItem(-1, AppLocalizations.of(context)!.favourites),
            for (int i = 0; i < classes.length; i++) classes.elementAt(i).hasEnabledSymbols ? _assetClassItem(i, classes.elementAt(i).name) : Container()
          ],
        ),
      ),
    );
  }

  Widget _assetClassItem(int index, String label) {
    final bool isSelected = index == _selectedClassIndex;
    final TextStyle text = isSelected
        ? THEME.texts.headingBold.copyWith(color: THEME.tabSelectorTextSelected())
        : THEME.texts.headingRegular.copyWith(color: THEME.tabSelectorText());
    final Color bg = isSelected ? THEME.tabSelectorBackgroundSelected() : THEME.tabSelectorBackground();

    return GestureDetector(
      onTap: () => _onTapAssetClassItem(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          border:
              isSelected ? Border(bottom: BorderSide(color: THEME.tabSelectorBorderSelected())) : Border(bottom: BorderSide(color: THEME.tabSelectorBorder())),
        ),
        child: Text(label, style: text),
      ),
    );
  }

  Widget _favoritesList(AppLocalizations l10n, Iterable<SymbolData> symbols) {
    if (symbols.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Text(
          l10n.placeholderFavoritesListEmpty,
          style: THEME.texts.bodyMediumSecondary,
          textAlign: TextAlign.center,
        ),
      );
    }

    final List<Widget> childs = <Widget>[];
    for (final SymbolData s in symbols) {
      if (s.enabled) childs.add(_symbolItem(l10n, s));
    }

    return Column(children: childs);
  }

  Widget _symbolsList(AppLocalizations l10n, AssetClassData assetClass) {
    final List<Widget> childs = <Widget>[];

    for (final SymbolCategoryData cat in assetClass.categories) {
      if (cat.hasEnabledSymbols) childs.addAll(_symbolsCategory(l10n, cat));
    }

    return Column(children: childs);
  }

  List<Widget> _symbolsCategory(AppLocalizations l10n, SymbolCategoryData category) {
    final List<Widget> elems = <Widget>[];

    if (category.assetClass.categories.length > 1) elems.add(_symbolCategoryTitle(category));

    if (!category.isCollapsed) {
      for (final SymbolData symbol in category.symbols) {
        if (symbol.enabled) elems.add(_symbolItem(l10n, symbol));
      }
    }

    return elems;
  }

  Widget _symbolCategoryTitle(SymbolCategoryData category) {
    return Container(
      height: 32,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: THEME.marektsGroupBackground(),
        border: Border(bottom: BorderSide(color: THEME.marketsGroupBorder())),
      ),
      child: Row(
        children: <Widget>[
          Text(category.name, style: THEME.texts.bodyBold.copyWith(color: THEME.marketsGroupText())),
          const Spacer(),
          GestureDetector(
            onTap: () => _toggleCategory(category.id),
            child: Container(
              color: Colors.transparent,
              alignment: Alignment.center,
              child: SizedBox(
                width: 16,
                height: 16,
                child: RotatedBox(
                  quarterTurns: category.isCollapsed ? 0 : 2,
                  child: SvgPicture.asset(
                    'assets/svg/triangle_down.svg',
                    width: 16,
                    height: 16,
                    colorFilter: THEME.marketsGroupIcon().asFilter,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _symbolItem(AppLocalizations l10n, SymbolData symbol) {
    return VisibilityDetector(
      key: Key('symbol_${symbol.id}'),
      onVisibilityChanged: (VisibilityInfo info) {
        if (info.visibleFraction > 0) {
          _visibleSymbols.add(symbol.id);
        } else {
          _visibleSymbols.remove(symbol.id);
        }
        _visibilityUpdTS = DateTime.now().millisecondsSinceEpoch;
        _updateSubscriptions();
      },
      child: SymbolBuySell(
        symbol: symbol,
        isSelected: symbol.id == _selectedSymbolId,
        showPositions: GetIt.I<AppState>().showOrdersInMarket,
        onSelect: () => _selectSymbol(symbol.id),
        onAction: (int? symbolId, bool isBuy) async {
          setState(() => _selectedSymbolId = symbol.id);

          if (GetIt.I<UserState>().selectedTrader.accessRights != proto.ProtoOAAccessRights.fullAccess) {
            final UserState userState = GetIt.I<UserState>();
            GetIt.I<PopupManager>().showTraderSelection(AppLocalizations.of(context)!, userState.selectedTrader, userState.traders.length > 1);
          } else if (symbol.details?.data.tradingMode == proto.ProtoOATradingMode.closeOnlyMode) {
            GetIt.I<PopupManager>().showPopup(
              title: l10n.limitedAccessPopupTitle,
              message: l10n.symbolHasLimitedAccessWithDescription,
            );
          } else if (symbol.details?.data.tradingMode == proto.ProtoOATradingMode.disabledWithPendingsExecution ||
              symbol.details?.data.tradingMode == proto.ProtoOATradingMode.disabledWithoutPendingsExecution) {
            GetIt.I<PopupManager>().showSymbolDisabledByTradingMode(l10n);
          } else if (!isBuy && symbol.details?.data.enableShortSelling == false) {
            GetIt.I<PopupManager>().showSymbolDisabledForShortTrading(l10n);
          } else {
            await Navigator.pushNamed(context, BuySellScreen.ROUTE_NAME, arguments: <String, dynamic>{'isBuy': isBuy, 'symbolId': symbol.id});
          }
        },
      ),
    );
  }

  Widget _chartResizeButton(BoxConstraints constraints) {
    final AppState appState = GetIt.I<AppState>();
    final double maxHeight = constraints.maxHeight * 0.7;

    return Positioned(
      bottom: context.watch<AppState>().chartHeight - 15,
      child: GestureDetector(
        onVerticalDragUpdate: (DragUpdateDetails details) {
          appState.setChartHeight(min(maxHeight, max(150, appState.chartHeight - details.delta.dy)));
        },
        child: Container(
          width: 42,
          height: 30,
          decoration: BoxDecoration(
            color: THEME.chartResizeButtonBackground(),
            borderRadius: BorderRadius.circular(32),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RotatedBox(
                quarterTurns: 2,
                child: SvgPicture.asset(
                  'assets/svg/triangle_down.svg',
                  width: 14,
                  colorFilter:
                      (appState.chartHeight >= maxHeight * 0.999 ? THEME.chartResizeButtonBackground() : THEME.chartResizeButtonOnBackground()).asFilter,
                ),
              ),
              const SizedBox(height: 2),
              SvgPicture.asset(
                'assets/svg/triangle_down.svg',
                width: 14,
                colorFilter: (appState.chartHeight == 150 ? THEME.chartResizeButtonBackground() : THEME.chartResizeButtonOnBackground()).asFilter,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectSymbol(int id) {
    _selectedSymbolId = id;
    GetIt.I<UserState>().setMarketSelects(_selectedClassIndex, _selectedSymbolId);
    setState(() {});
  }

  double _scrollOffsetForSelectedSymbol() {
    const double symbolHeight = 129;
    const double titleHeight = 32;
    const double activityHeight = 41;
    final TraderData trader = GetIt.I<UserState>().selectedTrader;
    double offset = 0;

    if (_selectedClassIndex == -1) {
      // favorites class
      final Iterable<int> symbolIds = trader.tree.favoriteSymbolIds;
      for (final int id in symbolIds) {
        if (id == _selectedSymbolId) return offset;

        final SymbolData? symbol = trader.tree.symbol(id);
        if (symbol != null && symbol.enabled) {
          offset += symbolHeight;
          offset += activityHeight * trader.positionsManager.activitiesBy(symbolId: id).length;
          offset += activityHeight * trader.ordersManager.activitiesBy(symbolId: id).length;
        }
      }
    } else {
      final AssetClassData assetClass = trader.tree.assetClasses.elementAt(_selectedClassIndex);
      for (final SymbolCategoryData category in assetClass.categories) {
        if (category.hasEnabledSymbols && assetClass.categories.length > 1) offset += titleHeight;

        if (!category.isCollapsed && category.hasEnabledSymbols) {
          for (final SymbolData symbol in category.symbols) {
            if (symbol.id == _selectedSymbolId) return offset;

            if (symbol.enabled) {
              offset += symbolHeight;
              offset += activityHeight * trader.positionsManager.activitiesBy(symbolId: symbol.id).length;
              offset += activityHeight * trader.ordersManager.activitiesBy(symbolId: symbol.id).length;
            }
          }
        }
      }
    }

    return 0;
  }

  void _selectAssetClass(int index, [int? symbolId]) {
    final UserState userState = GetIt.I<UserState>();

    _visibleSymbols.clear();
    _selectedClassIndex = index;

    List<int> symbolIds;
    if (_selectedClassIndex == -1) {
      symbolIds = userState.selectedTrader.tree.favoriteSymbolIds.toList();
      if (symbolId != null && symbolIds.contains(symbolId)) {
        _selectedSymbolId = symbolId;
      } else if (symbolIds.isNotEmpty) {
        _selectedSymbolId = symbolIds.first;
      }
    } else {
      final AssetClassData assetClass = userState.selectedTrader.tree.assetClasses.elementAt(_selectedClassIndex);
      symbolIds = assetClass.symbols.map((SymbolData e) => e.id).toList();

      if (symbolId != null && symbolIds.contains(symbolId)) {
        _selectedSymbolId = symbolId;
      } else {
        for (final SymbolCategoryData category in assetClass.categories) {
          if (!category.isCollapsed && category.hasEnabledSymbols) {
            _selectedSymbolId = category.symbols.firstWhere((SymbolData symbol) => symbol.enabled).id;
            break;
          }
        }
      }
    }

    userState.setMarketSelects(_selectedClassIndex, _selectedSymbolId);

    setState(() {});
  }

  void _onTapAssetClassItem(int index) {
    if (_scrollController.hasClients) _scrollController.jumpTo(0);

    _selectAssetClass(index);
  }

  void _unlockRotation() {
    SystemChrome.setPreferredOrientations(<DeviceOrientation>[
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  void _lockRotation() {
    SystemChrome.setPreferredOrientations(<DeviceOrientation>[
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
  }

  void _disableRotationNotification() {
    GetIt.I<TutorialState>().finishStep(TutorialSteps.chartRotation, withPause: true);
  }

  void _scrollStarted() {
    _isScrolling = true;
  }

  void _scrollFinished() {
    _isScrolling = false;
  }

  void _updateSubscriptions() {
    _subscribeDelay ??= Timer.periodic(const Duration(milliseconds: 100), (Timer timer) async {
      if (_isScrolling) return;

      if (DateTime.now().millisecondsSinceEpoch - _visibilityUpdTS > 300) {
        timer.cancel();
        _subscribeDelay = null;

        await _unsubscribeFromInvisibleSymbols();
        await _subscribeForVisibleSymbols();
      }
    });
  }

  Future<void> _unsubscribeFromInvisibleSymbols() async {
    final UserState userState = GetIt.I<UserState>();
    if (userState.selectedTraderId < 0) return;

    try {
      final TraderData trader = userState.selectedTrader;
      final SpotSubscriptionManager manager = GetIt.I<RemoteAPIManager>().getSpotSubscriptionManager(demo: trader.demo);
      final Iterable<int> symbols;
      if (mounted) {
        symbols = manager.subscribedSymbols.where((int id) => id != _selectedSymbolId && !_visibleSymbols.contains(id));
      } else {
        symbols = manager.subscribedSymbols.toList();
      }

      await manager.unsubscribe(trader.id, symbols.toList());
    } on proto.ProtoOAErrorRes catch (err) {
      Logger.log(() => 'Server error at symbol unsubsription process: #${err.errorCode}:${err.description}');
    } catch (err) {
      Logger.error('Error occurred at symbol unsubscription process', err);
    }
  }

  Future<void> _subscribeForVisibleSymbols() async {
    if (!mounted) return;

    final TraderData trader = GetIt.I<UserState>().selectedTrader;
    final RemoteAPIManager remoteManager = GetIt.I<RemoteAPIManager>();
    if (!remoteManager.getAPI(demo: trader.demo).isAutorized) return;

    try {
      await trader.subscriptionManagerApi.subscribe(trader.id, _visibleSymbols.toList());

      final Iterable<int> symbols = _visibleSymbols.where((int id) => trader.tree.symbol(id)?.details?.data == null);
      if (symbols.isNotEmpty) {
        GetIt.I<RemoteAPIManager>().getAPI(demo: trader.demo).sendSymbolById(trader.id, symbols.toList());
      }
    } on proto.ProtoOAErrorRes catch (e) {
      Logger.log(() => 'Server error at symbol subscription process: #${e.errorCode}:${e.description}');
      GetIt.I<PopupManager>().showError(AppLocalizations.of(context)!, '${e.errorCode}\n${e.description}');
    } catch (err) {
      Logger.error('Error occurred at symbol subscription process', err);
      GetIt.I<PopupManager>().showSomeErrorOccurred(AppLocalizations.of(context)!);
    }
  }

  void _toggleCategory(int categoryId) => GetIt.I<UserState>().toggleCategoryCollapse(categoryId);
}
