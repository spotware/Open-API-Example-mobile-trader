import 'package:ctrader_example_app/styles/itheme_config.dart';
import 'package:ctrader_example_app/styles/text_styles.dart';
import 'package:flutter/material.dart';

class LightThemeConfig extends IThemeConfig {
  LightThemeConfig() {
    _texts = TextStyles.colorizedBy(config: this);
    _theme = colozizeTheme(ThemeData.light(useMaterial3: true));
  }

  late final TextStyles _texts;
  late final ThemeData _theme;

  @override
  TextStyles get texts => _texts;
  @override
  ThemeData get theme => _theme;

  @override
  Color background() => const Color(0xffffffff);
  @override
  Color onBackground() => const Color(0xff1A1E40);
  @override
  Color onBackgroundSecondary() => const Color(0xff5D6183);

  @override
  Color blockUIBackground() => const Color(0x541A1E40);
  @override
  Color blockUIOnBackground() => const Color(0xff000000);

  @override
  Color popupShadow() => const Color(0x33484C6D);
  @override
  Color popupOnBackgroundSecondary() => const Color(0xff5D6183);

  @override
  Color dividerStrong() => const Color(0xff5D6183);
  @override
  Color dividerLight() => const Color(0xffC8CAD6);

  @override
  Color bannerBottomBackground() => const Color(0xff222222);
  @override
  Color bannerBottonOnBackground() => const Color(0xffffffff);
  @override
  Color bannerBottonOnBackgroundSecond() => const Color(0xffD9D9D9);

  @override
  Color buttonPrimaryBackground() => const Color(0xff2537C2);
  @override
  Color buttonPrimaryText() => const Color(0xffffffff);
  @override
  Color buttonPrimaryBackgroundDisabled() => const Color(0xffEEEFF4);
  @override
  Color buttonPrimaryTextDisabled() => const Color(0xffC8CAD6);

  @override
  Color buttonSecondaryBorder() => const Color(0xffD4D7EC);
  @override
  Color buttonSecondaryText() => const Color(0xff1A1E40);

  @override
  Color buttonThirdBorder() => const Color(0xff2537C2);
  @override
  Color buttonThirdText() => const Color(0xff1A1E40);

  @override
  Color inputBorder() => const Color(0xffD4D7EC);
  @override
  Color inputBorderDisabled() => const Color(0xffD4D7EC);
  @override
  Color inputPlaceholder() => const Color(0xffD4D7EC);
  @override
  Color inputText() => const Color(0xff1A1E40);
  @override
  Color inputIcon() => const Color(0xff484C6D);
  @override
  Color inputIncrementText() => const Color(0xff2537C2);

  @override
  Color checkboxMark() => const Color(0xffffffff);
  @override
  Color checkboxBackgroundSelected() => const Color(0xff4F6FE3);
  @override
  Color checkboxBackgroundDisabled() => const Color(0xffC8CAD6);

  @override
  Color switchBackground() => const Color(0xffD4D7EA);
  @override
  Color switchBackgroundDisabled() => const Color(0xffE9EAF4);
  @override
  Color switchBackgroundSelected() => const Color(0xff566EDC);
  @override
  Color switchBackgroundSelectedDisabled() => const Color(0xffAAB7ED);
  @override
  Color switchThumb() => const Color(0xffFFFFFF);
  @override
  Color switchThumbDisabled() => const Color(0xffF8F8FC);
  @override
  Color switchThumbSelected() => const Color(0xffFFFFFF);
  @override
  Color switchThumbSelectedDisabled() => const Color(0xffE3E7F8);

  @override
  Color menuOverlay() => const Color(0x541A1E40);
  @override
  Color menuBackground() => const Color(0xffffffff);
  @override
  Color menuText() => const Color(0xff1A1E40);
  @override
  Color menuTextSecondary() => const Color(0xff484C6D);
  @override
  Color menuDivider() => const Color(0xffD4D7EC);
  @override
  Color menuActivityOrders() => const Color(0xffC8CAD6);
  @override
  Color menuActivityCircleText() => const Color(0xffffffff);

  @override
  Color accountShadow() => const Color(0x44c8cad6);

  @override
  Color tabSelectorBackground() => const Color(0xffEEEFF4);
  @override
  Color tabSelectorBorder() => const Color(0xffC8CAD6);
  @override
  Color tabSelectorText() => const Color(0xff5D6183);
  @override
  Color tabSelectorBackgroundSelected() => const Color(0xffD4D7EC);
  @override
  Color tabSelectorBorderSelected() => const Color(0xff1A1E40);
  @override
  Color tabSelectorTextSelected() => const Color(0xff1A1E40);
  @override
  Color marketsSymbolDetailsBackground() => const Color(0xffEEEFF4);
  @override
  Color marketsSymbolSelectedBorder() => const Color(0xffA8A8BD);
  @override
  Color marketsSymbolSelectedBackground() => const Color(0xffF7F7FB);
  @override
  Color marektsGroupBackground() => const Color(0xffD4D7EC);
  @override
  Color marketsGroupIcon() => const Color(0xff1A1E40);
  @override
  Color marketsGroupText() => const Color(0xff1A1E40);
  @override
  Color marketsGroupBorder() => const Color(0xffC8CAD6);
  @override
  Color marketsPositionOnBackground() => const Color(0xff1A1E40);

  @override
  Color floatingPnlSmallBackground() => const Color(0xffEF6161);
  @override
  Color floatingPnlSmallOnBackground() => const Color(0xffffffff);
  @override
  Color floatingPnlSmallBorder() => const Color(0xff5D6183);
  @override
  Color floatingPnlSmallDivider() => const Color(0x7fE5E6EC);
  @override
  Color floatingPnlLargeBackground() => const Color(0xffD4D7EC);
  @override
  Color floatingPnlLargeOnBackground() => const Color(0xff1A1E40);
  @override
  Color floatingPnlLargeBorder() => const Color(0xff5D6183);
  @override
  Color floatingPnlLargeDivider() => const Color(0xffA8A8BD);

  @override
  Color chartBlockBackground() => const Color(0xaaffffff);
  @override
  Color chartBlockOnBackground() => const Color(0xff4F6FE3);
  @override
  Color chartResizeButtonBackground() => const Color(0xffEEEFF4);
  @override
  Color chartResizeButtonOnBackground() => const Color(0xffA8A8BD);

  @override
  Color buySellSelectedBackground() => const Color(0xff4F6FE3);
  @override
  Color buySellTimerIcon() => const Color(0xffD4D7EC);
  @override
  Color buySellTimerIconSelected() => const Color(0xff4F6FE3);

  @override
  Color tradingHoursSelectedBackground() => const Color(0xffD4D7EC);

  @override
  Color buttonInfoBackground() => const Color(0xffEEEFF4);
  @override
  Color buttonInfoOnBackground() => const Color(0xff1A1E40);
}
