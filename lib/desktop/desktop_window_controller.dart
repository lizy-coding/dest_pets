import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:window_manager/window_manager.dart';

import '../settings/pet_settings.dart';
import 'macos_window_bootstrap.dart';

class DesktopWindowController with WindowListener {
  DesktopWindowController({required PetSettings settings})
    : _settings = settings;

  final PetSettings _settings;
  Timer? _persistDebounce;
  bool _initialized = false;

  bool get supportsNativeWindowControl =>
      !kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux);

  Future<void> initialize() async {
    if (_initialized || !supportsNativeWindowControl) {
      return;
    }

    if (Platform.isMacOS) {
      await MacosWindowBootstrap(settings: _settings).initialize();
    }

    windowManager.addListener(this);
    _initialized = true;
  }

  Future<void> startDragging() async {
    if (!_initialized || !supportsNativeWindowControl) {
      return;
    }

    await windowManager.startDragging();
  }

  Future<void> close() async {
    if (!_initialized || !supportsNativeWindowControl) {
      return;
    }

    await windowManager.close();
  }

  @override
  void onWindowMoved() {
    _persistDebounce?.cancel();
    _persistDebounce = Timer(const Duration(milliseconds: 250), () {
      unawaited(_persistCurrentPosition());
    });
  }

  Future<void> _persistCurrentPosition() async {
    try {
      final position = await windowManager.getPosition();
      await _settings.saveWindowPosition(position);
    } catch (_) {
      // Window position persistence is best-effort during early desktop PoC work.
    }
  }

  void dispose() {
    _persistDebounce?.cancel();
    if (_initialized && supportsNativeWindowControl) {
      windowManager.removeListener(this);
    }
    _initialized = false;
  }
}
