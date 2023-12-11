import 'package:ctrader_example_app/extensions.dart';
import 'package:ctrader_example_app/l10n/localizations.dart';
import 'package:ctrader_example_app/main.dart';
import 'package:ctrader_example_app/models/trader_data.dart';
import 'package:ctrader_example_app/popups/popup.dart';
import 'package:ctrader_example_app/popups/popup_constants.dart' as popup_constants;
import 'package:ctrader_example_app/popups/popup_manager.dart';
import 'package:ctrader_example_app/remote/proto.dart';
import 'package:ctrader_example_app/screens/activity_screen.dart';
import 'package:ctrader_example_app/screens/market_screen.dart';
import 'package:ctrader_example_app/states/app_state.dart';
import 'package:ctrader_example_app/states/simultaneous_trading_state.dart';
import 'package:ctrader_example_app/states/user_state.dart';
import 'package:ctrader_example_app/utils.dart';
import 'package:ctrader_example_app/widgets/button_primary.dart';
import 'package:ctrader_example_app/widgets/button_secondary.dart';
import 'package:ctrader_example_app/widgets/side_menu.dart';
import 'package:ctrader_example_app/widgets/wrapped_appbar.dart';
import 'package:ctrader_example_app/widgets/wrapped_checkbox.dart';
import 'package:ctrader_example_app/widgets/wrapped_dropdown.dart';
import 'package:ctrader_example_app/widgets/wrapped_switch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  static const String ROUTE_NAME = '/account';

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  late final List<TraderData> _traders;
  bool _isAllowSimultaneousTrading = false;
  final List<TraderData> _simultaniousAccounts = <TraderData>[];
  final List<int> _simultaniousSelectedAccounts = <int>[];

  @override
  void initState() {
    super.initState();

    _traders = GetIt.I<UserState>().traders.toList();

    _isAllowSimultaneousTrading = GetIt.I<SimultaneousTrdaingState>().enabled;
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final AppState appState = context.watch<AppState>();
    final UserState userState = context.watch<UserState>();
    final int selectedTraderIndex = _traders.indexWhere((TraderData t) => t.id == userState.selectedTraderId);
    final TraderData trader = _traders[selectedTraderIndex];

    return WillPopScope(
      onWillPop: () => Future<bool>.value(false),
      child: Scaffold(
        appBar: WrappedAppBar(title: l10n.myAccound),
        drawer: const SideMenu(),
        body: GestureDetector(
          onHorizontalDragUpdate: (DragUpdateDetails details) {
            if (details.delta.dx < -20) {
              changePageWithSlideTransition(context, const Offset(1, 0), const ActivityScreen());
            } else if (details.delta.dx > 20) {
              changePageWithSlideTransition(context, const Offset(-1, 0), const MarketScreen());
            }
          },
          child: _wrapWithApiSupportLine(
            l10n,
            Column(
              children: <Widget>[
                _welcomeLine(l10n),
                _divider(),
                _selectAccountDropdownLine(l10n, selectedTraderIndex),
                _divider(),
                Expanded(
                  child: ListView(
                    children: <Widget>[
                      _accountInfo(l10n, trader),
                      _divider(),
                      _themeSelectorLine(l10n, appState),
                      _divider(),
                      _showPositionsSelectorLine(l10n, appState),
                      _divider(),
                      _showAllowSimulteneousTradingSelectorLine(l10n),
                      if (_isAllowSimultaneousTrading) _simultaneousSection(l10n),
                      _divider(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _divider() => Divider(color: THEME.dividerLight(), height: 1);

  Widget _welcomeLine(AppLocalizations l10n) {
    return Container(
      height: 54,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(l10n.helloTrader, style: THEME.texts.headingBold),
    );
  }

  Widget _selectAccountDropdownLine(AppLocalizations l10n, int selectedTraderIndex) {
    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(l10n.account, style: THEME.texts.headingSmall),
          const SizedBox(width: 12),
          Expanded(
            child: WrappedDropdown(
              selected: selectedTraderIndex,
              items: _traders.map((TraderData t) => '${t.demo ? l10n.demo : l10n.live}: ${t.login} - ${t.name}').toList(),
              onChange: _onChangeAccount,
            ),
          ),
        ],
      ),
    );
  }

  Widget _accountInfo(AppLocalizations l10n, TraderData trader) {
    final Color? pnlColor = trader.pnl > 0 ? THEME.green : (trader.pnl < 0 ? THEME.red : null);

    return Stack(
      children: <Widget>[
        Column(children: <Widget>[
          const SizedBox(height: 8),
          _accountInfoLine(l10n.balanceLabel, trader.formattedMoneyWithCurrency(cents: trader.balance)),
          _accountInfoLine(l10n.equityLabel, trader.formattedMoneyWithCurrency(cents: trader.equity)),
          _accountInfoLine(l10n.marginLabel, trader.formattedMoneyWithCurrency(cents: trader.margin)),
          _accountInfoLine(l10n.freeMarginLabel, trader.formattedMoneyWithCurrency(cents: trader.freeMargin)),
          _accountInfoLine(l10n.marginLevelLabel, '${trader.formattedMarginLevel}%'),
          _accountInfoLine(l10n.unrNetPnlLabel, trader.formattedMoneyWithCurrency(cents: trader.pnl), pnlColor),
          const SizedBox(height: 8),
        ]),
      ],
    );
  }

  Widget _accountInfoLine(String label, String value, [Color? color]) {
    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: <Widget>[
          Text(label, style: THEME.texts.bodyMediumSecondary),
          const Spacer(),
          Text(value, style: THEME.texts.bodyMediumSecondary.copyWith(color: color)),
        ],
      ),
    );
  }

  Widget _themeSelectorLine(AppLocalizations l10n, AppState appState) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: <Widget>[
          Text(l10n.darkTheme, style: THEME.texts.headingBold),
          const Spacer(),
          WrappedSwitch(
            selected: appState.themeType == ThemeType.dark,
            onChange: (bool v) => appState.selectTheme(v ? ThemeType.dark : ThemeType.light),
          )
        ],
      ),
    );
  }

  Widget _showPositionsSelectorLine(AppLocalizations l10n, AppState appState) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(children: <Widget>[
        Expanded(
          child: Text(
            l10n.showOpenPositionsOrdersInMarketScreen,
            style: THEME.texts.headingBold,
            softWrap: true,
          ),
        ),
        Container(
          width: 46,
          alignment: Alignment.centerRight,
          child: WrappedSwitch(
            selected: appState.showOrdersInMarket,
            onChange: (bool v) => setState(() => appState.setShowOrdersInMarkets(v)),
          ),
        ),
      ]),
    );
  }

  Widget _showAllowSimulteneousTradingSelectorLine(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(children: <Widget>[
        Expanded(child: Text(l10n.allowSimultaneousTradingForAccounts, style: THEME.texts.headingBold)),
        Container(
          width: 46,
          alignment: Alignment.centerRight,
          child: WrappedSwitch(
            selected: _isAllowSimultaneousTrading,
            onChange: _toggleSimulteniousTradingSelector,
          ),
        ),
      ]),
    );
  }

  Widget _simultaneousSection(AppLocalizations l10n) {
    return Column(children: <Widget>[
      if (GetIt.I<SimultaneousTrdaingState>().enabled)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          height: 46,
          child: Row(
            children: <Widget>[
              Text(
                l10n.allowdForAmountAccounts(GetIt.I<SimultaneousTrdaingState>().pariedAccounts.length),
                style: THEME.texts.bodyBold,
              ),
              const Spacer(),
              GestureDetector(
                onTap: _onTapEditSimultaneousList,
                child: Container(
                  alignment: Alignment.center,
                  color: Colors.transparent,
                  constraints: BoxConstraints.tight(const Size.square(23)),
                  child: SvgPicture.asset(
                    'assets/svg/edit_position.svg',
                    height: 20,
                    width: 20,
                    colorFilter: THEME.onBackground().asFilter,
                  ),
                ),
              ),
            ],
          ),
        ),
      for (final TraderData acc in _simultaniousAccounts) _simultaneousAccountLine(l10n, acc),
      if (_simultaniousAccounts.isNotEmpty)
        SizedBox(
          height: 56,
          child: Row(
            children: <Widget>[
              const SizedBox(width: 16),
              Flexible(
                flex: 1,
                child: GestureDetector(
                  onTap: () => GetIt.I<PopupManager>().showPopup(message: '${l10n.simultaniousTradingTooltip}\n\n${l10n.simultaniousTradingTooltipNote}\n'),
                  child: Container(
                    alignment: Alignment.centerLeft,
                    color: Colors.transparent,
                    child: Container(
                      constraints: BoxConstraints.tight(const Size.square(32)),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: THEME.buttonInfoBackground(),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: SvgPicture.asset(
                        'assets/svg/circle_i.svg',
                        width: 18,
                        colorFilter: THEME.buttonInfoOnBackground().asFilter,
                      ),
                    ),
                  ),
                ),
              ),
              ButtonPrimary(label: l10n.save, flex: 1, height: 32, onTap: _onTapSaveSimultaneous),
              const SizedBox(width: 16),
            ],
          ),
        ),
      const SizedBox(height: 8),
    ]);
  }

  Widget _simultaneousAccountLine(AppLocalizations l10n, TraderData account) {
    final bool isSelected = _simultaniousSelectedAccounts.contains(account.id);

    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Flex(
        direction: Axis.horizontal,
        children: <Widget>[
          Expanded(
              child: Row(children: <Widget>[
            Container(
              alignment: Alignment.center,
              constraints: const BoxConstraints.tightFor(width: 56, height: 26),
              decoration: BoxDecoration(
                color: account.demo ? THEME.green : THEME.red,
                borderRadius: BorderRadius.circular(2),
              ),
              child: Text(account.demo ? l10n.demo : l10n.live, style: THEME.texts.bodyBold.copyWith(color: Colors.white)),
            ),
            const SizedBox(width: 16),
            Flexible(
              flex: 2,
              fit: FlexFit.loose,
              child: Text(
                '${account.login} · ${account.name}',
                style: THEME.texts.headingBold,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ])),
          WrappedCheckbox(
              selected: isSelected,
              disabled: account.id == GetIt.I<UserState>().selectedTraderId,
              onTap: () {
                setState(() {
                  if (isSelected) {
                    if (account.id != GetIt.I<UserState>().selectedTraderId) {
                      _simultaniousSelectedAccounts.remove(account.id);
                    }
                  } else {
                    _simultaniousSelectedAccounts.add(account.id);
                  }
                });
              }),
        ],
      ),
    );
  }

  Widget _wrapWithApiSupportLine(AppLocalizations l10n, Widget child) {
    return Column(
      children: <Widget>[
        Expanded(child: child),
        _apiSupportLine(l10n),
      ],
    );
  }

  Widget _apiSupportLine(AppLocalizations l10n) {
    return GestureDetector(
      onTap: () => openOpenApiTelegram(),
      child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(border: Border(top: BorderSide(color: THEME.dividerLight()))),
          child: Row(children: <Widget>[
            Text(l10n.openApiSupport, style: THEME.texts.headingBold),
            const Spacer(),
            SvgPicture.asset('assets/svg/telegram.svg'),
          ])),
    );
  }

  Future<void> _toggleSimulteniousTradingSelector(bool enable) async {
    if (enable && GetIt.I<UserState>().selectedTrader.accessRights != ProtoOAAccessRights.fullAccess) {
      final AppLocalizations l10n = AppLocalizations.of(context)!;
      GetIt.I<PopupManager>().showPopup(
        title: l10n.changeAccount,
        message: l10n.accountNotSutableForSultaneousTrading,
      );
      return;
    }

    if (enable) {
      final UserState userState = GetIt.I<UserState>();
      final AppLocalizations l10n = AppLocalizations.of(context)!;

      if (userState.hasBlockedAccounts && !userState.blockedAccountsWarningPopup) {
        final StringBuffer accounts = StringBuffer();

        for (final ProtoOACtidTraderAccount acc in userState.blockedAccounts) {
          accounts.write('\n');
          accounts.write(acc.isLive == true ? l10n.live : l10n.demo);
          accounts.write(': ${acc.traderLogin} - ${acc.brokerTitleShort}');
        }

        GetIt.I<PopupManager>().showPopup(
          title: l10n.noAccess,
          message: l10n.accountsHasNoAccessToTradingContactBroker(userState.blockedAccounts.length) + accounts.toString(),
        );
        userState.setBlockedAccountsWarningPopup();
      }

      _simultaniousAccounts.clear();
      _simultaniousSelectedAccounts.clear();
      _simultaniousSelectedAccounts.add(userState.selectedTraderId);
      for (final TraderData acc in userState.traders) {
        if (acc.accessRights == ProtoOAAccessRights.fullAccess) _simultaniousAccounts.add(acc);
      }

      if (!_simultaniousAccounts.contains(userState.selectedTrader)) {
        GetIt.I<PopupManager>().showPopup(
          title: l10n.changeAccount,
          message: l10n.accountNotSutableForSultaneousTrading,
        );
        return;
      }

      if (_simultaniousAccounts.length < 2) {
        final PopupResult result = await GetIt.I<PopupManager>().showPopup(
          title: l10n.limitedTradingAccess,
          message: l10n.limitedTradingAccessDescription,
          buttons: <Widget>[
            ButtonSecondary(
              label: l10n.cancel,
              flex: 1,
              height: popup_constants.singleButtonSize.height,
              onTap: () => GetIt.I<PopupManager>().currentPopup?.closeWithResult(false),
            ),
            const SizedBox(width: 8),
            ButtonPrimary(
              label: 'Ok',
              flex: 1,
              height: popup_constants.singleButtonSize.height,
              onTap: () => GetIt.I<PopupManager>().currentPopup?.closeWithResult(true),
            ),
          ],
        );

        if (result.agree) openUrlInBrowser('https://www.spotware.com/featured-ctrader-brokers');

        return;
      }
    } else {
      final SimultaneousTrdaingState simultaneousState = GetIt.I<SimultaneousTrdaingState>();
      if (simultaneousState.hasPairedOrders || simultaneousState.hasPairedPosition) {
        final PopupResult result = await GetIt.I<PopupManager>().askToDisableSimulataneousTrading(AppLocalizations.of(context)!);
        if (!result.agree) return;
      }

      simultaneousState.disable();
    }

    setState(() => _isAllowSimultaneousTrading = enable);
  }

  void _onChangeAccount(int? index) {
    if (index == null) return;

    final TraderData trader = _traders[index];
    if (trader.accountType == ProtoOAAccountType.spreadBetting || trader.accessRights != ProtoOAAccessRights.fullAccess) {
      GetIt.I<PopupManager>().showTraderSelection(AppLocalizations.of(context)!, trader, false);
    }
    if (trader.accountType != ProtoOAAccountType.spreadBetting && trader.accessRights != ProtoOAAccessRights.noLogin) {
      GetIt.I<UserState>().selectTrader(trader.id);
    }

    _simultaniousAccounts.clear();
    _simultaniousSelectedAccounts.clear();
    _isAllowSimultaneousTrading = GetIt.I<SimultaneousTrdaingState>().enabled;
  }

  Future<void> _onTapSaveSimultaneous() async {
    if (!_isAllowSimultaneousTrading) return;

    final AppLocalizations l10n = AppLocalizations.of(context)!;

    if (_simultaniousSelectedAccounts.length < 2) {
      GetIt.I<PopupManager>().showPopup(title: l10n.incorrectChoice, message: l10n.simultaneousChoose2Accounts);
      return;
    }

    final SimultaneousTrdaingState simultaneousState = GetIt.I<SimultaneousTrdaingState>();

    final List<int> removedAccounts = <int>[];
    for (final int pairedAccId in simultaneousState.pariedAccounts) {
      if (_simultaniousSelectedAccounts.every((int id) {
        return id != pairedAccId;
      })) {
        removedAccounts.add(pairedAccId);
      }
    }

    if (removedAccounts.isNotEmpty &&
        removedAccounts.any((int id) => simultaneousState.isAccountHasPaierdOrders(id) || simultaneousState.isAccountHasPaierdPositions(id))) {
      final PopupResult result = await GetIt.I<PopupManager>().askToDisableSimulataneousTrading(l10n);
      if (!result.agree) {
        _simultaniousSelectedAccounts.clear();
        _simultaniousSelectedAccounts.addAll(GetIt.I<SimultaneousTrdaingState>().pariedAccounts);
        setState(() {});
        return;
      }

      simultaneousState.unpairAccounts(removedAccounts);
    }

    final Set<ProtoOAAccountType?> selectedAccountTypes = <ProtoOAAccountType?>{};
    for (final int accId in _simultaniousSelectedAccounts) {
      selectedAccountTypes.add(GetIt.I<UserState>().trader(accId)?.accountType);
    }
    selectedAccountTypes.remove(null);

    if (selectedAccountTypes.length > 1) {
      GetIt.I<PopupManager>().showPopup(title: l10n.warning, message: l10n.simultaneousIncludeBothAccountTypes);
    }

    simultaneousState.pairAccounts(_simultaniousSelectedAccounts);
    _simultaniousSelectedAccounts.clear();
    _simultaniousAccounts.clear();

    setState(() {});
  }

  void _onTapEditSimultaneousList() {
    final UserState userState = GetIt.I<UserState>();

    if (userState.selectedTrader.accessRights != ProtoOAAccessRights.fullAccess) {
      final AppLocalizations l10n = AppLocalizations.of(context)!;

      GetIt.I<PopupManager>().showPopup(
        title: l10n.changeAccount,
        message: l10n.accountNotSutableForSultaneousTrading,
      );
      return;
    }

    _simultaniousAccounts.clear();
    for (final TraderData acc in userState.traders) {
      if (acc.accessRights == ProtoOAAccessRights.fullAccess) _simultaniousAccounts.add(acc);
    }

    _simultaniousSelectedAccounts.clear();
    _simultaniousSelectedAccounts.addAll(GetIt.I<SimultaneousTrdaingState>().pariedAccounts);

    setState(() {});
  }
}
