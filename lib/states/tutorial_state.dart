import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum TutorialStatePrefKeys { state }

enum TutorialSteps {
  swipeLeft(1 << 0), //     mask: 0001 / 1
  chartRotation(1 << 1), // mask: 0010 / 2
  swipeRight(1 << 2), //    mask: 0100 / 4
  done(1 << 3); //          mask: 1000 / 8

  const TutorialSteps(this.mask);

  final int mask;
  static TutorialSteps restoreFromPrefs(int? index) => values.elementAt(max(0, min(index ?? 0, values.length - 1)));

  bool isMatch(int value) => value & mask == mask;
  TutorialSteps get next => values.elementAt(values.indexOf(this) + 1);
}

class TutorialState extends ChangeNotifier {
  TutorialState() {
    SharedPreferences.getInstance().then((SharedPreferences prefs) {
      _preferences = prefs;
      _finishedSteps = _preferences?.getInt(TutorialStatePrefKeys.state.toString()) ?? _finishedSteps;

      notifyListeners();
    });
  }

  static const int STEP_DELAY_SEC = 2;

  SharedPreferences? _preferences;
  int _finishedSteps = 0;
  bool _visible = true;

  bool get visible => _visible;
  bool isFinished(TutorialSteps step) => step.isMatch(_finishedSteps);
  TutorialSteps get currentStep => TutorialSteps.values.firstWhere((TutorialSteps s) => !s.isMatch(_finishedSteps));

  void _disableVisibilityForDelay(int delaySec) {
    _visible = false;
    Timer(Duration(seconds: delaySec), () {
      _visible = true;
      notifyListeners();
    });
  }

  void finishStep(TutorialSteps step, {bool withPause = false}) {
    if (isFinished(step)) return;
    if (withPause) _disableVisibilityForDelay(STEP_DELAY_SEC);
    _finishedSteps += step.mask;

    notifyListeners();

    _preferences?.setInt(TutorialStatePrefKeys.state.toString(), _finishedSteps);
  }

  void finishCurrentStep() => finishStep(currentStep, withPause: true);
}
