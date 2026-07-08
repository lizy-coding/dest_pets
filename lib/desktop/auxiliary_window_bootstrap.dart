import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'package:window_manager/window_manager.dart';

import 'auxiliary_window_arguments.dart';
import 'platform_capabilities.dart';

typedef AllDisplaysProvider = Future<List<Display>> Function();
typedef AuxiliaryPrimaryDisplayProvider = Future<Display> Function();

class AuxiliaryWindowBootstrap {
  AuxiliaryWindowBootstrap({
    required this.currentWindowController,
    PlatformCapabilities? capabilities,
    @visibleForTesting AllDisplaysProvider? allDisplaysProvider,
    @visibleForTesting AuxiliaryPrimaryDisplayProvider? primaryDisplayProvider,
  }) : _capabilities = capabilities ?? PlatformCapabilities.current(),
       _allDisplaysProvider =
           allDisplaysProvider ?? screenRetriever.getAllDisplays,
       _primaryDisplayProvider =
           primaryDisplayProvider ?? screenRetriever.getPrimaryDisplay;

  static const Size contextMenuSize = Size(280, 420);
  static const double _screenMargin = 8;
  static const Offset fallbackContextMenuPosition = Offset(
    _screenMargin,
    _screenMargin,
  );

  final WindowController currentWindowController;
  final PlatformCapabilities _capabilities;
  final AllDisplaysProvider _allDisplaysProvider;
  final AuxiliaryPrimaryDisplayProvider _primaryDisplayProvider;

  bool get supportsNativeWindowControl =>
      _capabilities.supportsNativeWindowControl;

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
      await contextMenuPosition(arguments.anchorGlobalPosition),
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

  @visibleForTesting
  Future<Offset> contextMenuPosition(Offset anchor) async {
    final display = await _displayForAnchor(anchor);
    if (display == null) {
      return fallbackContextMenuPosition;
    }

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

  Future<Display?> _displayForAnchor(Offset anchor) async {
    final displays = await _safeAllDisplays();
    for (final display in displays) {
      final visiblePosition = display.visiblePosition ?? Offset.zero;
      final visibleSize = display.visibleSize ?? display.size;
      final rect = visiblePosition & visibleSize;
      if (rect.contains(anchor)) {
        return display;
      }
    }

    return _safePrimaryDisplay();
  }

  Future<List<Display>> _safeAllDisplays() async {
    try {
      return await _allDisplaysProvider();
    } on Object {
      return const [];
    }
  }

  Future<Display?> _safePrimaryDisplay() async {
    try {
      return await _primaryDisplayProvider();
    } on Object {
      return null;
    }
  }
}
