import 'package:flutter/widgets.dart';

import 'app/pet_app.dart';
import 'desktop/desktop_window_controller.dart';
import 'settings/pet_settings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final settings = PetSettings();
  final windowController = DesktopWindowController(settings: settings);
  await windowController.initialize();

  runApp(PetApp(windowController: windowController));
}
