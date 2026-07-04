import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../desktop/desktop_window_controller.dart';
import '../pet/controller/pet_controller.dart';
import '../pet/view/pet_view.dart';
import '../resources/data/pet_resource_repository.dart';
import '../settings/settings_store.dart';

class App extends StatelessWidget {
  const App({
    required this.windowController,
    this.settingsStore,
    this.resourceRepository,
    this.petController,
    super.key,
  });

  final DesktopWindowController windowController;
  final SettingsStore? settingsStore;
  final PetResourceRepository? resourceRepository;
  final PetController? petController;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<SettingsStore>(
          create: (_) => settingsStore ?? SettingsStore(),
        ),
        Provider<PetResourceRepository>(
          create: (_) => resourceRepository ?? PetResourceRepository(),
        ),
      ],
      child: Builder(
        builder: (context) {
          return ChangeNotifierProvider<PetController>(
            create: (_) {
              final controller =
                  petController ??
                  PetController(
                    resourceRepository: context.read<PetResourceRepository>(),
                    settingsStore: context.read<SettingsStore>(),
                  );
              unawaited(controller.initialize());
              return controller;
            },
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              color: Colors.transparent,
              theme: ThemeData(
                useMaterial3: true,
                brightness: Brightness.light,
                scaffoldBackgroundColor: Colors.transparent,
                canvasColor: Colors.transparent,
              ),
              builder: (context, child) {
                return ColoredBox(
                  color: Colors.transparent,
                  child: child ?? const SizedBox.shrink(),
                );
              },
              home: PetView(windowController: windowController),
            ),
          );
        },
      ),
    );
  }
}
