import 'package:ctrader_example_app/styles/text_styles.dart';
import 'package:flutter/material.dart';

abstract class IThemeConfig {
  TextStyles get texts;
  ThemeData get theme;

  Color get red => const Color(0xffEF6161);
  Color get green => const Color(0xff049F30);

  Color get buySellBackground => const Color(0x00000000);
  Color get buySellBorder => const Color(0xffD4D7EC);
  Color get buySellUpBackground => const Color(0x33049F30);
  Color get buySellUpBorder => const Color(0x7E049F30);
  Color get buySellDownBackground => const Color(0x33FF6A6A);
  Color get buySellDownBorder => const Color(0x7EEF6161);

  Color background();
  Color onBackground();
  Color onBackgroundSecondary();

  Color blockUIBackground();
  Color blockUIOnBackground();

  Color popupShadow();
  Color popupOnBackgroundSecondary();

  Color dividerStrong();
  Color dividerLight();

  Color bannerBottomBackground();
  Color bannerBottonOnBackground();
  Color bannerBottonOnBackgroundSecond();

  Color buttonPrimaryBackground();
  Color buttonPrimaryText();
  Color buttonPrimaryBackgroundDisabled();
  Color buttonPrimaryTextDisabled();

  Color buttonSecondaryBorder();
  Color buttonSecondaryText();

  Color buttonThirdBorder();
  Color buttonThirdText(); 

  Color inputBorder();
  Color inputBorderDisabled();
  Color inputText();
  Color inputPlaceholder();
  Color inputIcon();
  Color inputIncrementText();

  Color checkboxMark();
  Color checkboxBackgroundSelected();
  Color checkboxBackgroundDisabled();

  Color switchBackground();
  Color switchBackgroundDisabled();
  Color switchBackgroundSelected();
  Color switchBackgroundSelectedDisabled();
  Color switchThumb();
  Color switchThumbDisabled();
  Color switchThumbSelected();
  Color switchThumbSelectedDisabled();

  Color menuOverlay();
  Color menuBackground();
  Color menuText();
  Color menuTextSecondary();
  Color menuDivider();
  Color menuActivityOrders();
  Color menuActivityCircleText();

  Color accountShadow();

  Color tabSelectorBackground();
  Color tabSelectorBorder();
  Color tabSelectorText();
  Color tabSelectorBackgroundSelected();
  Color tabSelectorBorderSelected();
  Color tabSelectorTextSelected();

  Color marektsGroupBackground();
  Color marketsGroupBorder();
  Color marketsGroupIcon();
  Color marketsGroupText();
  Color marketsSymbolDetailsBackground();
  Color marketsSymbolSelectedBorder();
  Color marketsSymbolSelectedBackground();
  Color marketsPositionOnBackground();

  Color floatingPnlSmallBackground();
  Color floatingPnlSmallOnBackground();
  Color floatingPnlSmallBorder();
  Color floatingPnlSmallDivider();
  Color floatingPnlLargeBackground();
  Color floatingPnlLargeOnBackground();
  Color floatingPnlLargeBorder();
  Color floatingPnlLargeDivider();

  Color chartBlockBackground();
  Color chartBlockOnBackground();
  Color chartResizeButtonBackground();
  Color chartResizeButtonOnBackground();

  Color buySellSelectedBackground();
  Color buySellTimerIcon();
  Color buySellTimerIconSelected();
  
  Color tradingHoursSelectedBackground();

  Color buttonInfoBackground();
  Color buttonInfoOnBackground();

