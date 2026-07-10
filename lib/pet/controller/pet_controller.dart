import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../resources/data/pet_resource_repository.dart';
import '../../resources/model/pet_resource.dart';
import '../../resources/model/pet_resource_discovery_result.dart';
import '../../settings/settings_store.dart';
import '../model/pet_animation_state.dart';
import '../model/pet_config.dart';
import '../model/pet_runtime_mode.dart';
import '../model/pet_state.dart';

class PetController extends ChangeNotifier {
  PetController({
    required PetResourceRepository resourceRepository,
    required SettingsStore settingsStore,
  }) : _resourceRepository = resourceRepository,
       _settingsStore = settingsStore;

  static const double minScale = 0.5;
  static const double maxScale = 2.0;
  static const double scaleStep = 0.1;

  final PetResourceRepository _resourceRepository;
  final SettingsStore _settingsStore;

  PetState _state = PetState();

  PetState get state {
    return _state;
  }

  Future<void> initialize() async {
    _setState(
      _state.copyWith(
        runtimeMode: PetRuntimeMode.initializing,
        errorMessage: null,
      ),
    );

    try {
      final loadedConfig = await _settingsStore.loadConfig();
      final config = _normalizeConfig(loadedConfig ?? const PetConfig());
      final resolved = await _loadResourcesForConfig(config);

      _setState(
        PetState(
          config: resolved.config,
          resource: resolved.resource,
          availableResources: resolved.resources,
          ignoredResourceReports: resolved.ignoredResourceReports,
          runtimeMode: PetRuntimeMode.idle,
          animationState: const PetAnimationState(),
        ),
      );
    } catch (error) {
      _setState(
        _state.copyWith(
          runtimeMode: PetRuntimeMode.error,
          resource: null,
          animationState: const PetAnimationState(
            animationId: PetAnimationState.errorAnimationId,
          ),
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> refreshResources() async {
    _setState(
      _state.copyWith(
        runtimeMode: PetRuntimeMode.switchingResource,
        errorMessage: null,
      ),
    );

    try {
      final previousConfig = _state.config;
      final resolved = await _loadResourcesForConfig(previousConfig);
      _setState(
        _state.copyWith(
          config: resolved.config,
          resource: resolved.resource,
          availableResources: resolved.resources,
          ignoredResourceReports: resolved.ignoredResourceReports,
          runtimeMode: PetRuntimeMode.idle,
          errorMessage: null,
        ),
      );

      if (resolved.config != previousConfig) {
        await _settingsStore.saveConfig(resolved.config);
      }
    } catch (error) {
      _setState(
        _state.copyWith(
          runtimeMode: PetRuntimeMode.error,
          animationState: const PetAnimationState(
            animationId: PetAnimationState.errorAnimationId,
          ),
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> switchPet(String petId) async {
    _setState(
      _state.copyWith(
        runtimeMode: PetRuntimeMode.switchingResource,
        errorMessage: null,
      ),
    );

    try {
      final resolvedResources = _state.availableResources.isEmpty
          ? await _resourceRepository.loadAvailableResourcesWithReports()
          : PetResourceDiscoveryResult(
              validResources: _state.availableResources,
              ignoredResources: _state.ignoredResourceReports,
            );
      final resources = resolvedResources.validResources;
      final resource = _findResource(resources, petId);
      final config = _state.config.copyWith(petId: resource.id);

      _setState(
        _state.copyWith(
          config: config,
          resource: resource,
          availableResources: resources,
          ignoredResourceReports: resolvedResources.ignoredResources,
          runtimeMode: PetRuntimeMode.idle,
          animationState: const PetAnimationState(),
          errorMessage: null,
        ),
      );
      await _settingsStore.saveConfig(config);
    } catch (error) {
      _setState(
        _state.copyWith(
          runtimeMode: PetRuntimeMode.error,
          animationState: const PetAnimationState(
            animationId: PetAnimationState.errorAnimationId,
          ),
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> setScale(double scale) async {
    final config = _state.config.copyWith(scale: _clampScale(scale));
    _setState(_state.copyWith(config: config));
    await _settingsStore.saveConfig(config);
  }

  Future<void> increaseScale() async {
    await setScale(_state.config.scale + scaleStep);
  }

  Future<void> decreaseScale() async {
    await setScale(_state.config.scale - scaleStep);
  }

  Future<void> resetScale() async {
    await setScale(PetConfig.defaultScale);
  }

  Future<void> moveTo(Offset position) async {
    final config = _state.config.copyWith(windowPosition: position);
    _setState(_state.copyWith(config: config));
    await _settingsStore.saveConfig(config);
  }

  Future<void> setAlwaysOnTop(bool value) async {
    final config = _state.config.copyWith(alwaysOnTop: value);
    _setState(_state.copyWith(config: config));
    await _settingsStore.saveConfig(config);
  }

  Future<void> resetConfig() async {
    _setState(
      _state.copyWith(
        runtimeMode: PetRuntimeMode.initializing,
        errorMessage: null,
      ),
    );

    try {
      await _settingsStore.resetConfig();
      final resolved = await _loadResourcesForConfig(const PetConfig());
      _setState(
        _state.copyWith(
          config: resolved.config,
          resource: resolved.resource,
          availableResources: resolved.resources,
          ignoredResourceReports: resolved.ignoredResourceReports,
          runtimeMode: PetRuntimeMode.idle,
          animationState: const PetAnimationState(),
          errorMessage: null,
        ),
      );
    } catch (error) {
      _setState(
        _state.copyWith(
          runtimeMode: PetRuntimeMode.error,
          animationState: const PetAnimationState(
            animationId: PetAnimationState.errorAnimationId,
          ),
          errorMessage: error.toString(),
        ),
      );
    }
  }

  void startDragging() {
    if (_state.runtimeMode != PetRuntimeMode.idle) {
      return;
    }

    _setState(
      _state.copyWith(
        runtimeMode: PetRuntimeMode.dragging,
        animationState: const PetAnimationState(
          animationId: PetAnimationState.draggingAnimationId,
        ),
      ),
    );
  }

  Future<void> endDragging(Offset position) async {
    final config = _state.config.copyWith(windowPosition: position);
    _setState(
      _state.copyWith(
        config: config,
        runtimeMode: PetRuntimeMode.idle,
        animationState: const PetAnimationState(),
      ),
    );
    await _settingsStore.saveConfig(config);
  }

  Future<void> recoverFromError() async {
    await initialize();
  }

  Future<_ResolvedPetResources> _loadResourcesForConfig(
    PetConfig config,
  ) async {
    final discoveryResult = await _resourceRepository
        .loadAvailableResourcesWithReports();
    final resources = discoveryResult.validResources;
    final resource = _resourceRepository.resolveResource(
      resources,
      config.petId,
    );
    final resolvedConfig = config.copyWith(petId: resource.id);

    return _ResolvedPetResources(
      config: resolvedConfig,
      resource: resource,
      resources: resources,
      ignoredResourceReports: discoveryResult.ignoredResources,
    );
  }

  PetConfig _normalizeConfig(PetConfig config) {
    return config.copyWith(scale: _clampScale(config.scale));
  }

  PetResource _findResource(List<PetResource> resources, String petId) {
    final normalizedPetId = petId.trim();
    for (final resource in resources) {
      if (resource.id == normalizedPetId) {
        return resource;
      }
    }

    throw StateError('Pet resource "$petId" is unavailable.');
  }

  double _clampScale(double scale) {
    if (!scale.isFinite) {
      return PetConfig.defaultScale;
    }

    return clampDouble(scale, minScale, maxScale);
  }

  void _setState(PetState state) {
    _state = state;
    notifyListeners();
  }
}

class _ResolvedPetResources {
  const _ResolvedPetResources({
    required this.config,
    required this.resource,
    required this.resources,
    required this.ignoredResourceReports,
  });

  final PetConfig config;
  final PetResource resource;
  final List<PetResource> resources;
  final List<PetResourceValidationReport> ignoredResourceReports;
}
