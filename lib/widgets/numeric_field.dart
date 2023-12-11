import 'package:ctrader_example_app/main.dart';
import 'package:flutter/material.dart';

class NumericField extends StatefulWidget {
  const NumericField({
    super.key,
    required this.value,
    this.textStyle,
    this.height,
    this.decimals,
    required this.onChange,
  });

  final String value;
  final int? decimals;
  final TextStyle? textStyle;
  final double? height;
  final void Function(double value) onChange;

  @override
  State<NumericField> createState() => _NumericFieldState();
}

class _NumericFieldState extends State<NumericField> {
  final TextEditingController _controller = TextEditingController();
  bool _isEditing = false;

  @override
  Widget build(BuildContext context) {
    _updateVisualText();

    return Container(
      height: widget.height ?? 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: THEME.inputBorder()),
        borderRadius: BorderRadius.circular(2),
      ),
      child: TextField(
        controller: _controller,
        autocorrect: false,
        textAlign: TextAlign.center,
        textAlignVertical: TextAlignVertical.center,
        style: widget.textStyle ?? THEME.texts.input,
        keyboardType: TextInputType.number,
        expands: true,
        minLines: null,
        maxLines: null,
        decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.zero),
        onTap: _startEditing,
        onEditingComplete: _finishedEditing,
        onTapOutside: (PointerDownEvent p) => _finishedEditing(),
      ),
    );
  }

  void _startEditing() {
    _isEditing = true;
    _controller.text = _controller.text.replaceAll(RegExp('[^0-9.]'), '');
  }

  void _finishedEditing() {
    if (!_isEditing) return;

    FocusManager.instance.primaryFocus?.unfocus();
    _isEditing = false;

    final String value = _controller.text.replaceAll(RegExp('[^0-9.]'), '');
    widget.onChange(double.tryParse(value) ?? 0.0);
  }

  void _updateVisualText() {
    if (!_isEditing) {
      _controller.text = widget.value;
    }
  }
}
