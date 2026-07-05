import '../../resources/model/pet_resource.dart';

class PetResourceOption {
  const PetResourceOption({
    required this.id,
    required this.label,
    required this.source,
    required this.selected,
  });

  final String id;
  final String label;
  final PetResourceSource source;
  final bool selected;

  factory PetResourceOption.fromJson(Map<String, dynamic> json) {
    return PetResourceOption(
      id: json['id'] as String,
      label: json['label'] as String,
      source: _petResourceSourceFromJson(json['source']),
      selected: json['selected'] as bool? ?? false,
    );
  }

  String get sourceLabel {
    return switch (source) {
      PetResourceSource.bundled => 'Bundled',
      PetResourceSource.local => 'Local',
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'source': source.name,
      'selected': selected,
    };
  }

  static PetResourceOption fromResource(
    PetResource resource, {
    required String selectedPetId,
  }) {
    return PetResourceOption(
      id: resource.id,
      label: resource.menuLabel,
      source: resource.source,
      selected: resource.id == selectedPetId,
    );
  }
}

PetResourceSource _petResourceSourceFromJson(Object? value) {
  if (value is! String) {
    throw const FormatException('Pet resource source must be a string.');
  }

  for (final source in PetResourceSource.values) {
    if (source.name == value) {
      return source;
    }
  }

  throw FormatException('Unknown pet resource source "$value".');
}
