import 'package:flutter/material.dart';

class PetHitArea extends StatelessWidget {
  const PetHitArea({
    required this.child,
    this.onPanStart,
    this.onPanEnd,
    this.onSecondaryTapDown,
    super.key,
  });

  final Widget child;
  final GestureDragStartCallback? onPanStart;
  final GestureDragEndCallback? onPanEnd;
  final GestureTapDownCallback? onSecondaryTapDown;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onPanStart: onPanStart,
      onPanEnd: onPanEnd,
      onSecondaryTapDown: onSecondaryTapDown,
      child: child,
    );
  }
}
