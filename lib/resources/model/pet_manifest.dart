import 'pet_animation_manifest.dart';

class PetAtlasManifest {
  const PetAtlasManifest({
    required this.image,
    required this.columns,
    required this.rows,
    required this.frameWidth,
    required this.frameHeight,
  });

  final String image;
  final int columns;
  final int rows;
  final int frameWidth;
  final int frameHeight;

  static PetAtlasManifest? fromJson(Map<String, Object?> json) {
    final image = json['image'];
    final columns = json['columns'];
    final rows = json['rows'];
    final frameWidth = json['frameWidth'];
    final frameHeight = json['frameHeight'];

    if (image is! String ||
        columns is! int ||
        rows is! int ||
        frameWidth is! int ||
        frameHeight is! int) {
      return null;
    }

    final normalizedImage = image.trim();
    if (!_isSafeRelativePath(normalizedImage) ||
        columns <= 0 ||
        rows <= 0 ||
        frameWidth <= 0 ||
        frameHeight <= 0) {
      return null;
    }

    return PetAtlasManifest(
      image: normalizedImage,
      columns: columns,
      rows: rows,
      frameWidth: frameWidth,
      frameHeight: frameHeight,
    );
  }
}

class PetManifest {
  const PetManifest({
    required this.id,
    required this.name,
    required this.description,
    required this.defaultScale,
    required this.atlas,
    required this.animations,
  });

  final String id;
  final String name;
  final String description;
  final double defaultScale;
  final PetAtlasManifest atlas;
  final Map<String, PetAnimationManifest> animations;

  static PetManifest? fromJson(Map<String, Object?> json) {
    final id = json['id'];
    final name = json['name'];
    final description = json['description'];
    final defaultScale = json['defaultScale'];
    final atlasJson = json['atlas'];
    final animationsJson = json['animations'];

    if (id is! String ||
        name is! String ||
        description is! String ||
        defaultScale is! num ||
        atlasJson is! Map ||
        animationsJson is! Map) {
      return null;
    }

    final normalizedId = id.trim();
    final normalizedName = name.trim();
    final normalizedDescription = description.trim();
    final normalizedScale = defaultScale.toDouble();
    final atlas = PetAtlasManifest.fromJson(
      Map<String, Object?>.from(atlasJson),
    );

    if (normalizedId.isEmpty ||
        normalizedName.isEmpty ||
        normalizedDescription.isEmpty ||
        !normalizedScale.isFinite ||
        normalizedScale <= 0 ||
        atlas == null) {
      return null;
    }

    final animations = <String, PetAnimationManifest>{};
    for (final entry in animationsJson.entries) {
      final animationId = entry.key;
      final animationJson = entry.value;
      if (animationId is! String || animationJson is! Map) {
        return null;
      }

      final animation = PetAnimationManifest.fromJson(
        Map<String, Object?>.from(animationJson),
        atlasRows: atlas.rows,
        atlasColumns: atlas.columns,
      );
      if (animation == null) {
        return null;
      }

      animations[animationId] = animation;
    }

    if (!animations.containsKey('idle')) {
      return null;
    }

    return PetManifest(
      id: normalizedId,
      name: normalizedName,
      description: normalizedDescription,
      defaultScale: normalizedScale,
      atlas: atlas,
      animations: Map.unmodifiable(animations),
    );
  }
}

bool _isSafeRelativePath(String path) {
  if (path.isEmpty || path.startsWith('/') || path.contains(r'\')) {
    return false;
  }

  return !path
      .split('/')
      .any((segment) => segment.isEmpty || segment == '.' || segment == '..');
}
