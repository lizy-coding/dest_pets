import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:window_manager/window_manager.dart';

import '../settings/settings_store.dart';
import 'macos_window_bootstrap.dart';

class DesktopWindowController with WindowListener {
  DesktopWindowController({required SettingsStore settingsStore})
    : _settingsStore = settingsStore;

  final SettingsStore _settingsStore;
  bool _initialized = false;

  bool get supportsNativeWindowControl =>
      !kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux);

  Future<void> initialize() async {
    if (_initialized || !supportsNativeWindowControl) {
      return;
    }

    if (Platform.isMacOS) {
      await MacosWindowBootstrap(settingsStore: _settingsStore).initialize();
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

  Future<Offset?> getPosition() async {
    if (!_initialized || !supportsNativeWindowControl) {
      return null;
    }

    return windowManager.getPosition();
  }

  Future<void> setAlwaysOnTop(bool value) async {
    if (!_initialized || !supportsNativeWindowControl) {
      return;
    }

    await windowManager.setAlwaysOnTop(value);
  }

  Future<void> close() async {
    if (!_initialized || !supportsNativeWindowControl) {
      return;
    }

    await windowManager.close();
  }

  @override
  void onWindowMoved() {}

  void dispose() {
    if (_initialized && supportsNativeWindowControl) {
      windowManager.removeListener(this);
    }
    _initialized = false;
  }
}
