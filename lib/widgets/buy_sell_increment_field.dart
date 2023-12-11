import 'dart:async';
import 'dart:math';

import 'package:ctrader_example_app/extensions.dart';
import 'package:ctrader_example_app/main.dart';
import 'package:ctrader_example_app/widgets/numeric_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BuySellIncrementField extends StatefulWidget {
  const BuySellIncrementField({
    super.key,
    this.value,
    this.minVolume,
    this.maxVolume,
    required this.step,
    this.decimals,
    required this.onChange,
    this.minusButtonDisabled,
    this.plusButtonDisabled,
  });

  final double? value;
  final double? minVolume;
  final double? maxVolume;
  final double step;
  final int? decimals;
  final bool? minusButtonDisabled;
  final bool? plusButtonDisabled;
  final void Function(double value) onChange;

  @override
  State<BuySellIncrementField> createState() => _BuySellIncrementFieldState();
}

class _BuySellIncrementFieldState extends State<BuySellIncrementField> {
  Timer? _longPressTimer;
  int? _longPressTS;

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
      _button(
          SvgPicture.asset(
            'assets/svg/minus.svg',
            width: 8,
            colorFilter: (widget.minusButtonDisabled == true ? THEME.inputBorderDisabled() : THEME.onBackground()).asFilter,
          ),
          _onTapMinus,
          widget.minusButtonDisabled),
      const SizedBox(width: 12),
      SizedBox(
          width: 112,
          child: NumericField(
            value: widget.value != null ? widget.value!.toComaSeparated(decimals: widget.decimals ?? 0) : '----',
            decimals: widget.decimals ?? 0,
            textStyle: THEME.texts.inputIncremenet,
            height: 36,
            onChange: _onChangeValue,
          )),
      const SizedBox(width: 12),
      _button(
          SvgPicture.asset(
            'assets/svg/plus.svg',
            width: 10,
            colorFilter: (widget.plusButtonDisabled == true ? THEME.inputBorderDisabled() : THEME.onBackground()).asFilter,
          ),
          _onTapPlus,
          widget.plusButtonDisabled),
    ]);
  }

  Widget _button(Widget label, Function([int?]) onTap, [bool? disabled]) {
    return GestureDetector(
      onTap: disabled == true ? null : onTap,
      onLongPressStart: (LongPressStartDetails details) {
        if (disabled == true) return;
        _longPressTimer?.cancel();
        _longPressTS = DateTime.now().millisecondsSinceEpoch;

        _longPressTimer = Timer.periodic(const Duration(milliseconds: 100), (Timer timer) {
          final int delta = (DateTime.now().millisecondsSinceEpoch - (_longPressTS ?? 0)) ~/ 100 * 100;
          if (delta > 2000 || delta % 300 == 0) {
            onTap(delta > 4000 ? 10 : 1);
          }
        });

        onTap();
      },
      onLongPressEnd: (LongPressEndDetails details) {
        _longPressTimer?.cancel();
        _longPressTimer = null;
      },
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(color: disabled == true ? THEME.inputBorderDisabled() : THEME.inputBorder()),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Center(child: label),
      ),
    );
  }

  void _onTapMinus([int? multiplier]) {
    if (widget.value == null) {
      widget.onChange(widget.step);
    } else if (widget.minVolume == null || widget.value! > widget.minVolume!) {
      widget.onChange(widget.value! - widget.step * (multiplier ?? 1));
    }
  }

  void _onTapPlus([int? multiplier]) {
    if (widget.value == null) {
      widget.onChange(widget.step);
    } else if (widget.maxVolume == null || widget.value! < widget.maxVolume!) {
      widget.onChange(widget.value! + widget.step * (multiplier ?? 1));
    }
  }

  void _onChangeValue(double value) {
    final double amount = value / widget.step * widget.step;
    widget.onChange(min(widget.maxVolume ?? double.infinity, max(widget.minVolume ?? 0, amount)));
  }
}
