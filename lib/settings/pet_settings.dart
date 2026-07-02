import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PetSettings {
  static const String _windowXKey = 'desktop_pet.window.x';
  static const String _windowYKey = 'desktop_pet.window.y';

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
}
