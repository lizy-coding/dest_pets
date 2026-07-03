enum PetPackageSource { bundled, local }

class PetPackageSelection {
  const PetPackageSelection({required this.source, required this.id});

  final PetPackageSource source;
  final String id;

  @override
  bool operator ==(Object other) {
    return other is PetPackageSelection &&
        other.source == source &&
        other.id == id;
  }

  @override
  int get hashCode => Object.hash(source, id);
}

class PetPackage {
  const PetPackage({
    required this.source,
    required this.basePath,
    required this.id,
    required this.displayName,
    required this.description,
    required this.spritesheetPath,
  });

  final PetPackageSource source;
  final String basePath;
  final String id;
  final String displayName;
  final String description;
  final String spritesheetPath;

  PetPackageSelection get selection {
    return PetPackageSelection(source: source, id: id);
  }

  String get resolvedSpritesheetPath {
    final separator = basePath.endsWith('/') ? '' : '/';
    return '$basePath$separator$spritesheetPath';
  }

  String get menuLabel {
    if (source == PetPackageSource.bundled) {
      return '$displayName (Default)';
    }

    return displayName;
  }

  static PetPackage? fromJson(
    Map<String, Object?> json, {
    required PetPackageSource source,
    required String basePath,
  }) {
    final id = json['id'];
    final displayName = json['displayName'];
    final description = json['description'];
    final spritesheetPath = json['spritesheetPath'];

    if (id is! String ||
        displayName is! String ||
        description is! String ||
        spritesheetPath is! String) {
      return null;
    }

    final normalizedId = id.trim();
    final normalizedDisplayName = displayName.trim();
    final normalizedDescription = description.trim();
    final normalizedSpritesheetPath = spritesheetPath.trim();

    if (normalizedId.isEmpty ||
        normalizedDisplayName.isEmpty ||
        normalizedDescription.isEmpty ||
        !_isSafeRelativePath(normalizedSpritesheetPath)) {
      return null;
    }

    return PetPackage(
      source: source,
      basePath: basePath,
      id: normalizedId,
      displayName: normalizedDisplayName,
      description: normalizedDescription,
      spritesheetPath: normalizedSpritesheetPath,
    );
  }

  static PetPackageSource? sourceFromName(String name) {
    for (final source in PetPackageSource.values) {
      if (source.name == name) {
        return source;
      }
    }

    return null;
  }

  static bool _isSafeRelativePath(String path) {
    if (path.isEmpty || path.startsWith('/') || path.contains(r'\')) {
      return false;
    }

    return !path
        .split('/')
        .any((segment) => segment.isEmpty || segment == '.' || segment == '..');
  }
}
