enum PetMenuActionType {
  switchPet,
  increaseScale,
  decreaseScale,
  resetScale,
  toggleAlwaysOnTop,
  openSettings,
  refreshResources,
  resetConfig,
  recoverFromError,
  quit,
}

class PetMenuAction {
  const PetMenuAction(this.type, {this.petId, this.enabled = true});

  final PetMenuActionType type;
  final String? petId;
  final bool enabled;

  factory PetMenuAction.fromJson(Map<String, dynamic> json) {
    return PetMenuAction(
      _petMenuActionTypeFromJson(json['type']),
      petId: json['petId'] as String?,
      enabled: json['enabled'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      if (petId != null) 'petId': petId,
      'enabled': enabled,
    };
  }
}

PetMenuActionType _petMenuActionTypeFromJson(Object? value) {
  if (value is! String) {
    throw const FormatException('Pet menu action type must be a string.');
  }

  for (final type in PetMenuActionType.values) {
    if (type.name == value) {
      return type;
    }
  }

  throw FormatException('Unknown pet menu action type "$value".');
}
