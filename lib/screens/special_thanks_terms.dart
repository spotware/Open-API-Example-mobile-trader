import 'dart:async';
import 'dart:convert';

import 'package:ctrader_example_app/l10n/localizations.dart';
import 'package:ctrader_example_app/main.dart';
import 'package:ctrader_example_app/widgets/wrapped_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SpecialThanksTerms extends StatefulWidget {
  const SpecialThanksTerms({super.key, required this.type});

  final String type;

  @override
  State<SpecialThanksTerms> createState() => _SpecialThanksTermsState();
}

class _SpecialThanksTermsState extends State<SpecialThanksTerms> {
  String? terms;

  @override
  void initState() {
    super.initState();

    Timer.run(() async {
      final String jsonStr = await rootBundle.loadString('assets/json/licenses.json');
      final dynamic json = jsonDecode(jsonStr);
      terms = json[widget.type] as String?;

      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: WrappedAppBar(title: l10n.specialThanks, showBack: true),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(terms ?? l10n.noTermsFound, style: THEME.texts.bodyRegular),
        ),
      ),
    );
  }
}
