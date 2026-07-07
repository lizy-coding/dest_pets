import 'dart:io';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'app/app.dart';
import 'app/pet_menu_window_app.dart';
import 'desktop/auxiliary_window_arguments.dart';
import 'desktop/auxiliary_window_bootstrap.dart';
import 'desktop/desktop_auxiliary_window_controller.dart';
import 'desktop/desktop_window_controller.dart';
import 'desktop/macos_window_bootstrap.dart';
import 'desktop/window_bootstrap.dart';
import 'desktop/windows_window_bootstrap.dart';
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

  final windowBootstrap = _createWindowBootstrap(settingsStore);
  final windowController = DesktopWindowController(
    windowBootstrap: windowBootstrap,
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

WindowBootstrap? _createWindowBootstrap(SettingsStore settingsStore) {
  if (kIsWeb) {
    return null;
  }

  if (Platform.isMacOS) {
    return MacosWindowBootstrap(settingsStore: settingsStore);
  }

  if (Platform.isWindows || Platform.isLinux) {
    return WindowsWindowBootstrap(settingsStore: settingsStore);
  }

  return null;
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
