import 'package:ctrader_example_app/styles/login_text_styles.dart';
import 'package:flutter/material.dart';

class LoginTheme {
  LoginTheme() {
    texts.heading = texts.heading.copyWith(color: heading);
    texts.headingStrong = texts.headingStrong.copyWith(color: heading);
    texts.headingSmall = texts.headingSmall.copyWith(color: headingSecond);
    texts.headingSmallBold = texts.headingSmallBold.copyWith(color: headingSecond);

    texts.brokerButton = texts.brokerButton.copyWith(color: onBackground);

    texts.banner = texts.banner.copyWith(color: bannerText);
    texts.bannerBold = texts.bannerBold.copyWith(color: bannerText);
  }

  Color background = const Color(0xff1B1C28);
  Color onBackground = const Color(0xffEEEFF4);

  Color heading = const Color(0xffEEEFF4);
  Color headingSecond = const Color(0xffC8CAD6);

  Color brokerBorder = const Color(0xffD4D7EC);
  Color brokerText = const Color(0xff5D6183);

  Color bannerBackground = const Color(0xffEEEFF4);
  Color bannerText = const Color(0xff1A1E40);

  LoginTextStyles texts = LoginTextStyles();
}
