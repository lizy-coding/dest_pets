import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';

class PetAnimationController {
  PetAnimationController({
    required TickerProvider vsync,
    required this.frameCount,
    this.duration = const Duration(milliseconds: 720),
  }) : _controller = AnimationController(vsync: vsync, duration: duration);

  final int frameCount;
  final Duration duration;
  final AnimationController _controller;

  Listenable get listenable => _controller;

  int get currentFrame {
    if (frameCount <= 1) {
      return 0;
    }

    final frame = (_controller.value * frameCount).floor();
    return frame.clamp(0, frameCount - 1).toInt();
  }

  void startIdleLoop() {
    _controller.repeat();
  }

  void dispose() {
    _controller.dispose();
  }
}
