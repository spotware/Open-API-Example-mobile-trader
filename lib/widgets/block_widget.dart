import 'package:ctrader_example_app/l10n/localizations.dart';
import 'package:ctrader_example_app/main.dart';
import 'package:flutter/material.dart';

class BlockWidget extends StatelessWidget {
  const BlockWidget({super.key, required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        child,
        Positioned(
          left: 0,
          top: 0,
          right: 0,
          bottom: 0,
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              decoration: BoxDecoration(color: THEME.blockUIBackground()),
              child: Center(
                child: Text(
                  AppLocalizations.of(context)!.waitPlease,
                  style: THEME.texts.headingBold.copyWith(
                    color: THEME.blockUIOnBackground(),
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
