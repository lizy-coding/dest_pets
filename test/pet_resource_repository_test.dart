import 'dart:io';

import 'package:desktop_pet/pet/data/pet_resource_repository.dart';
import 'package:desktop_pet/pet/model/pet_resource.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loads the bundled default pet resource', () async {
    final repository = PetResourceRepository(localPetsDirectory: '');

    final resource = await repository.loadBundledResource();

    expect(resource.source, PetResourceSource.bundled);
    expect(resource.id, 'mq');
    expect(resource.resourceId, 'bundled:mq');
    expect(resource.displayName, 'MQ');
    expect(
      resource.resolvedSpritesheetPath,
      'assets/pets/default/spritesheet.webp',
    );
  });

  test(
    'discovers valid local resources and ignores invalid packages',
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
      await File('${validPetDirectory.path}/pet.json').writeAsString('''
{
  "id": "valid",
  "displayName": "Valid Pet",
  "description": "A valid local pet.",
  "spritesheetPath": "spritesheet.webp"
}
''');
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
      await File('${missingSpritesheetDirectory.path}/pet.json').writeAsString(
        '''
{
  "id": "missing",
  "displayName": "Missing",
  "description": "This package is incomplete.",
  "spritesheetPath": "spritesheet.webp"
}
''',
      );

      final unsafePathDirectory = Directory(
        '${tempDirectory.path}/unsafe_path',
      );
      await unsafePathDirectory.create();
      await File('${unsafePathDirectory.path}/pet.json').writeAsString('''
{
  "id": "unsafe",
  "displayName": "Unsafe",
  "description": "This package has an unsafe path.",
  "spritesheetPath": "../spritesheet.webp"
}
''');

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

  test(
    'falls back to bundled resource when saved resource is unavailable',
    () async {
      final repository = PetResourceRepository(localPetsDirectory: '');
      final resources = await repository.loadAvailableResources();

      final selected = repository.resolveResource(resources, 'local:missing');

      expect(selected.source, PetResourceSource.bundled);
      expect(selected.id, 'mq');
    },
  );
}
