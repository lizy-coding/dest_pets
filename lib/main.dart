import 'package:flutter/widgets.dart';

import 'app/app.dart';
import 'desktop/desktop_window_controller.dart';
import 'settings/settings_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final settingsStore = SettingsStore();
  final windowController = DesktopWindowController(
    settingsStore: settingsStore,
  );
  await windowController.initialize();

  runApp(App(windowController: windowController, settingsStore: settingsStore));
}
