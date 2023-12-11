import 'package:ctrader_example_app/main.dart';
import 'package:ctrader_example_app/styles/itheme_config.dart';
import 'package:flutter/material.dart';

class BlockLoginUI extends StatelessWidget {
  const BlockLoginUI({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final IThemeConfig theme = THEMES[ThemeType.dark.index];
    return GestureDetector(
      onTap: () {},
      child: Container(
        color: theme.blockUIBackground(),
        alignment: Alignment.center,
        child: Text(
          label,
          style: theme.texts.headingBold.copyWith(
            color: theme.blockUIOnBackground(),
            decoration: TextDecoration.none,
          ),
        ),
      ),
    );
  }
}
