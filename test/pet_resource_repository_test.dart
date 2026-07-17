import 'dart:io';

import 'package:desktop_pet/resources/data/local_pets_directory_resolver.dart';
import 'package:desktop_pet/resources/data/pet_resource_repository.dart';
import 'package:desktop_pet/resources/model/pet_resource.dart';
import 'package:desktop_pet/resources/model/pet_resource_discovery_result.dart';
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
    'discovers valid local resources and reports invalid resources',
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

      final missingAtlasDirectory = Directory(
        '${tempDirectory.path}/missing_atlas',
      );
      await missingAtlasDirectory.create();
      await File('${missingAtlasDirectory.path}/pet.json').writeAsString('''
{
  "id": "missing_atlas",
  "name": "Missing Atlas",
  "description": "No atlas.",
  "defaultScale": 1.0,
  "animations": {
    "idle": {
      "row": 0,
      "frames": [0],
      "durationsMs": [100],
      "loop": true
    }
  }
}
''');

      final missingIdleDirectory = Directory(
        '${tempDirectory.path}/missing_idle',
      );
      await missingIdleDirectory.create();
      await File('${missingIdleDirectory.path}/pet.json').writeAsString('''
{
  "id": "missing_idle",
  "name": "Missing Idle",
  "description": "No idle animation.",
  "defaultScale": 1.0,
  "atlas": {
    "image": "spritesheet.webp",
    "columns": 8,
    "rows": 9,
    "frameWidth": 192,
    "frameHeight": 208
  },
  "animations": {}
}
''');
      await File(
        '${missingIdleDirectory.path}/spritesheet.webp',
      ).writeAsBytes([0]);

      final repository = PetResourceRepository(
        localPetsDirectory: tempDirectory.path,
      );

      final result = await repository.discoverLocalResourcesWithReports();

      expect(result.validResources, hasLength(1));
      expect(result.validResources.single.source, PetResourceSource.local);
      expect(result.validResources.single.id, 'valid');
      expect(
        result.validResources.single.resolvedSpritesheetPath,
        '${validPetDirectory.path}/spritesheet.webp',
      );
      expect(result.ignoredResources, hasLength(6));
      expect(
        result.ignoredResources.map((report) => report.reason),
        containsAll([
          PetResourceValidationReason.missingManifest,
          PetResourceValidationReason.missingSpritesheet,
          PetResourceValidationReason.invalidManifest,
        ]),
      );
      expect(
        result.ignoredResources.every(
          (report) => report.severity == PetResourceValidationSeverity.warning,
        ),
        isTrue,
      );
      expect(
        result.ignoredResources
            .where(
              (report) =>
                  report.reason ==
                  PetResourceValidationReason.missingSpritesheet,
            )
            .single
            .resourceId,
        'missing',
      );
    },
  );

  test('loadAvailableResources excludes invalid local resources', () async {
    final tempDirectory = await Directory.systemTemp.createTemp(
      'desktop_pet_runtime_resource_test_',
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
    await File('${validPetDirectory.path}/spritesheet.webp').writeAsBytes([0]);

    final invalidPetDirectory = Directory('${tempDirectory.path}/invalid');
    await invalidPetDirectory.create();

    final repository = PetResourceRepository(
      localPetsDirectory: tempDirectory.path,
    );

    final resources = await repository.loadAvailableResources();

    expect(resources.map((resource) => resource.id), ['default_pet', 'valid']);
  });

  group('LocalPetsDirectoryResolver', () {
    test('prefers CODEX_HOME', () {
      const resolver = LocalPetsDirectoryResolver(
        environment: {'CODEX_HOME': '/codex', 'HOME': '/home'},
        platform: DesktopPlatform.macos,
      );

      expect(resolver.resolve(), '/codex/pets');
    });

    test('uses HOME on macOS and Linux', () {
      const macosResolver = LocalPetsDirectoryResolver(
        environment: {'HOME': '/Users/example'},
        platform: DesktopPlatform.macos,
      );
      const linuxResolver = LocalPetsDirectoryResolver(
        environment: {'HOME': '/home/example'},
        platform: DesktopPlatform.linux,
      );

      expect(macosResolver.resolve(), '/Users/example/.codex/pets');
      expect(linuxResolver.resolve(), '/home/example/.codex/pets');
    });

    test('uses USERPROFILE on Windows', () {
      const resolver = LocalPetsDirectoryResolver(
        environment: {'USERPROFILE': r'C:\Users\example'},
        platform: DesktopPlatform.windows,
      );

      expect(resolver.resolve(), r'C:\Users\example/.codex/pets');
    });

    test('returns null when no platform home is available', () {
      const resolver = LocalPetsDirectoryResolver(
        environment: {},
        platform: DesktopPlatform.windows,
      );

      expect(resolver.resolve(), isNull);
    });
  });
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
