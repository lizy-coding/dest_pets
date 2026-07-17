import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:desktop_pet/desktop/auxiliary_window_bootstrap.dart';
import 'package:desktop_pet/desktop/platform_capabilities.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:screen_retriever/screen_retriever.dart';

void main() {
  test('contextMenuPosition clamps inside display containing anchor', () async {
    final bootstrap = AuxiliaryWindowBootstrap(
      currentWindowController: WindowController.fromWindowId('test'),
      capabilities: const PlatformCapabilities(
        platform: DesktopPlatform.macos,
        supportsNativeWindowControl: true,
        supportsAuxiliaryWindows: true,
        supportsTransparency: true,
        supportsClickThrough: true,
        supportsTray: true,
        supportsLaunchAtStartup: true,
        supportsGlobalShortcut: false,
      ),
      allDisplaysProvider: () async => const [
        Display(id: 'left', size: Size(800, 600)),
        Display(
          id: 'right',
          size: Size(800, 600),
          visiblePosition: Offset(800, 0),
          visibleSize: Size(800, 600),
        ),
      ],
      primaryDisplayProvider: () async =>
          const Display(id: 'left', size: Size(800, 600)),
    );

    expect(
      await bootstrap.contextMenuPosition(const Offset(1500, 500)),
      const Offset(1312, 172),
    );
  });

  test('contextMenuPosition falls back when display APIs fail', () async {
    final bootstrap = AuxiliaryWindowBootstrap(
      currentWindowController: WindowController.fromWindowId('test'),
      capabilities: const PlatformCapabilities(
        platform: DesktopPlatform.macos,
        supportsNativeWindowControl: true,
        supportsAuxiliaryWindows: true,
        supportsTransparency: true,
        supportsClickThrough: true,
        supportsTray: true,
        supportsLaunchAtStartup: true,
        supportsGlobalShortcut: false,
      ),
      allDisplaysProvider: () async => throw StateError('all displays failed'),
      primaryDisplayProvider: () async => throw StateError('primary failed'),
    );

    expect(
      await bootstrap.contextMenuPosition(const Offset(100, 100)),
      AuxiliaryWindowBootstrap.fallbackContextMenuPosition,
    );
  });
}
