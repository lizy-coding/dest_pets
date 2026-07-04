import 'pet_manifest.dart';

enum PetResourceSource { bundled, local }

class PetResource {
  const PetResource({
    required this.source,
    required this.basePath,
    required this.manifest,
  });

  final PetResourceSource source;
  final String basePath;
  final PetManifest manifest;

  String get id {
    return manifest.id;
  }

  String get name {
    return manifest.name;
  }

  String get description {
    return manifest.description;
  }

  String get resourceId {
    return id;
  }

  String get resolvedSpritesheetPath {
    final separator = basePath.endsWith('/') ? '' : '/';
    return '$basePath$separator${manifest.atlas.image}';
  }

  String get menuLabel {
    if (source == PetResourceSource.bundled) {
      return '$name (Default)';
    }

    return name;
  }
}
