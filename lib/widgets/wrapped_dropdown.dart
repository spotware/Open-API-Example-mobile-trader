import 'package:ctrader_example_app/extensions.dart';
import 'package:ctrader_example_app/main.dart';
import 'package:ctrader_example_app/states/app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class WrappedDropdown extends StatelessWidget {
  const WrappedDropdown({super.key, required this.selected, required this.items, required this.onChange});

  final int selected;
  final List<String> items;
  final void Function(int? index) onChange;

  @override
  Widget build(BuildContext context) {
    // NOTE: this line is required to properly update theme on theme changing
    context.watch<AppState>();

    final List<DropdownMenuItem<int>> dropdownItems = <DropdownMenuItem<int>>[];
    for (int i = 0; i < items.length; i++) {
      dropdownItems.add(DropdownMenuItem<int>(
        value: i,
        child: Text(items[i], overflow: TextOverflow.ellipsis, style: THEME.texts.bodyMedium),
      ));
    }

    return Align(
      alignment: Alignment.centerRight,
      child: IntrinsicWidth(
        child: Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(border: Border.all(color: THEME.inputBorder()), borderRadius: BorderRadius.circular(2)),
          child: DropdownButton<int>(
            dropdownColor: THEME.switchBackground(),
            icon: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: SvgPicture.asset('assets/svg/arrow_dropdown.svg', colorFilter: THEME.inputIcon().asFilter),
            ),
            isExpanded: true,
            style: THEME.texts.input,
            underline: Container(),
            value: selected,
            items: dropdownItems,
            onChanged: onChange,
          ),
        ),
      ),
    );
  }
}
