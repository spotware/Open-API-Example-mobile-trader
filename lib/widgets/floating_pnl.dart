import 'package:ctrader_example_app/extensions.dart';
import 'package:ctrader_example_app/l10n/localizations.dart';
import 'package:ctrader_example_app/main.dart';
import 'package:ctrader_example_app/models/trader_data.dart';
import 'package:ctrader_example_app/states/app_state.dart';
import 'package:ctrader_example_app/states/user_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

enum FloatingPnlState { hide, small, open }

class FloatingPnl extends StatefulWidget {
  const FloatingPnl({super.key, required this.child});

  final Widget child;

  @override
  State<FloatingPnl> createState() => _FloatingPnlState();
}

class _FloatingPnlState extends State<FloatingPnl> with TickerProviderStateMixin {
  late final AnimationController _manualController;
  late final Animation<double> _manualAnimation;

  @override
  void initState() {
    super.initState();

    _manualController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _manualAnimation = Tween<double>(begin: -0.25, end: -1.25).animate(_manualController);
    _manualController.animateTo(<double>[0, 0.25, 0.75][GetIt.I<AppState>().floatingPnlState.index]);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final TraderData trader = context.watch<UserState>().selectedTrader;
    final FloatingPnlState state = context.watch<AppState>().floatingPnlState;
    final bool isHide = state == FloatingPnlState.hide;
    final bool isExpanded = state == FloatingPnlState.open;
    final Color bgColor = isExpanded ? THEME.floatingPnlLargeBackground() : (trader.pnl < 0 ? THEME.red : THEME.green);
    final Color colorOnBg = isExpanded ? THEME.floatingPnlLargeOnBackground() : THEME.floatingPnlSmallOnBackground();

    return Stack(
      children: <Widget>[
        widget.child,
        AnimatedPositioned(
          duration: const Duration(milliseconds: 250),
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            alignment: Alignment.centerLeft,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: const BorderRadius.only(topRight: Radius.circular(2)),
              ),
              constraints: const BoxConstraints(minHeight: 40),
              child: AnimatedSize(
                duration: const Duration(milliseconds: 200),
                alignment: Alignment.bottomRight,
                child: IntrinsicHeight(
                  child: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    if (!isHide && !isExpanded)
                      for (final Widget item in _smallFilling(trader)) item,
                    if (!isHide && isExpanded)
                      for (final Widget item in _expandedFilling(l10n, trader)) item,
                    Container(
                      width: 1,
                      color: isExpanded ? THEME.floatingPnlLargeDivider() : bgColor,
                      height: isExpanded ? 86 : null,
                    ),
                    const SizedBox(width: 8),
                    Container(
                      alignment: isExpanded ? Alignment.topCenter : Alignment.center,
                      child: GestureDetector(
                        onTap: _toggleState,
                        child: Container(
                          width: 24,
                          height: 24,
                          alignment: Alignment.center,
                          color: Colors.transparent,
                          padding: isExpanded ? const EdgeInsets.only(top: 12) : null,
                          child: RotationTransition(
                            turns: _manualAnimation,
                            child: SvgPicture.asset(
                              'assets/svg/triangle_down.svg',
                              width: 18,
                              colorFilter: colorOnBg.asFilter,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ]),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _smallFilling(TraderData trader) {
    return <Widget>[
      GestureDetector(
        onTap: _hide,
        child: Container(
          width: 26,
          alignment: Alignment.center,
          color: Colors.transparent,
          child: RotatedBox(
            quarterTurns: 1,
            child: SvgPicture.asset(
              'assets/svg/triangle_down.svg',
              width: 18,
              colorFilter: THEME.floatingPnlSmallOnBackground().asFilter,
            ),
          ),
        ),
      ),
      Container(width: 1, height: 24, color: THEME.floatingPnlSmallDivider()),
      const SizedBox(width: 12),
      Text(
        '${AppLocalizations.of(context)!.pnl}: ${trader.formattedMoneyWithCurrency(cents: trader.pnl)}',
        style: THEME.texts.bodyMedium.copyWith(color: THEME.floatingPnlSmallOnBackground()),
      ),
    ];
  }

  List<Widget> _expandedFilling(AppLocalizations l10n, TraderData trader) {
    final TextStyle textStyle = THEME.texts.bodyMedium.copyWith(color: THEME.floatingPnlLargeOnBackground());

    return <Widget>[
      const SizedBox(width: 8),
      IntrinsicWidth(
        child: Column(children: <Widget>[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(l10n.balanceLabel, style: textStyle),
              const SizedBox(width: 12),
              Text(trader.formattedMoneyWithCurrency(cents: trader.balance), style: textStyle),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(l10n.equityLabel, style: textStyle),
              const SizedBox(width: 12),
              Text(trader.formattedMoneyWithCurrency(cents: trader.equity), style: textStyle),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(l10n.marginLabel, style: textStyle),
              const SizedBox(width: 12),
              Text(trader.formattedMoneyWithCurrency(cents: trader.margin), style: textStyle),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(l10n.unrNetPnlLabel, style: textStyle),
              const SizedBox(width: 12),
              Text(
                trader.formattedMoneyWithCurrency(cents: trader.pnl),
                style: textStyle.copyWith(color: trader.pnl < 0 ? THEME.red : THEME.green),
              )
            ],
          ),
          const SizedBox(height: 8),
        ]),
      ),
      const SizedBox(width: 8),
    ];
  }

  void _toggleState() {
    final AppState appState = GetIt.I<AppState>();

    switch (appState.floatingPnlState) {
      case FloatingPnlState.hide:
        _manualController.animateTo(0.25);
        appState.setFloatingPnlState(FloatingPnlState.small);
        break;
      case FloatingPnlState.small:
        _manualController.animateTo(0.75);
        appState.setFloatingPnlState(FloatingPnlState.open);
        break;
      case FloatingPnlState.open:
        _manualController.animateTo(0.25);
        appState.setFloatingPnlState(FloatingPnlState.small);
        break;
    }
  }

  void _hide() {
    _manualController.animateTo(0);
    GetIt.I<AppState>().setFloatingPnlState(FloatingPnlState.hide);
  }
}
