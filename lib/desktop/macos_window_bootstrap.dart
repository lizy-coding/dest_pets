import 'package:window_manager/window_manager.dart';

import 'window_bootstrap.dart';

class MacosWindowBootstrap extends DesktopWindowBootstrap {
  MacosWindowBootstrap({required super.settingsStore});

  @override
  bool get skipTaskbar => false;

  @override
  Future<void> applyPlatformSpecificOptions() async {
    await windowManager.setVisibleOnAllWorkspaces(true);
  }
}
