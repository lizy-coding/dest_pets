import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../pet/pet_package.dart';

class PetSettings {
  static const String _windowXKey = 'desktop_pet.window.x';
  static const String _windowYKey = 'desktop_pet.window.y';
  static const String _petSourceKey = 'desktop_pet.pet.source';
  static const String _petIdKey = 'desktop_pet.pet.id';

  Future<Offset?> loadWindowPosition() async {
    final preferences = await SharedPreferences.getInstance();
    final x = preferences.getDouble(_windowXKey);
    final y = preferences.getDouble(_windowYKey);

    if (x == null || y == null) {
      return null;
    }

    return Offset(x, y);
  }

  Future<void> saveWindowPosition(Offset position) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setDouble(_windowXKey, position.dx);
    await preferences.setDouble(_windowYKey, position.dy);
  }

  Future<PetPackageSelection?> loadPetSelection() async {
    final preferences = await SharedPreferences.getInstance();
    final sourceName = preferences.getString(_petSourceKey);
    final id = preferences.getString(_petIdKey);

    if (sourceName == null || id == null) {
      return null;
    }

    final source = PetPackage.sourceFromName(sourceName);
    if (source == null || id.isEmpty) {
      return null;
    }

    return PetPackageSelection(source: source, id: id);
  }

  Future<void> savePetSelection(PetPackageSelection selection) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_petSourceKey, selection.source.name);
    await preferences.setString(_petIdKey, selection.id);
  }
}
