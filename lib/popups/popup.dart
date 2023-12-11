import 'dart:async';

import 'package:ctrader_example_app/main.dart';
import 'package:ctrader_example_app/popups/popup_constants.dart' as popup_constants;
import 'package:ctrader_example_app/popups/popup_manager.dart';
import 'package:ctrader_example_app/widgets/button_primary.dart';
import 'package:ctrader_example_app/widgets/wrapped_checkbox.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class PopupResult {
  PopupResult(this.agree, this.payload);

  final bool agree;
  final Map<String, dynamic> payload;
}

class Popup extends StatefulWidget {
  const Popup({
    super.key,
    required this.completer,
    required this.payload,
    this.title,
    this.message,
    this.checkbox,
    this.content,
    this.buttons,
    this.buttonsAxis,
  }) : assert(message != null || content != null, 'message or content param should be provided');
  static const String PAYLOAD_CHECKBOX_KEY = 'checkbox_checked';

  final Completer<PopupResult> completer;
  final Map<String, dynamic> payload;
  final String? title;
  final String? message;
  final String? checkbox;
  final List<Widget>? content;
  final List<Widget>? buttons;
  final Axis? buttonsAxis;

  @override
  State<Popup> createState() => _PopupState();

  void closeWithResult(bool success, [Map<String, dynamic>? payload]) {
    if (payload != null) this.payload.addAll(payload);

    GetIt.I<PopupManager>().removePopup(this);
    completer.complete(PopupResult(success, this.payload));
  }
}

class _PopupState extends State<Popup> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Stack(children: <Widget>[
          Positioned.fill(child: GestureDetector(onTap: () {}, child: Container(color: THEME.blockUIBackground()))),
          Positioned.fill(
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                constraints: BoxConstraints(
                  minHeight: 40,
                  minWidth: constraints.maxWidth * 0.9,
                  maxWidth: constraints.maxWidth * 0.9,
                  maxHeight: constraints.maxHeight * 0.9,
                ),
                decoration: BoxDecoration(
                  color: THEME.background(),
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: <BoxShadow>[
                    BoxShadow(color: THEME.popupShadow(), blurRadius: 12, spreadRadius: 4, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (widget.title != null) popupTitle(),
                    for (final Widget w in popupContent()) w,
                    if (widget.checkbox != null) popupCheckbox(),
                    const SizedBox(height: 12),
                    popupButtons(),
                  ],
                ),
              ),
            ),
          ),
        ]);
      },
    );
  }

  Widget popupTitle() {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(widget.title!, style: popup_constants.textStyleTitle),
    );
  }

  List<Widget> popupContent() {
    if (widget.message != null) return <Widget>[Text(widget.message!, style: popup_constants.textStyleBody)];

    return widget.content!;
  }

  Widget popupCheckbox() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            WrappedCheckbox(
              selected: widget.payload[Popup.PAYLOAD_CHECKBOX_KEY] == true,
              onTap: () => setState(() => widget.payload[Popup.PAYLOAD_CHECKBOX_KEY] = !(widget.payload[Popup.PAYLOAD_CHECKBOX_KEY] == true)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.checkbox!,
                  style: popup_constants.textStyleBody.copyWith(height: 1),
                  softWrap: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget popupButtons() {
    if (widget.buttons != null && widget.buttons!.isNotEmpty) {
      return Flex(direction: widget.buttonsAxis ?? Axis.horizontal, children: widget.buttons!);
    } else {
      return Center(
        child: ButtonPrimary(
          label: 'OK',
          width: popup_constants.singleButtonSize.width,
          height: popup_constants.singleButtonSize.height,
          onTap: () => widget.closeWithResult(false, widget.payload),
        ),
      );
    }
  }
}
