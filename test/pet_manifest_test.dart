import 'package:desktop_pet/pet/model/pet_config.dart';
import 'package:desktop_pet/resources/model/pet_manifest.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses the normalized pet manifest', () {
    final manifest = PetManifest.fromJson(_manifestJson());

    expect(manifest, isNotNull);
    expect(manifest!.id, 'default_pet');
    expect(manifest.name, 'Default Pet');
    expect(manifest.defaultScale, 1.0);
    expect(manifest.atlas.image, 'spritesheet.webp');
    expect(manifest.animations['idle']!.frames, [0, 1, 2, 3, 4, 5]);
  });

  test('rejects an unsafe atlas image path', () {
    final json = _manifestJson();
    json['atlas'] = {
      ...json['atlas']! as Map<String, Object?>,
      'image': '../spritesheet.webp',
    };

    expect(PetManifest.fromJson(json), isNull);
  });

  test('rejects a manifest without atlas data', () {
    final json = _manifestJson()..remove('atlas');

    expect(PetManifest.fromJson(json), isNull);
  });

  test('rejects a manifest without idle animation', () {
    final json = _manifestJson();
    json['animations'] = <String, Object?>{};

    expect(PetManifest.fromJson(json), isNull);
  });

  test('PetConfig exposes the current default values', () {
    const config = PetConfig();

    expect(config.petId, 'default_pet');
    expect(config.scale, 1.0);
    expect(config.windowPosition, isNull);
    expect(config.alwaysOnTop, isTrue);
  });
}

Map<String, Object?> _manifestJson({String id = 'default_pet'}) {
  return {
    'id': id,
    'name': 'Default Pet',
    'description': 'Default desktop pet.',
    'defaultScale': 1.0,
    'atlas': {
      'image': 'spritesheet.webp',
      'columns': 8,
      'rows': 9,
      'frameWidth': 192,
      'frameHeight': 208,
    },
    'animations': {
      'idle': {
        'row': 0,
        'frames': [0, 1, 2, 3, 4, 5],
        'durationsMs': [280, 110, 110, 140, 140, 320],
        'loop': true,
      },
    },
  };
}