  ThemeData colozizeTheme(ThemeData theme) {
    return theme.copyWith(
      drawerTheme: theme.drawerTheme.copyWith(
        backgroundColor: menuBackground(),
        scrimColor: menuOverlay(),
        elevation: 0,
        width: 280,
        shape: const Border.fromBorderSide(BorderSide.none),

        // shadowColor: null,
        // surfaceTintColor: null,
        // endShape: null,
      ),
      appBarTheme: theme.appBarTheme.copyWith(
        backgroundColor: background(),
        foregroundColor: onBackground(),
        shape: Border(bottom: BorderSide(color: dividerStrong())),
        toolbarTextStyle: texts.headingBold,
        titleTextStyle: texts.headingBold,
        toolbarHeight: 48,
        scrolledUnderElevation: 0,

        // color: null,
        // elevation: null,
        // shadowColor: null,
        // surfaceTintColor: null,
        // iconTheme: null,
        // actionsIconTheme: null,
        // centerTitle: null,
        // titleSpacing: null,
        // systemOverlayStyle: null,
      ),
      colorScheme: theme.colorScheme.copyWith(
        background: background(),
        onBackground: onBackground(),

        // brightness: null,
        // primary: null,
        // onPrimary: null,
        // primaryContainer: null,
        // onPrimaryContainer: null,
        // secondary: null,
        // onSecondary: null,
        // secondaryContainer: null,
        // onSecondaryContainer: null,
        // tertiary: null,
        // onTertiary: null,
        // tertiaryContainer: null,
        // onTertiaryContainer: null,
        // error: null,
        // onError: null,
        // errorContainer: null,
        // onErrorContainer: null,
        // surface: null,
        // onSurface: null,
        // surfaceVariant: null,
        // onSurfaceVariant: null,
        // outline: null,
        // outlineVariant: null,
        // shadow: null,
        // scrim: null,
        // inverseSurface: null,
        // onInverseSurface: null,
        // inversePrimary: null,
        // surfaceTint: null,
      ),
      textTheme: theme.textTheme.copyWith(
        // displayLarge: null,
        // displayMedium: null,
        // displaySmall: null,
        headlineLarge: texts.headingBold,
        headlineMedium: texts.headingRegular,
        headlineSmall: texts.headingSmall,
        // titleLarge: null,
        // titleMedium: null,
        // titleSmall: null,
        bodyLarge: texts.bodyMedium,
        bodyMedium: texts.bodyRegular,
        // bodySmall: null,
        // labelLarge: null,
        // labelMedium: null,
        // labelSmall: null,
      ),
      dropdownMenuTheme: theme.dropdownMenuTheme.copyWith(
        textStyle: texts.bodyRegular.copyWith(color: Colors.red),
        inputDecorationTheme: (theme.dropdownMenuTheme.inputDecorationTheme ?? const InputDecorationTheme()).copyWith(
          labelStyle: texts.bodyRegular.copyWith(color: Colors.amber),
          // floatingLabelStyle: null,
          // helperStyle: null,
          // helperMaxLines: null,
          // hintStyle: null,
          // errorStyle: null,
          // errorMaxLines: null,
          // floatingLabelBehavior: FloatingLabelBehavior.auto,
          // floatingLabelAlignment: FloatingLabelAlignment.start,
          // isDense: false,
          // contentPadding: null,
          // isCollapsed: false,
          // iconColor: null,
          // prefixStyle: null,
          // prefixIconColor: null,
          // suffixStyle: null,
          // suffixIconColor: null,
          // counterStyle: null,
          // filled : false,
          // fillColor: null,
          // activeIndicatorBorder: null,
          // outlineBorder: null,
          // focusColor: null,
          // hoverColor: null,
          // errorBorder: null,
          // focusedBorder: null,
          // focusedErrorBorder: null,
          // disabledBorder: null,
          // enabledBorder: null,
          // border: null,
          // alignLabelWithHint: false,
          // constraints: null,
        ),
        menuStyle: null,
      ),
      switchTheme: theme.switchTheme.copyWith(
        thumbColor: MaterialStateProperty.resolveWith((Set<MaterialState> states) =>
            states.contains(MaterialState.selected) ? switchThumbSelected() : switchThumb()),
        trackColor: MaterialStateProperty.resolveWith((Set<MaterialState> states) =>
            states.contains(MaterialState.selected) ? switchBackgroundSelected() : switchBackground()),
        // materialTapTargetSize: null,
        // mouseCursor: null,
        // overlayColor: null,
        // splashRadius: null,
        // thumbIcon: null,
      ),
      scaffoldBackgroundColor: background(),

      // applyElevationOverlayColor: null,
      // cupertinoOverrideTheme: null,
      // extensions: null,
      // inputDecorationTheme: null,
      // materialTapTargetSize: null,
      // pageTransitionsTheme: null,
      // platform: null,
      // scrollbarTheme: null,
      // splashFactory: null,
      // useMaterial3: null,
      // visualDensity: null,

      // // COLOR
      // // [colorScheme] is the preferred way to configure colors. The other color
      // // properties (as well as primaryColorBrightness, and primarySwatch)
      // // will gradually be phased out, see https://github.com/flutter/flutter/issues/91772.
      // brightness: null,
      // canvasColor: null,
      // cardColor: null,
      // dialogBackgroundColor: null,
      // disabledColor: null,
      // dividerColor: null,
      // focusColor: null,
      // highlightColor: null,
      // hintColor: null,
      // hoverColor: null,
      // indicatorColor: null,
      // primaryColor: null,
      // primaryColorDark: null,
      // primaryColorLight: null,
      // secondaryHeaderColor: null,
      // shadowColor: null,
      // splashColor: null,
      // unselectedWidgetColor: null,

      // // TYPOGRAPHY & ICONOGRAPHY
      // iconTheme: null,
      // primaryIconTheme: null,
      // primaryTextTheme: null,
      // typography: null,

      // // COMPONENT THEMES
      // badgeTheme: null,
      // bannerTheme: null,
      // bottomAppBarTheme: null,
      // bottomNavigationBarTheme: null,
      // bottomSheetTheme: null,
      // buttonBarTheme: null,
      // buttonTheme: null,
      // cardTheme: null,
      // checkboxTheme: null,
      // chipTheme: null,
      // dataTableTheme: null,
      // dialogTheme: null,
      // dividerTheme: null,
      // elevatedButtonTheme: null,
      // expansionTileTheme: null,
      // filledButtonTheme: null,
      // floatingActionButtonTheme: null,
      // iconButtonTheme: null,
      // listTileTheme: null,
      // menuBarTheme: null,
      // menuButtonTheme: null,
      // menuTheme: null,
      // navigationBarTheme: null,
      // navigationDrawerTheme: null,
      // navigationRailTheme: null,
      // outlinedButtonTheme: null,
      // popupMenuTheme: null,
      // progressIndicatorTheme: null,
      // radioTheme: null,
      // segmentedButtonTheme: null,
      // sliderTheme: null,
      // snackBarTheme: null,
      // tabBarTheme: null,
      // textButtonTheme: null,
      // textSelectionTheme: null,
      // timePickerTheme: null,
      // toggleButtonsTheme: null,
      // tooltipTheme: null,
    );
  }
}
