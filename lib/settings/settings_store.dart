import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../pet/model/pet_config.dart';

class SettingsStore {
  static const String _petIdKey = 'desktop_pet.config.petId';
  static const String _scaleKey = 'desktop_pet.config.scale';
  static const String _windowXKey = 'desktop_pet.config.window.x';
  static const String _windowYKey = 'desktop_pet.config.window.y';
  static const String _alwaysOnTopKey = 'desktop_pet.config.alwaysOnTop';

  Future<PetConfig?> loadConfig() async {
    final preferences = await SharedPreferences.getInstance();
    final hasPetId = preferences.containsKey(_petIdKey);
    final hasScale = preferences.containsKey(_scaleKey);
    final hasWindowX = preferences.containsKey(_windowXKey);
    final hasWindowY = preferences.containsKey(_windowYKey);
    final hasAlwaysOnTop = preferences.containsKey(_alwaysOnTopKey);

    if (!hasPetId &&
        !hasScale &&
        !hasWindowX &&
        !hasWindowY &&
        !hasAlwaysOnTop) {
      return null;
    }

    final petId = preferences.getString(_petIdKey)?.trim();
    final scale = preferences.getDouble(_scaleKey);
    final x = preferences.getDouble(_windowXKey);
    final y = preferences.getDouble(_windowYKey);
    final alwaysOnTop = preferences.getBool(_alwaysOnTopKey);

    return PetConfig(
      petId: petId == null || petId.isEmpty ? PetConfig.defaultPetId : petId,
      scale: scale == null || !scale.isFinite ? PetConfig.defaultScale : scale,
      windowPosition: x == null || y == null ? null : Offset(x, y),
      alwaysOnTop: alwaysOnTop ?? PetConfig.defaultAlwaysOnTop,
    );
  }

  Future<void> saveConfig(PetConfig config) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_petIdKey, config.petId);
    await preferences.setDouble(_scaleKey, config.scale);
    await preferences.setBool(_alwaysOnTopKey, config.alwaysOnTop);

    final position = config.windowPosition;
    if (position == null) {
      await preferences.remove(_windowXKey);
      await preferences.remove(_windowYKey);
    } else {
      await preferences.setDouble(_windowXKey, position.dx);
      await preferences.setDouble(_windowYKey, position.dy);
    }
  }

  Future<void> resetConfig() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_petIdKey);
    await preferences.remove(_scaleKey);
    await preferences.remove(_windowXKey);
    await preferences.remove(_windowYKey);
    await preferences.remove(_alwaysOnTopKey);
  }
}
