import 'package:ctrader_example_app/main.dart';
import 'package:flutter/material.dart';

class WrappedSwitch extends StatelessWidget {
  const WrappedSwitch({super.key, required this.selected, required this.onChange, this.disabled});

  final bool? selected;
  final bool? disabled;
  final void Function(bool value) onChange;

  @override
  Widget build(BuildContext context) {
    Color background;
    Color thumb;

    if (disabled == true) {
      background = selected == true ? THEME.switchBackgroundSelectedDisabled() : THEME.switchBackgroundDisabled();
      thumb = selected == true ? THEME.switchThumbSelectedDisabled() : THEME.switchThumbDisabled();
    } else {
      background = selected == true ? THEME.switchBackgroundSelected() : THEME.switchBackground();
      thumb = selected == true ? THEME.switchThumbSelected() : THEME.switchThumb();
    }

    return GestureDetector(
      onTap: () => disabled == true ? null : onChange(selected == !true),
      child: Stack(
        children: <Widget>[
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 20,
            width: 34,
            decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(20)),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            top: 2,
            left: selected == true ? 16 : 2,
            child: Container(
              height: 16,
              width: 16,
              decoration: BoxDecoration(color: thumb, borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ],
      ),
    );
  }
}
