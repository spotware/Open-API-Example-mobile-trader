import 'package:ctrader_example_app/extensions.dart';
import 'package:ctrader_example_app/l10n/localizations.dart';
import 'package:ctrader_example_app/main.dart';
import 'package:ctrader_example_app/screens/special_thanks_terms.dart';
import 'package:ctrader_example_app/widgets/wrapped_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SpecialThanksScreen extends StatelessWidget {
  const SpecialThanksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: WrappedAppBar(title: l10n.specialThanks, showBack: true),
      body: SingleChildScrollView(
        child: Column(children: <Widget>[
          const SizedBox(height: 8),
          _item(context, 'https://pub.dev/packages/cupertino_icons', 'mit'),
          _item(context, 'https://pub.dev/packages/flutter_localization', 'bsd3'),
          _item(context, 'https://pub.dev/packages/flutter_native_timezone', 'flutter_native_timezone'),
          _item(context, 'https://pub.dev/packages/flutter_secure_storage', 'bsd3'),
          _item(context, 'https://pub.dev/packages/flutter_svg', 'mit'),
          _item(context, 'https://pub.dev/packages/get_it', 'mit'),
          _item(context, 'https://pub.dev/packages/http', 'bsd3clause'),
          _item(context, 'https://pub.dev/packages/intl', 'bsd3clause'),
          _item(context, 'https://pub.dev/packages/provider', 'mit'),
          _item(context, 'https://pub.dev/packages/shared_preferences', 'bsd3clause'),
          _item(context, 'https://pub.dev/packages/timezone', 'bsd2clause'),
          _item(context, 'https://pub.dev/packages/url_launcher', 'bsd3clause'),
          _item(context, 'https://pub.dev/packages/visibility_detector', 'bsd3clause'),
          _item(context, 'https://pub.dev/packages/webview_flutter', 'bsd3clause'),
        ]),
      ),
    );
  }

  Widget _item(BuildContext context, String label, String type) {
    return GestureDetector(
      onTap: () => _onTapItem(context, type),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(children: <Widget>[
          Expanded(child: Text(label, style: THEME.texts.bodyRegular)),
          SvgPicture.asset('assets/svg/arrow_greater.svg', width: 5, height: 10, colorFilter: THEME.onBackground().asFilter),
        ]),
      ),
    );
  }

  void _onTapItem(BuildContext context, String type) {
    Navigator.push(context, MaterialPageRoute<void>(builder: (BuildContext context) => SpecialThanksTerms(type: type)));
  }
}
