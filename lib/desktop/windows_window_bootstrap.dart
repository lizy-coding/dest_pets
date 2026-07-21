import 'package:flutter/services.dart';

import 'window_bootstrap.dart';

class WindowsWindowBootstrap extends DesktopWindowBootstrap {
  WindowsWindowBootstrap({
    required super.settingsStore,
    super.primaryDisplayProvider,
  });

  static const _channel = MethodChannel('desktop_pet/suppress_dwm_border');

  @override
  bool get skipTaskbar => true;

  @override
  Future<void> applyPlatformSpecificOptions() async {
    try {
      await _channel.invokeMethod<void>('suppress');
    } on MissingPluginException {
      // Method channel not registered; pre-creation suppression already handled.
    }
  }
}
