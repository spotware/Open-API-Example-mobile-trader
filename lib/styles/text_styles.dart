import 'package:ctrader_example_app/styles/itheme_config.dart';
import 'package:flutter/material.dart';

TextStyle _formStyle(double size, double lineHeight, [FontWeight? weight]) {
  return TextStyle(
    fontFamily: 'Arimo',
    fontSize: size,
    height: lineHeight / size,
    fontWeight: weight,
    decoration: TextDecoration.none,
  );
}

class TextStyles {
  TextStyles.colorizedBy({required IThemeConfig config}) {
    bodyRegular = bodyRegular.copyWith(color: config.onBackground());
    bodyRegularSecondary = bodyRegular.copyWith(color: config.onBackgroundSecondary());
    bodyMedium = bodyMedium.copyWith(color: config.onBackground());
    bodyMediumSecondary = bodyMedium.copyWith(color: config.onBackgroundSecondary());
    bodyBold = bodyBold.copyWith(color: config.onBackground());
    bodySmall = bodySmall.copyWith(color: config.onBackground());

    headingLargeBold = headingLargeBold.copyWith(color: config.onBackground());
    headingRegular = headingRegular.copyWith(color: config.onBackground());
    headingBold = headingBold.copyWith(color: config.onBackground());
    headingSmall = headingSmall.copyWith(color: config.onBackground());

    bannerBotom = bannerBotom.copyWith(color: config.bannerBottonOnBackground());
    bannerBottomSecondary = bannerBottomSecondary.copyWith(color: config.bannerBottonOnBackgroundSecond());

    buttonPrimary = buttonPrimary.copyWith(color: config.buttonPrimaryText());
    buttonSecondary = buttonSecondary.copyWith(color: config.buttonSecondaryText());
    buttonThird = buttonThird.copyWith(color: config.buttonThirdText());

    input = input.copyWith(color: config.inputText());
    inputIncremenet = inputIncremenet.copyWith(color: config.inputIncrementText());

    sideMenu = sideMenu.copyWith(color: config.menuText());
    sideMenuSecondary = sideMenu.copyWith(color: config.menuTextSecondary());
    sideMenuActivityCircles = sideMenu.copyWith(color: config.menuActivityCircleText());

    chartRotateTip = chartRotateTip.copyWith(color: config.chartBlockOnBackground());
  }

  TextStyle bodyRegular = _formStyle(14, 22);
  late TextStyle bodyRegularSecondary;
  TextStyle bodyMedium = _formStyle(14, 22, FontWeight.w500);
  late TextStyle bodyMediumSecondary;
  TextStyle bodyBold = _formStyle(14, 22, FontWeight.bold);
  TextStyle bodySmall = _formStyle(12, 22, FontWeight.bold);

  TextStyle headingLargeBold = _formStyle(20, 22, FontWeight.bold);
  TextStyle headingRegular = _formStyle(16, 22);
  TextStyle headingBold = _formStyle(16, 22, FontWeight.bold);
  TextStyle headingSmall = _formStyle(14, 22, FontWeight.bold);

  TextStyle bannerBotom = _formStyle(16, 22, FontWeight.bold);
  TextStyle bannerBottomSecondary = _formStyle(16, 22);

  TextStyle buttonPrimary = _formStyle(14, 22, FontWeight.bold);
  TextStyle buttonSecondary = _formStyle(14, 22, FontWeight.bold);
  TextStyle buttonThird = _formStyle(14, 22, FontWeight.bold);

  TextStyle input = _formStyle(14, 14);
  TextStyle inputIncremenet = _formStyle(16, 16, FontWeight.bold);

  TextStyle chartRotateTip = _formStyle(20, 24, FontWeight.bold);

  TextStyle sideMenu = _formStyle(16, 22, FontWeight.bold);
  late TextStyle sideMenuSecondary;
  late TextStyle sideMenuActivityCircles;
}
