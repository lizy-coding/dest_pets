import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../desktop/desktop_window_controller.dart';
import '../pet/controller/pet_appearance_controller.dart';
import '../pet/data/pet_resource_repository.dart';
import '../pet/data/pet_settings_store.dart';
import '../pet/pet_scene.dart';
import '../pet/pet_package_repository.dart';
import '../settings/pet_settings.dart';

class PetApp extends StatelessWidget {
  const PetApp({
    required this.windowController,
    required this.settings,
    this.petPackageRepository,
    this.petResourceRepository,
    this.petSettingsStore,
    super.key,
  });

  final DesktopWindowController windowController;
  final PetSettings settings;
  final PetPackageRepository? petPackageRepository;
  final PetResourceRepository? petResourceRepository;
  final PetSettingsStore? petSettingsStore;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<PetResourceRepository>(
          create: (_) {
            final repository = petResourceRepository;
            if (repository != null) {
              return repository;
            }

            final packageRepository = petPackageRepository;
            if (packageRepository != null) {
              return PetPackageResourceRepositoryAdapter(packageRepository);
            }

            return PetResourceRepository();
          },
        ),
        Provider<PetSettingsStore>(
          create: (_) => petSettingsStore ?? PetSettingsStore(),
        ),
      ],
      child: Builder(
        builder: (context) {
          return ChangeNotifierProvider<PetAppearanceController>(
            create: (_) => PetAppearanceController(
              resourceRepository: context.read<PetResourceRepository>(),
              settingsStore: context.read<PetSettingsStore>(),
            ),
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
              home: PetScene(windowController: windowController),
            ),
          );
        },
      ),
    );
  }
}
