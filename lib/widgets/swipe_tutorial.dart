import 'package:ctrader_example_app/extensions.dart';
import 'package:ctrader_example_app/l10n/localizations.dart';
import 'package:ctrader_example_app/main.dart';
import 'package:ctrader_example_app/screens/account_screen.dart';
import 'package:ctrader_example_app/states/tutorial_state.dart';
import 'package:ctrader_example_app/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';

class SwipeTutorial extends StatelessWidget {
  const SwipeTutorial({super.key, required this.child, required this.direction, required this.scaffolfKey})
      : assert(direction == null || direction == AxisDirection.left || direction == AxisDirection.right, 'Direction can be only one of: null, left, right');

  final Widget child;
  final AxisDirection? direction;
  final GlobalKey<ScaffoldState> scaffolfKey;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Stack(children: <Widget>[
          child,
          if (direction != null)
            Positioned.fill(
              child: GestureDetector(
                onHorizontalDragUpdate: (DragUpdateDetails details) => _handleSwipeAction(context, details.delta.dx),
                child: Container(color: THEME.blockUIBackground()),
              ),
            ),
          if (direction != null)
            Positioned(
              left: 0,
              top: 110,
              right: 0,
              child: GestureDetector(
                onHorizontalDragUpdate: (DragUpdateDetails details) => _handleSwipeAction(context, details.delta.dx),
                child: Center(
                  child: Container(
                    constraints: BoxConstraints.tightFor(height: constraints.maxHeight * 0.53),
                    child: Column(children: <Widget>[
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: _onTapClosePopup,
                          child: Container(
                            constraints: const BoxConstraints.tightFor(width: 36, height: 36),
                            alignment: Alignment.center,
                            color: Colors.transparent,
                            child: SvgPicture.asset(
                              'assets/svg/x.svg',
                              height: 20,
                              width: 20,
                              colorFilter: THEME.onBackground().asFilter,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Container(
                                alignment: direction == AxisDirection.left ? Alignment.centerRight : Alignment.centerLeft,
                                padding: const EdgeInsets.symmetric(horizontal: 32),
                                child: SvgPicture.asset(
                                  'assets/svg/swipe_${direction!.name}_tip.svg',
                                  colorFilter: THEME.onBackground().asFilter,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                direction == AxisDirection.left ? l10n.swipeLeftTutorial : l10n.swipeRightTutorial,
                                style: THEME.texts.headingLargeBold.copyWith(height: 1.5),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 36),
                            ],
                          ),
                        ),
                      ),
                    ]),
                  ),
                ),
              ),
            ),
        ]);
      },
    );
  }

  void _handleSwipeAction(BuildContext context, double dx) {
    if (direction == AxisDirection.left && dx < -20) {
      GetIt.I<TutorialState>().finishStep(TutorialSteps.swipeLeft);
      changePageWithSlideTransition(scaffolfKey.currentContext!, const Offset(1, 0), const AccountScreen());
    } else if (direction == AxisDirection.right && dx > 20) {
      GetIt.I<TutorialState>().finishStep(TutorialSteps.swipeRight);
      scaffolfKey.currentState!.openDrawer();
    }
  }

  void _onTapClosePopup() {
    GetIt.I<TutorialState>().finishCurrentStep();
  }
}
