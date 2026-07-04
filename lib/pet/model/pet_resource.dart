enum PetResourceSource { bundled, local }

class PetResourceSelection {
  const PetResourceSelection({required this.source, required this.id});

  final PetResourceSource source;
  final String id;

  String get resourceId {
    return PetResource.resourceIdFor(source: source, id: id);
  }

  @override
  bool operator ==(Object other) {
    return other is PetResourceSelection &&
        other.source == source &&
        other.id == id;
  }

  @override
  int get hashCode => Object.hash(source, id);
}

class PetResource {
  const PetResource({
    required this.source,
    required this.basePath,
    required this.id,
    required this.displayName,
    required this.description,
    required this.spritesheetPath,
  });

  final PetResourceSource source;
  final String basePath;
  final String id;
  final String displayName;
  final String description;
  final String spritesheetPath;

  String get resourceId {
    return resourceIdFor(source: source, id: id);
  }

  PetResourceSelection get selection {
    return PetResourceSelection(source: source, id: id);
  }

  String get resolvedSpritesheetPath {
    final separator = basePath.endsWith('/') ? '' : '/';
    return '$basePath$separator$spritesheetPath';
  }

  String get menuLabel {
    if (source == PetResourceSource.bundled) {
      return '$displayName (Default)';
    }

    return displayName;
  }

  static PetResource? fromJson(
    Map<String, Object?> json, {
    required PetResourceSource source,
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

    return PetResource(
      source: source,
      basePath: basePath,
      id: normalizedId,
      displayName: normalizedDisplayName,
      description: normalizedDescription,
      spritesheetPath: normalizedSpritesheetPath,
    );
  }

  static PetResourceSource? sourceFromName(String name) {
    for (final source in PetResourceSource.values) {
      if (source.name == name) {
        return source;
      }
    }

    return null;
  }

  static String resourceIdFor({
    required PetResourceSource source,
    required String id,
  }) {
    return '${source.name}:$id';
  }

  static ({PetResourceSource source, String id})? parseResourceId(
    String resourceId,
  ) {
    final separatorIndex = resourceId.indexOf(':');
    if (separatorIndex <= 0 || separatorIndex == resourceId.length - 1) {
      return null;
    }

    final sourceName = resourceId.substring(0, separatorIndex);
    final source = sourceFromName(sourceName);
    if (source == null) {
      return null;
    }

    final id = resourceId.substring(separatorIndex + 1);
    if (id.isEmpty) {
      return null;
    }

    return (source: source, id: id);
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
