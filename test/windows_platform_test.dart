import 'package:desktop_pet/desktop/platform_capabilities.dart';
import 'package:desktop_pet/desktop/windows_window_bootstrap.dart';
import 'package:desktop_pet/settings/settings_store.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:screen_retriever/screen_retriever.dart';

void main() {
  test('Windows capabilities expose the supported desktop surface', () {
    final capabilities = PlatformCapabilities.forPlatform(
      DesktopPlatform.windows,
    );

    expect(capabilities.platform, DesktopPlatform.windows);
    expect(capabilities.supportsNativeWindowControl, isTrue);
    expect(capabilities.supportsAuxiliaryWindows, isTrue);
    expect(capabilities.supportsTransparency, isTrue);
    expect(capabilities.supportsClickThrough, isTrue);
    expect(capabilities.supportsTray, isTrue);
    expect(capabilities.supportsLaunchAtStartup, isTrue);
    expect(capabilities.supportsGlobalShortcut, isFalse);
  });

  test(
    'Windows bootstrap skips the taskbar and uses shared placement',
    () async {
      final bootstrap = WindowsWindowBootstrap(
        settingsStore: SettingsStore(),
        primaryDisplayProvider: () async => const Display(
          id: 'windows-display',
          size: Size(1920, 1080),
          visiblePosition: Offset.zero,
          visibleSize: Size(1920, 1040),
        ),
      );

      expect(bootstrap.skipTaskbar, isTrue);
      expect(await bootstrap.defaultPosition(), const Offset(1688, 808));
    },
  );
}
