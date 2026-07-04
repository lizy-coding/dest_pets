import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../desktop/desktop_window_controller.dart';
import '../settings/pet_settings.dart';
import 'controller/pet_appearance_controller.dart';
import 'data/pet_resource_repository.dart';
import 'data/pet_settings_store.dart';
import 'pet_package_repository.dart';
import 'view/pet_view.dart';

class PetScene extends StatefulWidget {
  const PetScene({
    required this.windowController,
    this.settings,
    this.petPackageRepository,
    this.petResourceRepository,
    super.key,
  });

  final DesktopWindowController windowController;
  final PetSettings? settings;
  final PetPackageRepository? petPackageRepository;
  final PetResourceRepository? petResourceRepository;

  @override
  State<PetScene> createState() => _PetSceneState();
}

class _PetSceneState extends State<PetScene> {
  PetAppearanceController? _ownedController;

  @override
  void initState() {
    super.initState();

    final shouldOwnController =
        widget.settings != null ||
        widget.petPackageRepository != null ||
        widget.petResourceRepository != null;
    if (shouldOwnController) {
      final repository =
          widget.petResourceRepository ??
          (widget.petPackageRepository == null
              ? PetResourceRepository()
              : PetPackageResourceRepositoryAdapter(
                  widget.petPackageRepository!,
                ));
      _ownedController = PetAppearanceController(
        resourceRepository: repository,
        settingsStore: PetSettingsStore(),
      );
      unawaited(_ownedController!.load());
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }

        unawaited(context.read<PetAppearanceController>().load());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ownedController = _ownedController;
    final view = PetView(windowController: widget.windowController);

    if (ownedController == null) {
      return view;
    }

    return ChangeNotifierProvider<PetAppearanceController>.value(
      value: ownedController,
      child: view,
    );
  }

  @override
  void dispose() {
    _ownedController?.dispose();
    super.dispose();
  }
}
