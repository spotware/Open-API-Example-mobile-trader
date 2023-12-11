import 'package:ctrader_example_app/main.dart';
import 'package:ctrader_example_app/widgets/button_base.dart';
import 'package:flutter/material.dart';

class ButtonSecondary extends ButtonBase {
  ButtonSecondary({
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
          border: THEME.buttonSecondaryBorder(),
          textStyle: THEME.texts.buttonSecondary,
          backgroundDisabled: Colors.transparent,
          borderDisabled: THEME.buttonSecondaryBorder(),
          textStyleDisabled: THEME.texts.buttonSecondary,
        );
}
