import 'package:ctrader_example_app/main.dart';
import 'package:ctrader_example_app/widgets/button_base.dart';
import 'package:flutter/material.dart';

class ButtonThird extends ButtonBase {
  ButtonThird({
    super.key,
    required super.label,
    super.width,
    super.height,
    super.flex,
    super.prefix,
    super.suffix,
    super.onTap,
  }) : super(
          background: Colors.transparent,
          border: THEME.buttonThirdBorder(),
          textStyle: THEME.texts.buttonThird,
          backgroundDisabled: Colors.transparent,
          borderDisabled: THEME.buttonThirdBorder(),
          textStyleDisabled: THEME.texts.buttonThird,
        );
}
