import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../desktop/auxiliary_window_controller.dart';
import '../desktop/pet_window_service.dart';
import '../pet/model/pet_menu_action.dart';
import '../pet/controller/pet_controller.dart';
import '../pet/view/pet_view.dart';
import '../resources/data/pet_resource_repository.dart';
import '../settings/settings_store.dart';

class App extends StatelessWidget {
  const App({
    required this.windowController,
    required this.auxiliaryWindowController,
    this.settingsStore,
    this.resourceRepository,
    this.petController,
    super.key,
  });

  final PetWindowService windowController;
  final AuxiliaryWindowController auxiliaryWindowController;
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
              final injectedController = petController;
              if (injectedController != null) {
                return injectedController;
              }

              final controller = PetController(
                resourceRepository: context.read<PetResourceRepository>(),
                settingsStore: context.read<SettingsStore>(),
              );
              unawaited(controller.initialize());
              return controller;
            },
            child: _PetMenuActionBinding(
              windowController: windowController,
              auxiliaryWindowController: auxiliaryWindowController,
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
                home: PetView(
                  windowController: windowController,
                  auxiliaryWindowController: auxiliaryWindowController,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PetMenuActionBinding extends StatefulWidget {
  const _PetMenuActionBinding({
    required this.windowController,
    required this.auxiliaryWindowController,
    required this.child,
  });

  final PetWindowService windowController;
  final AuxiliaryWindowController auxiliaryWindowController;
  final Widget child;

  @override
  State<_PetMenuActionBinding> createState() => _PetMenuActionBindingState();
}

class _PetMenuActionBindingState extends State<_PetMenuActionBinding> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    unawaited(
      widget.auxiliaryWindowController.initializePetMenuActionHandler(
        handlePetMenuAction,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  Future<void> handlePetMenuAction(PetMenuAction action) async {
    if (!action.enabled || !mounted) {
      return;
    }

    final controller = context.read<PetController>();
    switch (action.type) {
      case PetMenuActionType.switchPet:
        final petId = action.petId;
        if (petId != null) {
          await controller.switchPet(petId);
        }
      case PetMenuActionType.increaseScale:
        await controller.increaseScale();
      case PetMenuActionType.decreaseScale:
        await controller.decreaseScale();
      case PetMenuActionType.resetScale:
        await controller.resetScale();
      case PetMenuActionType.toggleAlwaysOnTop:
        final value = !controller.state.config.alwaysOnTop;
        await controller.setAlwaysOnTop(value);
        await widget.windowController.setAlwaysOnTop(value);
      case PetMenuActionType.refreshResources:
        await controller.refreshResources();
      case PetMenuActionType.resetConfig:
        await controller.resetConfig();
        await widget.windowController.setAlwaysOnTop(
          controller.state.config.alwaysOnTop,
        );
      case PetMenuActionType.recoverFromError:
        await controller.recoverFromError();
      case PetMenuActionType.quit:
        await widget.windowController.close();
    }
  }
}
