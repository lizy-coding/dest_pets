import 'package:shared_preferences/shared_preferences.dart';

import '../model/pet_appearance_settings.dart';
import '../model/pet_appearance_state.dart';
import '../model/pet_resource.dart';

class PetSettingsStore {
  static const String _resourceIdKey = 'desktop_pet.appearance.resourceId';
  static const String _scaleKey = 'desktop_pet.appearance.scale';
  static const String _legacyPetSourceKey = 'desktop_pet.pet.source';
  static const String _legacyPetIdKey = 'desktop_pet.pet.id';

  Future<PetAppearanceSettings?> loadAppearanceSettings() async {
    final preferences = await SharedPreferences.getInstance();
    final resourceId = _loadResourceId(preferences);
    final scale = _loadScale(preferences);

    if (resourceId == null && scale == null) {
      return null;
    }

    return PetAppearanceSettings(
      resourceId: resourceId,
      scale: scale ?? PetAppearanceState.defaultScale,
    );
  }

  Future<void> saveAppearanceSettings(PetAppearanceSettings settings) async {
    final preferences = await SharedPreferences.getInstance();
    final resourceId = settings.resourceId?.trim();

    if (resourceId == null || resourceId.isEmpty) {
      await preferences.remove(_resourceIdKey);
      await preferences.remove(_legacyPetSourceKey);
      await preferences.remove(_legacyPetIdKey);
    } else {
      await preferences.setString(_resourceIdKey, resourceId);
      await _saveLegacySelection(preferences, resourceId);
    }

    await preferences.setDouble(_scaleKey, settings.scale);
  }

  Future<void> resetAppearanceSettings() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_resourceIdKey);
    await preferences.remove(_scaleKey);
    await preferences.remove(_legacyPetSourceKey);
    await preferences.remove(_legacyPetIdKey);
  }

  String? _loadResourceId(SharedPreferences preferences) {
    final resourceId = preferences.getString(_resourceIdKey)?.trim();
    if (resourceId != null && resourceId.isNotEmpty) {
      return resourceId;
    }

    final legacySourceName = preferences.getString(_legacyPetSourceKey);
    final legacyId = preferences.getString(_legacyPetIdKey)?.trim();
    if (legacySourceName == null || legacyId == null || legacyId.isEmpty) {
      return null;
    }

    final legacySource = PetResource.sourceFromName(legacySourceName);
    if (legacySource == null) {
      return null;
    }

    return PetResource.resourceIdFor(source: legacySource, id: legacyId);
  }

  double? _loadScale(SharedPreferences preferences) {
    if (!preferences.containsKey(_scaleKey)) {
      return null;
    }

    final scale = preferences.getDouble(_scaleKey);
    if (scale == null || !scale.isFinite || scale <= 0) {
      return PetAppearanceState.defaultScale;
    }

    return scale;
  }

  Future<void> _saveLegacySelection(
    SharedPreferences preferences,
    String resourceId,
  ) async {
    final parsed = PetResource.parseResourceId(resourceId);
    if (parsed == null) {
      await preferences.remove(_legacyPetSourceKey);
      await preferences.remove(_legacyPetIdKey);
      return;
    }

    await preferences.setString(_legacyPetSourceKey, parsed.source.name);
    await preferences.setString(_legacyPetIdKey, parsed.id);
  }
}
