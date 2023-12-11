import 'package:ctrader_example_app/extensions.dart';
import 'package:ctrader_example_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class WrappedCheckbox extends StatelessWidget {
  const WrappedCheckbox({super.key, required this.selected, required this.onTap, this.disabled});

  final bool selected;
  final VoidCallback onTap;
  final bool? disabled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => disabled != true ? onTap() : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        alignment: Alignment.center,
        constraints: BoxConstraints.tight(const Size.square(20)),
        decoration: BoxDecoration(
          border: Border.all(color: THEME.inputBorder()),
          borderRadius: BorderRadius.circular(2),
          color: disabled == true ? THEME.checkboxBackgroundDisabled() : (selected ? THEME.checkboxBackgroundSelected() : Colors.transparent),
        ),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 200),
          child: SvgPicture.asset(
            'assets/svg/checkbox_mark.svg',
            width: selected ? 10 : 0,
            colorFilter: THEME.checkboxMark().asFilter,
          ),
        ),
      ),
    );
  }
}
