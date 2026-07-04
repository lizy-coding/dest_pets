import 'package:flutter/widgets.dart';

class PetConfig {
  const PetConfig({
    this.petId = defaultPetId,
    this.scale = defaultScale,
    this.windowPosition,
    this.alwaysOnTop = defaultAlwaysOnTop,
  });

  static const String defaultPetId = 'default_pet';
  static const double defaultScale = 1.0;
  static const bool defaultAlwaysOnTop = true;

  final String petId;
  final double scale;
  final Offset? windowPosition;
  final bool alwaysOnTop;

  PetConfig copyWith({
    String? petId,
    double? scale,
    Object? windowPosition = _unset,
    bool? alwaysOnTop,
  }) {
    return PetConfig(
      petId: petId ?? this.petId,
      scale: scale ?? this.scale,
      windowPosition: identical(windowPosition, _unset)
          ? this.windowPosition
          : windowPosition as Offset?,
      alwaysOnTop: alwaysOnTop ?? this.alwaysOnTop,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is PetConfig &&
        other.petId == petId &&
        other.scale == scale &&
        other.windowPosition == windowPosition &&
        other.alwaysOnTop == alwaysOnTop;
  }

  @override
  int get hashCode {
    return Object.hash(petId, scale, windowPosition, alwaysOnTop);
  }
}

const Object _unset = Object();
