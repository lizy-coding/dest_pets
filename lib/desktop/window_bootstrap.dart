import 'package:flutter/material.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'package:window_manager/window_manager.dart';

import '../settings/settings_store.dart';

abstract class WindowBootstrap {
  Future<void> initialize();
}

abstract class DesktopWindowBootstrap implements WindowBootstrap {
  DesktopWindowBootstrap({required this.settingsStore});

  static const Size windowSize = Size(200, 200);
  static const String windowTitle = 'Desktop Pet';
  static const double screenMargin = 32;

  final SettingsStore settingsStore;

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
      config?.windowPosition ?? await defaultPosition(),
    );
    await windowManager.show(inactive: true);
  }

  Future<void> applyPlatformSpecificOptions() async {}

  Future<Offset> defaultPosition() async {
    final display = await screenRetriever.getPrimaryDisplay();
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
}
