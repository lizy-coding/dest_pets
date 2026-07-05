import 'pet_resource_option.dart';
import 'pet_runtime_mode.dart';
import 'pet_state.dart';

class PetSettingsSnapshot {
  const PetSettingsSnapshot({
    required this.petId,
    required this.scale,
    required this.alwaysOnTop,
    required this.resourceOptions,
    required this.runtimeMode,
    this.errorMessage,
  });

  final String petId;
  final double scale;
  final bool alwaysOnTop;
  final List<PetResourceOption> resourceOptions;
  final PetRuntimeMode runtimeMode;
  final String? errorMessage;

  factory PetSettingsSnapshot.fromJson(Map<String, dynamic> json) {
    return PetSettingsSnapshot(
      petId: json['petId'] as String,
      scale: (json['scale'] as num).toDouble(),
      alwaysOnTop: json['alwaysOnTop'] as bool? ?? true,
      resourceOptions: [
        for (final item
            in json['resourceOptions'] as List<dynamic>? ?? const [])
          PetResourceOption.fromJson(item as Map<String, dynamic>),
      ],
      runtimeMode: _petRuntimeModeFromJson(json['runtimeMode']),
      errorMessage: json['errorMessage'] as String?,
    );
  }

  bool get hasError {
    return runtimeMode == PetRuntimeMode.error;
  }

  Map<String, dynamic> toJson() {
    return {
      'petId': petId,
      'scale': scale,
      'alwaysOnTop': alwaysOnTop,
      'resourceOptions': [
        for (final resource in resourceOptions) resource.toJson(),
      ],
      'runtimeMode': runtimeMode.name,
      if (errorMessage != null) 'errorMessage': errorMessage,
    };
  }

  static PetSettingsSnapshot fromState(PetState state) {
    return PetSettingsSnapshot(
      petId: state.config.petId,
      scale: state.config.scale,
      alwaysOnTop: state.config.alwaysOnTop,
      resourceOptions: [
        for (final resource in state.availableResources)
          PetResourceOption.fromResource(
            resource,
            selectedPetId: state.config.petId,
          ),
      ],
      runtimeMode: state.runtimeMode,
      errorMessage: state.errorMessage,
    );
  }
}

PetRuntimeMode _petRuntimeModeFromJson(Object? value) {
  if (value is! String) {
    throw const FormatException('Pet runtime mode must be a string.');
  }

  for (final mode in PetRuntimeMode.values) {
    if (mode.name == value) {
      return mode;
    }
  }

  throw FormatException('Unknown pet runtime mode "$value".');
}
