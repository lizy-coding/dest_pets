import 'dart:io';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'package:window_manager/window_manager.dart';

import 'auxiliary_window_arguments.dart';

class AuxiliaryWindowBootstrap {
  AuxiliaryWindowBootstrap({required this.currentWindowController});

  static const Size contextMenuSize = Size(280, 420);
  static const double _screenMargin = 8;

  final WindowController currentWindowController;

  bool get supportsNativeWindowControl =>
      !kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux);

  Future<void> initialize(AuxiliaryWindowArguments arguments) async {
    if (!supportsNativeWindowControl) {
      return;
    }

    await windowManager.ensureInitialized();
    await _registerWindowMethodHandler();

    switch (arguments.type) {
      case AuxiliaryWindowType.contextMenu:
        await _initializeContextMenu(arguments);
    }
  }

  Future<void> _initializeContextMenu(
    AuxiliaryWindowArguments arguments,
  ) async {
    final options = WindowOptions(
      size: contextMenuSize,
      minimumSize: contextMenuSize,
      maximumSize: contextMenuSize,
      alwaysOnTop: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: true,
      title: 'Desktop Pet Menu',
      titleBarStyle: TitleBarStyle.hidden,
      windowButtonVisibility: false,
    );

    await windowManager.waitUntilReadyToShow(options);
    await windowManager.setResizable(false);
    await windowManager.setMaximizable(false);
    await windowManager.setMinimizable(false);
    await windowManager.setHasShadow(false);
    await windowManager.setBackgroundColor(Colors.transparent);
    await windowManager.setPosition(
      await _contextMenuPosition(arguments.anchorGlobalPosition),
    );
    await windowManager.show();
    await windowManager.focus();
  }

  Future<void> _registerWindowMethodHandler() async {
    await currentWindowController.setWindowMethodHandler((call) async {
      if (call.method == 'window_close') {
        await windowManager.close();
        return null;
      }

      throw MissingPluginException('Unknown method ${call.method}');
    });
  }

  Future<Offset> _contextMenuPosition(Offset anchor) async {
    final display = await _displayForAnchor(anchor);
    final visiblePosition = display.visiblePosition ?? Offset.zero;
    final visibleSize = display.visibleSize ?? display.size;
    final minX = visiblePosition.dx + _screenMargin;
    final minY = visiblePosition.dy + _screenMargin;
    final maxX =
        visiblePosition.dx +
        visibleSize.width -
        contextMenuSize.width -
        _screenMargin;
    final maxY =
        visiblePosition.dy +
        visibleSize.height -
        contextMenuSize.height -
        _screenMargin;

    return Offset(
      anchor.dx.clamp(minX, maxX).toDouble(),
      anchor.dy.clamp(minY, maxY).toDouble(),
    );
  }

  Future<Display> _displayForAnchor(Offset anchor) async {
    final displays = await screenRetriever.getAllDisplays();
    for (final display in displays) {
      final visiblePosition = display.visiblePosition ?? Offset.zero;
      final visibleSize = display.visibleSize ?? display.size;
      final rect = visiblePosition & visibleSize;
      if (rect.contains(anchor)) {
        return display;
      }
    }

    return screenRetriever.getPrimaryDisplay();
  }
}
