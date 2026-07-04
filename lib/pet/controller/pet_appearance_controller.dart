import 'package:flutter/foundation.dart';

import '../data/pet_resource_repository.dart';
import '../data/pet_settings_store.dart';
import '../model/pet_appearance_settings.dart';
import '../model/pet_appearance_state.dart';

class PetAppearanceController extends ChangeNotifier {
  PetAppearanceController({
    required PetResourceRepository resourceRepository,
    required PetSettingsStore settingsStore,
  }) : _resourceRepository = resourceRepository,
       _settingsStore = settingsStore,
       _state = PetAppearanceState();

  final PetResourceRepository _resourceRepository;
  final PetSettingsStore _settingsStore;

  PetAppearanceState _state;

  PetAppearanceState get state {
    return _state;
  }

  Future<void> load() async {
    _setState(_state.copyWith(isLoading: true, errorMessage: null));

    try {
      final resources = await _resourceRepository.loadAvailableResources();
      final settings = await _settingsStore.loadAppearanceSettings();
      final selectedResource = _resourceRepository.resolveResource(
        resources,
        settings?.resourceId,
      );
      final scale = _normalizeScale(settings?.scale);

      _setState(
        PetAppearanceState(
          currentResourceId: selectedResource.resourceId,
          selectedResource: selectedResource,
          availableResources: resources,
          scale: scale,
        ),
      );
    } catch (error) {
      _setState(
        _state.copyWith(
          isLoading: false,
          selectedResource: null,
          currentResourceId: null,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> apply({String? resourceId, double? scale}) async {
    if (_state.availableResources.isEmpty) {
      await load();
    }

    final selectedResource = _resourceRepository.resolveResource(
      _state.availableResources,
      resourceId ?? _state.currentResourceId,
    );
    final nextScale = _normalizeScale(scale ?? _state.scale);

    _setState(
      _state.copyWith(
        currentResourceId: selectedResource.resourceId,
        selectedResource: selectedResource,
        scale: nextScale,
        isLoading: false,
        errorMessage: null,
      ),
    );

    await _settingsStore.saveAppearanceSettings(
      PetAppearanceSettings(
        resourceId: selectedResource.resourceId,
        scale: nextScale,
      ),
    );
  }

  Future<void> reset() async {
    final resources = _state.availableResources.isEmpty
        ? await _resourceRepository.loadAvailableResources()
        : _state.availableResources;
    final selectedResource = _resourceRepository.resolveResource(
      resources,
      null,
    );

    _setState(
      PetAppearanceState(
        currentResourceId: selectedResource.resourceId,
        selectedResource: selectedResource,
        availableResources: resources,
      ),
    );

    await _settingsStore.resetAppearanceSettings();
  }

  Future<void> refreshResources() async {
    _setState(_state.copyWith(isLoading: true, errorMessage: null));

    try {
      final resources = await _resourceRepository.loadAvailableResources();
      final selectedResource = _resourceRepository.resolveResource(
        resources,
        _state.currentResourceId,
      );

      _setState(
        _state.copyWith(
          currentResourceId: selectedResource.resourceId,
          selectedResource: selectedResource,
          availableResources: resources,
          isLoading: false,
        ),
      );
    } catch (error) {
      _setState(
        _state.copyWith(isLoading: false, errorMessage: error.toString()),
      );
    }
  }

  double _normalizeScale(double? scale) {
    if (scale == null || !scale.isFinite || scale <= 0) {
      return PetAppearanceState.defaultScale;
    }

    return scale;
  }

  void _setState(PetAppearanceState state) {
    _state = state;
    notifyListeners();
  }
}
