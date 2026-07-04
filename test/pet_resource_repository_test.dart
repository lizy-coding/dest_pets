import 'dart:io';

import 'package:desktop_pet/resources/data/pet_resource_repository.dart';
import 'package:desktop_pet/resources/model/pet_resource.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loads the bundled default pet resource', () async {
    final repository = PetResourceRepository(localPetsDirectory: '');

    final resource = await repository.loadBundledResource();

    expect(resource.source, PetResourceSource.bundled);
    expect(resource.id, 'default_pet');
    expect(resource.resourceId, 'default_pet');
    expect(resource.name, 'Default Pet');
    expect(
      resource.resolvedSpritesheetPath,
      'assets/pets/default_pet/spritesheet.webp',
    );
  });

  test(
    'discovers valid local resources and ignores invalid resources',
    () async {
      final tempDirectory = await Directory.systemTemp.createTemp(
        'desktop_pet_resource_test_',
      );
      addTearDown(() async {
        if (await tempDirectory.exists()) {
          await tempDirectory.delete(recursive: true);
        }
      });

      final validPetDirectory = Directory('${tempDirectory.path}/valid');
      await validPetDirectory.create();
      await File(
        '${validPetDirectory.path}/pet.json',
      ).writeAsString(_manifestJson(id: 'valid', name: 'Valid Pet'));
      await File(
        '${validPetDirectory.path}/spritesheet.webp',
      ).writeAsBytes([0]);

      final missingManifestDirectory = Directory(
        '${tempDirectory.path}/missing_manifest',
      );
      await missingManifestDirectory.create();

      final missingSpritesheetDirectory = Directory(
        '${tempDirectory.path}/missing_spritesheet',
      );
      await missingSpritesheetDirectory.create();
      await File(
        '${missingSpritesheetDirectory.path}/pet.json',
      ).writeAsString(_manifestJson(id: 'missing', name: 'Missing'));

      final unsafePathDirectory = Directory(
        '${tempDirectory.path}/unsafe_path',
      );
      await unsafePathDirectory.create();
      await File('${unsafePathDirectory.path}/pet.json').writeAsString(
        _manifestJson(
          id: 'unsafe',
          name: 'Unsafe',
          image: '../spritesheet.webp',
        ),
      );

      final legacyDirectory = Directory('${tempDirectory.path}/legacy');
      await legacyDirectory.create();
      await File('${legacyDirectory.path}/pet.json').writeAsString('''
{
  "id": "legacy",
  "displayName": "Legacy",
  "description": "Old shape.",
  "spritesheetPath": "spritesheet.webp"
}
''');
      await File('${legacyDirectory.path}/spritesheet.webp').writeAsBytes([0]);

      final repository = PetResourceRepository(
        localPetsDirectory: tempDirectory.path,
      );

      final resources = await repository.discoverLocalResources();

      expect(resources, hasLength(1));
      expect(resources.single.source, PetResourceSource.local);
      expect(resources.single.id, 'valid');
      expect(
        resources.single.resolvedSpritesheetPath,
        '${validPetDirectory.path}/spritesheet.webp',
      );
    },
  );
}

String _manifestJson({
  required String id,
  required String name,
  String image = 'spritesheet.webp',
}) {
  return '''
{
  "id": "$id",
  "name": "$name",
  "description": "A test pet.",
  "defaultScale": 1.0,
  "atlas": {
    "image": "$image",
    "columns": 8,
    "rows": 9,
    "frameWidth": 192,
    "frameHeight": 208
  },
  "animations": {
    "idle": {
      "row": 0,
      "frames": [0, 1, 2, 3, 4, 5],
      "durationsMs": [280, 110, 110, 140, 140, 320],
      "loop": true
    }
  }
}
''';
}
