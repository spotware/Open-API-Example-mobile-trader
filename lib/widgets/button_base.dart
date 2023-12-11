import 'package:flutter/material.dart';

class ButtonBase extends StatelessWidget {
  const ButtonBase({
    super.key,
    required this.label,
    required this.background,
    required this.border,
    required this.textStyle,
    required this.backgroundDisabled,
    required this.borderDisabled,
    required this.textStyleDisabled,
    this.height,
    this.width,
    this.flex,
    this.onTap,
    this.prefix,
    this.suffix,
    this.disabled,
  });

  final Color? background;
  final Color border;
  final TextStyle textStyle;
  final Color? backgroundDisabled;
  final Color borderDisabled;
  final TextStyle textStyleDisabled;
  final String label;
  final VoidCallback? onTap;
  final double? height;
  final double? width;
  final int? flex;
  final Widget? prefix;
  final Widget? suffix;
  final bool? disabled;

  @override
  Widget build(BuildContext context) {
    final GestureDetector btn = GestureDetector(
      onTap: disabled == true ? null : onTap,
      child: Container(
        width: width,
        height: height ?? 48,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: disabled == true ? backgroundDisabled : background,
          borderRadius: BorderRadius.circular(2),
          border: Border.all(color: disabled == true ? borderDisabled : border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            if (prefix != null) prefix!,
            Expanded(
              child: Text(
                label,
                style: (disabled == true ? textStyleDisabled : textStyle).copyWith(height: 1),
                textAlign: TextAlign.center,
              ),
            ),
            if (suffix != null) suffix!,
          ],
        ),
      ),
    );

    return flex == null ? btn : Flexible(flex: flex!, fit: FlexFit.tight, child: btn);
  }
}
