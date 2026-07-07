import 'window_bootstrap.dart';

class WindowsWindowBootstrap extends DesktopWindowBootstrap {
  WindowsWindowBootstrap({required super.settingsStore});

  @override
  bool get skipTaskbar => true;
}
