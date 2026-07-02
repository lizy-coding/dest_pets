import 'package:flutter/material.dart';

import '../desktop/desktop_window_controller.dart';

class PetHitArea extends StatelessWidget {
  const PetHitArea({
    required this.windowController,
    required this.child,
    super.key,
  });

  final DesktopWindowController windowController;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onPanStart: (_) => windowController.startDragging(),
      child: child,
    );
  }
}
