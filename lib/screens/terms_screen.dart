import 'package:ctrader_example_app/extensions.dart';
import 'package:ctrader_example_app/l10n/localizations.dart';
import 'package:ctrader_example_app/main.dart';
import 'package:ctrader_example_app/widgets/button_primary.dart';
import 'package:ctrader_example_app/widgets/button_secondary.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key, required this.terms});

  final Iterable<Iterable<String>> terms;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Container(
              height: 48,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(border: Border(bottom: BorderSide(color: THEME.dividerLight()))),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: SvgPicture.asset('assets/svg/x.svg', width: 24, height: 24, colorFilter: THEME.onBackground().asFilter),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[for (final Widget w in _terms()) w],
                ),
              ),
            ),
            _buttons(context),
          ],
        ),
      ),
    );
  }

  List<Widget> _terms() {
    return <Widget>[for (int i = 0; i < terms.length; i++) _paragraph(i + 1, terms.elementAt(i))];
  }

  Widget _paragraph(int num, Iterable<String> texts) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (texts.length > 1)
            Container(
              width: 28,
              alignment: Alignment.topRight,
              padding: const EdgeInsets.only(right: 6),
              child: Text(texts.elementAt(0), style: THEME.texts.bodyRegular),
            ),
          Expanded(
            child: Text(texts.elementAt(texts.length - 1), style: THEME.texts.bodyRegular),
          ),
        ],
      ),
    );
  }

  Widget _buttons(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      child: Row(children: <Widget>[
        Expanded(
          child: ButtonSecondary(
            label: l10n.reject,
            height: 32,
            onTap: () => Navigator.pop(context, false),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ButtonPrimary(
            label: l10n.agree,
            height: 32,
            onTap: () => Navigator.pop(context, true),
          ),
        ),
      ]),
    );
  }
}
