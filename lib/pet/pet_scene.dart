import 'package:flutter/material.dart';

import '../desktop/desktop_window_controller.dart';
import '../settings/pet_settings.dart';
import 'pet_actor.dart';
import 'pet_hit_area.dart';
import 'pet_package.dart';
import 'pet_package_repository.dart';

class PetScene extends StatefulWidget {
  const PetScene({
    required this.windowController,
    required this.settings,
    this.petPackageRepository,
    super.key,
  });

  final DesktopWindowController windowController;
  final PetSettings settings;
  final PetPackageRepository? petPackageRepository;

  @override
  State<PetScene> createState() => _PetSceneState();
}

class _PetSceneState extends State<PetScene> {
  late final PetPackageRepository _petPackageRepository;
  List<PetPackage> _pets = const [];
  PetPackage? _selectedPet;

  @override
  void initState() {
    super.initState();
    _petPackageRepository =
        widget.petPackageRepository ?? PetPackageRepository();
    _loadPets();
  }

  @override
  Widget build(BuildContext context) {
    final selectedPet = _selectedPet;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: RepaintBoundary(
          child: SizedBox.square(
            dimension: 200,
            child: PetHitArea(
              windowController: widget.windowController,
              onSecondaryTapDown: _showPetMenu,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: selectedPet == null
                    ? const SizedBox.shrink()
                    : PetActor(pet: selectedPet),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _loadPets() async {
    final pets = await _petPackageRepository.loadAvailablePets();
    final selection = await widget.settings.loadPetSelection();
    final selectedPet = _petPackageRepository.resolveSelection(pets, selection);

    if (!mounted) {
      return;
    }

    setState(() {
      _pets = pets;
      _selectedPet = selectedPet;
    });
  }

  Future<void> _showPetMenu(TapDownDetails details) async {
    if (_pets.isEmpty) {
      return;
    }

    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final selectedSelection = _selectedPet?.selection;
    final selected = await showMenu<PetPackageSelection>(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromPoints(details.globalPosition, details.globalPosition),
        Offset.zero & overlay.size,
      ),
      items: [
        for (final pet in _pets)
          CheckedPopupMenuItem<PetPackageSelection>(
            value: pet.selection,
            checked: pet.selection == selectedSelection,
            child: Text(pet.menuLabel),
          ),
      ],
    );

    if (!mounted || selected == null) {
      return;
    }

    await _selectPet(selected);
  }

  Future<void> _selectPet(PetPackageSelection selection) async {
    for (final pet in _pets) {
      if (pet.selection == selection) {
        setState(() {
          _selectedPet = pet;
        });
        await widget.settings.savePetSelection(selection);
        return;
      }
    }
  }
}
