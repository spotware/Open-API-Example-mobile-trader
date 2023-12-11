import 'package:ctrader_example_app/main.dart';
import 'package:ctrader_example_app/widgets/button_base.dart';

class ButtonPrimary extends ButtonBase {
  ButtonPrimary(
      {required super.label,
      super.key,
      super.height,
      super.width,
      super.flex,
      super.prefix,
      super.suffix,
      super.onTap,
      super.disabled})
      : super(
            background: THEME.buttonPrimaryBackground(),
            border: THEME.buttonPrimaryBackground(),
            textStyle: THEME.texts.buttonPrimary,
            backgroundDisabled: THEME.buttonPrimaryBackgroundDisabled(),
            borderDisabled: THEME.buttonPrimaryBackgroundDisabled(),
            textStyleDisabled: THEME.texts.buttonPrimary.copyWith(color: THEME.buttonPrimaryTextDisabled()));
}
