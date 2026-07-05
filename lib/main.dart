import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/widgets.dart';

import 'app/app.dart';
import 'app/pet_menu_window_app.dart';
import 'desktop/auxiliary_window_arguments.dart';
import 'desktop/auxiliary_window_bootstrap.dart';
import 'desktop/desktop_auxiliary_window_controller.dart';
import 'desktop/desktop_window_controller.dart';
import 'settings/settings_store.dart';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  final currentWindowController = await WindowController.fromCurrentEngine();
  final windowArguments = currentWindowController.arguments;
  if (windowArguments.isNotEmpty) {
    await _runAuxiliaryWindow(currentWindowController, windowArguments);
    return;
  }

  final settingsStore = SettingsStore();
  final windowController = DesktopWindowController(
    settingsStore: settingsStore,
  );
  final auxiliaryWindowController = DesktopAuxiliaryWindowController();
  await windowController.initialize();

  runApp(
    App(
      windowController: windowController,
      auxiliaryWindowController: auxiliaryWindowController,
      settingsStore: settingsStore,
    ),
  );
}

Future<void> _runAuxiliaryWindow(
  WindowController currentWindowController,
  String windowArguments,
) async {
  final arguments = AuxiliaryWindowArguments.fromJsonString(windowArguments);
  await AuxiliaryWindowBootstrap(
    currentWindowController: currentWindowController,
  ).initialize(arguments);

  switch (arguments.type) {
    case AuxiliaryWindowType.contextMenu:
      runApp(PetMenuWindowApp(snapshot: arguments.snapshot!));
    case AuxiliaryWindowType.settingsPanel:
      throw UnimplementedError('Settings panel window is not implemented.');
  }
}
