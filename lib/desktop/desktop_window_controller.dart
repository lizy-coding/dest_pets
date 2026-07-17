import 'package:flutter/widgets.dart';
import 'package:window_manager/window_manager.dart';

import 'pet_window_service.dart';
import 'platform_capabilities.dart';
import 'window_bootstrap.dart';

class DesktopWindowController with WindowListener implements PetWindowService {
  DesktopWindowController({
    this.windowBootstrap,
    PlatformCapabilities? capabilities,
  }) : _capabilities = capabilities ?? PlatformCapabilities.current();

  final WindowBootstrap? windowBootstrap;
  final PlatformCapabilities _capabilities;
  bool _initialized = false;

  bool get supportsNativeWindowControl =>
      _capabilities.supportsNativeWindowControl;

  @override
  PlatformCapabilities get capabilities => _capabilities;

  @override
  Future<void> initialize() async {
    if (_initialized || !supportsNativeWindowControl) {
      return;
    }

    await windowBootstrap?.initialize();

    windowManager.addListener(this);
    _initialized = true;
  }

  @override
  Future<void> startDragging() async {
    if (!_initialized || !supportsNativeWindowControl) {
      return;
    }

    await windowManager.startDragging();
  }

  @override
  Future<Offset?> getPosition() async {
    if (!_initialized || !supportsNativeWindowControl) {
      return null;
    }

    return windowManager.getPosition();
  }

  @override
  Future<void> setAlwaysOnTop(bool value) async {
    if (!_initialized || !supportsNativeWindowControl) {
      return;
    }

    await windowManager.setAlwaysOnTop(value);
  }

  @override
  Future<void> setTransparent(bool value) async {
    if (!_initialized || !supportsNativeWindowControl) {
      return;
    }

    await windowManager.setBackgroundColor(
      value ? const Color(0x00000000) : const Color(0xFFFFFFFF),
    );
  }

  @override
  Future<void> setFrameless(bool value) async {
    if (!_initialized || !supportsNativeWindowControl) {
      return;
    }

    await windowManager.setTitleBarStyle(
      value ? TitleBarStyle.hidden : TitleBarStyle.normal,
      windowButtonVisibility: !value,
    );
  }

  @override
  Future<void> setClickThrough(bool value) async {
    if (!_initialized || !supportsNativeWindowControl) {
      return;
    }

    await windowManager.setIgnoreMouseEvents(value);
  }

  @override
  Future<void> setSize(Size size) async {
    if (!_initialized || !supportsNativeWindowControl) {
      return;
    }

    await windowManager.setSize(size);
  }

  @override
  Future<void> setPosition(Offset position) async {
    if (!_initialized || !supportsNativeWindowControl) {
      return;
    }

    await windowManager.setPosition(position);
  }

  @override
  Future<void> show() async {
    if (!_initialized || !supportsNativeWindowControl) {
      return;
    }

    await windowManager.show();
  }

  @override
  Future<void> hide() async {
    if (!_initialized || !supportsNativeWindowControl) {
      return;
    }

    await windowManager.hide();
  }

  @override
  Future<void> close() async {
    if (!_initialized || !supportsNativeWindowControl) {
      return;
    }

    await windowManager.close();
  }

  @override
  void onWindowMoved() {}

  @override
  void dispose() {
    if (_initialized && supportsNativeWindowControl) {
      windowManager.removeListener(this);
    }
    _initialized = false;
  }
}
