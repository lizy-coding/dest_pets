import 'package:flutter/material.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'package:window_manager/window_manager.dart';

import '../settings/settings_store.dart';

typedef PrimaryDisplayProvider = Future<Display> Function();

abstract class WindowBootstrap {
  Future<void> initialize();
}

abstract class DesktopWindowBootstrap implements WindowBootstrap {
  DesktopWindowBootstrap({
    required this.settingsStore,
    @visibleForTesting PrimaryDisplayProvider? primaryDisplayProvider,
  }) : _primaryDisplayProvider =
           primaryDisplayProvider ?? screenRetriever.getPrimaryDisplay;

  static const Size windowSize = Size(200, 200);
  static const String windowTitle = 'Desktop Pet';
  static const double screenMargin = 32;
  static const Offset fallbackPosition = Offset(screenMargin, screenMargin);

  final SettingsStore settingsStore;
  final PrimaryDisplayProvider _primaryDisplayProvider;

  bool get skipTaskbar;

  @override
  Future<void> initialize() async {
    await windowManager.ensureInitialized();

    final config = await settingsStore.loadConfig();
    final options = WindowOptions(
      size: windowSize,
      minimumSize: windowSize,
      maximumSize: windowSize,
      alwaysOnTop: config?.alwaysOnTop ?? true,
      backgroundColor: Colors.transparent,
      skipTaskbar: skipTaskbar,
      title: windowTitle,
      titleBarStyle: TitleBarStyle.hidden,
      windowButtonVisibility: false,
    );

    await windowManager.waitUntilReadyToShow(options);
    await windowManager.setResizable(false);
    await windowManager.setMaximizable(false);
    await windowManager.setMinimizable(false);
    await windowManager.setHasShadow(false);
    await windowManager.setBackgroundColor(Colors.transparent);

    await applyPlatformSpecificOptions();

    await windowManager.setPosition(
      await safeWindowPosition(config?.windowPosition),
    );
    await windowManager.show(inactive: true);
  }

  Future<void> applyPlatformSpecificOptions() async {}

  @visibleForTesting
  Future<Offset> safeWindowPosition(Offset? requestedPosition) async {
    final display = await _safePrimaryDisplay();
    if (display == null) {
      return requestedPosition ?? fallbackPosition;
    }

    return _clampToDisplay(
      requestedPosition ?? _defaultPosition(display),
      display,
    );
  }

  Future<Offset> defaultPosition() async {
    final display = await _safePrimaryDisplay();
    if (display == null) {
      return fallbackPosition;
    }

    return _defaultPosition(display);
  }

  Future<Display?> _safePrimaryDisplay() async {
    try {
      return await _primaryDisplayProvider();
    } on Object {
      return null;
    }
  }

  Offset _defaultPosition(Display display) {
    final visiblePosition = display.visiblePosition ?? Offset.zero;
    final visibleSize = display.visibleSize ?? display.size;

    return Offset(
      visiblePosition.dx + visibleSize.width - windowSize.width - screenMargin,
      visiblePosition.dy +
          visibleSize.height -
          windowSize.height -
          screenMargin,
    );
  }

  Offset _clampToDisplay(Offset position, Display display) {
    final visiblePosition = display.visiblePosition ?? Offset.zero;
    final visibleSize = display.visibleSize ?? display.size;
    final minX = visiblePosition.dx;
    final minY = visiblePosition.dy;
    final maxX = visiblePosition.dx + visibleSize.width - windowSize.width;
    final maxY = visiblePosition.dy + visibleSize.height - windowSize.height;

    if (maxX < minX || maxY < minY) {
      return visiblePosition;
    }

    return Offset(
      position.dx.clamp(minX, maxX).toDouble(),
      position.dy.clamp(minY, maxY).toDouble(),
    );
  }
}
