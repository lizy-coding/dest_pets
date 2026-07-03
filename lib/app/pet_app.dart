import 'package:flutter/material.dart';

import '../desktop/desktop_window_controller.dart';
import '../pet/pet_scene.dart';
import '../pet/pet_package_repository.dart';
import '../settings/pet_settings.dart';

class PetApp extends StatelessWidget {
  const PetApp({
    required this.windowController,
    required this.settings,
    this.petPackageRepository,
    super.key,
  });

  final DesktopWindowController windowController;
  final PetSettings settings;
  final PetPackageRepository? petPackageRepository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      home: PetScene(
        windowController: windowController,
        settings: settings,
        petPackageRepository: petPackageRepository,
      ),
    );
  }
}
