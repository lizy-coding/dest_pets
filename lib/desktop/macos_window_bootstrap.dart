import 'package:flutter/material.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'package:window_manager/window_manager.dart';

import '../settings/settings_store.dart';

class MacosWindowBootstrap {
  MacosWindowBootstrap({required SettingsStore settingsStore})
    : _settingsStore = settingsStore;

  static const Size windowSize = Size(200, 200);
  static const String windowTitle = 'Desktop Pet';
  static const double _screenMargin = 32;

  final SettingsStore _settingsStore;

  Future<void> initialize() async {
    await windowManager.ensureInitialized();

    final config = await _settingsStore.loadConfig();
    final options = WindowOptions(
      size: windowSize,
      minimumSize: windowSize,
      maximumSize: windowSize,
      alwaysOnTop: config?.alwaysOnTop ?? true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
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
    await windowManager.setVisibleOnAllWorkspaces(true);
    await windowManager.setPosition(
      config?.windowPosition ?? await _defaultPosition(),
    );
    await windowManager.show(inactive: true);
  }

  Future<Offset> _defaultPosition() async {
    final display = await screenRetriever.getPrimaryDisplay();
    final visiblePosition = display.visiblePosition ?? Offset.zero;
    final visibleSize = display.visibleSize ?? display.size;

    return Offset(
      visiblePosition.dx + visibleSize.width - windowSize.width - _screenMargin,
      visiblePosition.dy +
          visibleSize.height -
          windowSize.height -
          _screenMargin,
    );
  }
}
