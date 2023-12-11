import 'package:ctrader_example_app/l10n/localizations.dart';
import 'package:ctrader_example_app/main.dart';
import 'package:ctrader_example_app/screens/account_screen.dart';
import 'package:ctrader_example_app/screens/activity_closed_positions.dart';
import 'package:ctrader_example_app/screens/activity_orders.dart';
import 'package:ctrader_example_app/screens/activity_positions.dart';
import 'package:ctrader_example_app/screens/market_screen.dart';
import 'package:ctrader_example_app/utils.dart';
import 'package:ctrader_example_app/widgets/side_menu.dart';
import 'package:ctrader_example_app/widgets/wrapped_appbar.dart';
import 'package:flutter/material.dart';

enum _Tabs { positions, orders, closed }

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  static const String ROUTE_NAME = '/activity';

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  _Tabs _selectedTab = _Tabs.positions;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: WrappedAppBar(title: l10n.myActivity),
      drawer: const SideMenu(),
      body: GestureDetector(
        onHorizontalDragUpdate: (DragUpdateDetails details) {
          if (details.delta.dx > 20) {
            changePageWithSlideTransition(context, const Offset(-1, 0), const AccountScreen());
          } else if (details.delta.dx < -20) {
            changePageWithSlideTransition(context, const Offset(1, 0), const MarketScreen());
          }
        },
        child: Column(children: <Widget>[
          _tabSection(l10n),
          if (_selectedTab == _Tabs.positions) const Expanded(child: ActivityPositions()),
          if (_selectedTab == _Tabs.orders) const Expanded(child: ActivityOrders()),
          if (_selectedTab == _Tabs.closed) const Expanded(child: ActivityClosedPositions()),
        ]),
      ),
    );
  }

  Widget _tabSection(AppLocalizations l10n) {
    return SizedBox(
      height: 36,
      child: Row(
        children: <Widget>[
          _tabButton(l10n.positions, _Tabs.positions, _onSelectTab),
          _tabButton(l10n.orders, _Tabs.orders, _onSelectTab),
          _tabButton(l10n.closed, _Tabs.closed, _onSelectTab),
        ],
      ),
    );
  }

  Widget _tabButton(String label, _Tabs tab, Function(_Tabs) onTap) {
    final bool isSelected = _selectedTab == tab;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(tab),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? THEME.tabSelectorBackgroundSelected() : THEME.tabSelectorBackground(),
            border: Border(
              bottom: BorderSide(
                color: isSelected ? THEME.tabSelectorBorderSelected() : THEME.tabSelectorBorder(),
              ),
            ),
          ),
          child: Text(
            label,
            style: (isSelected ? THEME.texts.headingBold : THEME.texts.headingRegular)
                .copyWith(color: isSelected ? THEME.tabSelectorTextSelected() : THEME.tabSelectorText()),
          ),
        ),
      ),
    );
  }

  void _onSelectTab(_Tabs tab) {
    setState(() => _selectedTab = tab);
  }
}
