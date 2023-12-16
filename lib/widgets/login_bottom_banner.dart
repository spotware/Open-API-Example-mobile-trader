import 'package:ctrader_example_app/l10n/localizations.dart';
import 'package:ctrader_example_app/main.dart';
import 'package:ctrader_example_app/utils.dart';
import 'package:flutter/material.dart';

class LoginBottomBanner extends StatelessWidget {
  const LoginBottomBanner({super.key});

  static Column wrap({required Widget child}) {
    return Column(children: <Widget>[Expanded(child: child), const LoginBottomBanner()]);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: () => openUrlInBrowser('https://github.com/spotware/Open-API-Example-mobile-trader'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(color: THEME_LOGIN.bannerBackground),
        child: Row(
          children: <Widget>[
            Image.asset(
              'assets/png/banner_bottom_logo.png',
              width: 40,
              height: 40,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(l10n.canYouCreateBetterApp, style: THEME_LOGIN.texts.banner),
                  Text(l10n.reuseOurCode, style: THEME_LOGIN.texts.bannerBold),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
