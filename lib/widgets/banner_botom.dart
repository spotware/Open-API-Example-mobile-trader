import 'package:ctrader_example_app/l10n/localizations.dart';
import 'package:ctrader_example_app/main.dart';
import 'package:ctrader_example_app/utils.dart';
import 'package:flutter/material.dart';

class BannerBottom extends StatelessWidget {
  const BannerBottom({super.key});

  static Widget insertTo({required Widget body, bool? ignore}) {
    return Column(children: <Widget>[
      Expanded(child: body),
      if (ignore != true) const BannerBottom(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: () => openUrlInBrowser('https://openapi.ctrader.com/'),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(color: THEME.bannerBottomBackground()),
        child: Row(children: <Widget>[
          Text(l10n.sourcesAndDetails, style: THEME.texts.bannerBotom),
          const Spacer(),
          Container(
            alignment: Alignment.center,
            child: Image.asset('assets/png/banner_bottom_logo.png', width: 30, height: 30),
          ),
          const SizedBox(width: 12),
          Text(l10n.openAPI, style: THEME.texts.bannerBottomSecondary),
        ]),
      ),
    );
  }
}
