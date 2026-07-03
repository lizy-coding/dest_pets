import 'dart:async';

import 'package:flutter/foundation.dart';

class PetAnimationController {
  PetAnimationController({required List<Duration> frameDurations})
    : frameDurations = List.unmodifiable(frameDurations),
      _currentFrame = ValueNotifier<int>(0);

  final List<Duration> frameDurations;
  final ValueNotifier<int> _currentFrame;
  Timer? _timer;

  int get frameCount => frameDurations.length;

  Listenable get listenable => _currentFrame;

  int get currentFrame {
    return _currentFrame.value;
  }

  void startIdleLoop() {
    if (frameCount <= 1) {
      return;
    }

    _scheduleNextFrame();
  }

  void dispose() {
    _timer?.cancel();
    _currentFrame.dispose();
  }

  void _scheduleNextFrame() {
    _timer?.cancel();
    _timer = Timer(frameDurations[_currentFrame.value], () {
      _currentFrame.value = (_currentFrame.value + 1) % frameCount;
      _scheduleNextFrame();
    });
  }
}
