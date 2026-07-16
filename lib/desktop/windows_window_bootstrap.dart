import 'window_bootstrap.dart';

class WindowsWindowBootstrap extends DesktopWindowBootstrap {
  WindowsWindowBootstrap({
    required super.settingsStore,
    super.primaryDisplayProvider,
  });

  @override
  bool get skipTaskbar => true;
}
