import 'dart:io';

import 'package:desktop_pet/pet/pet_package.dart';
import 'package:desktop_pet/pet/pet_package_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loads the bundled default pet package', () async {
    final repository = PetPackageRepository(localPetsDirectory: '');

    final pet = await repository.loadBundledPet();

    expect(pet.source, PetPackageSource.bundled);
    expect(pet.id, 'mq');
    expect(pet.displayName, 'MQ');
    expect(pet.resolvedSpritesheetPath, 'assets/pets/default/spritesheet.webp');
  });

  test('discovers valid local pets and ignores invalid packages', () async {
    final tempDirectory = await Directory.systemTemp.createTemp(
      'desktop_pet_test_',
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
    await File('${validPetDirectory.path}/spritesheet.webp').writeAsBytes([0]);

    final missingSpritesheetDirectory = Directory(
      '${tempDirectory.path}/missing_spritesheet',
    );
    await missingSpritesheetDirectory.create();
    await File('${missingSpritesheetDirectory.path}/pet.json').writeAsString('''
{
  "id": "missing",
  "displayName": "Missing",
  "description": "This package is incomplete.",
  "spritesheetPath": "spritesheet.webp"
}
''');

    final repository = PetPackageRepository(
      localPetsDirectory: tempDirectory.path,
    );

    final pets = await repository.discoverLocalPets();

    expect(pets, hasLength(1));
    expect(pets.single.source, PetPackageSource.local);
    expect(pets.single.id, 'valid');
    expect(
      pets.single.resolvedSpritesheetPath,
      '${validPetDirectory.path}/spritesheet.webp',
    );
  });

  test(
    'falls back to bundled pet when saved selection is unavailable',
    () async {
      final repository = PetPackageRepository(localPetsDirectory: '');
      final pets = await repository.loadAvailablePets();

      final selected = repository.resolveSelection(
        pets,
        const PetPackageSelection(
          source: PetPackageSource.local,
          id: 'missing',
        ),
      );

      expect(selected.source, PetPackageSource.bundled);
      expect(selected.id, 'mq');
    },
  );
}
