import 'package:flutter/material.dart';

class WrappedScroll extends StatelessWidget {
  const WrappedScroll({super.key, required this.child, this.controller, this.onScrollStarted, this.onScrollFinished});

  final Widget child;
  final VoidCallback? onScrollStarted;
  final VoidCallback? onScrollFinished;
  final ScrollController? controller;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        if (notification is ScrollStartNotification && onScrollStarted != null) onScrollStarted!();
        if (notification is ScrollEndNotification && onScrollFinished != null) onScrollFinished!();

        return true;
      },
      child: SingleChildScrollView(controller: controller, child: child),
    );
  }
}
