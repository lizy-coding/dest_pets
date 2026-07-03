import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';

import 'pet_package.dart';

class PetPackageRepository {
  PetPackageRepository({
    AssetBundle? assetBundle,
    this.localPetsDirectory,
    this.bundledBasePath = defaultBundledBasePath,
  }) : _assetBundle = assetBundle ?? rootBundle;

  static const String defaultBundledBasePath = 'assets/pets/default';

  final AssetBundle _assetBundle;
  final String? localPetsDirectory;
  final String bundledBasePath;

  Future<List<PetPackage>> loadAvailablePets() async {
    final bundledPet = await loadBundledPet();
    final localPets = await discoverLocalPets();

    return [bundledPet, ...localPets];
  }

  Future<PetPackage> loadBundledPet() async {
    final manifest = await _assetBundle.loadString('$bundledBasePath/pet.json');
    final pet = _parsePetPackage(
      manifest,
      source: PetPackageSource.bundled,
      basePath: bundledBasePath,
    );

    if (pet == null) {
      throw StateError('Bundled pet manifest is invalid.');
    }

    return pet;
  }

  Future<List<PetPackage>> discoverLocalPets() async {
    final directoryPath = localPetsDirectory ?? _defaultLocalPetsDirectory();
    if (directoryPath == null) {
      return const [];
    }

    final directory = Directory(directoryPath);
    if (!await directory.exists()) {
      return const [];
    }

    final pets = <PetPackage>[];
    try {
      await for (final entity in directory.list(followLinks: false)) {
        if (entity is! Directory) {
          continue;
        }

        final pet = await _loadLocalPet(entity);
        if (pet != null) {
          pets.add(pet);
        }
      }
    } on FileSystemException {
      return const [];
    }

    pets.sort((left, right) {
      final nameCompare = left.displayName.compareTo(right.displayName);
      if (nameCompare != 0) {
        return nameCompare;
      }

      return left.id.compareTo(right.id);
    });

    return pets;
  }

  PetPackage resolveSelection(
    List<PetPackage> pets,
    PetPackageSelection? selection,
  ) {
    if (selection != null) {
      for (final pet in pets) {
        if (pet.selection == selection) {
          return pet;
        }
      }
    }

    for (final pet in pets) {
      if (pet.source == PetPackageSource.bundled) {
        return pet;
      }
    }

    return pets.first;
  }

  Future<PetPackage?> _loadLocalPet(Directory directory) async {
    final manifestFile = File('${directory.path}/pet.json');
    if (!await manifestFile.exists()) {
      return null;
    }

    try {
      final manifest = await manifestFile.readAsString();
      final pet = _parsePetPackage(
        manifest,
        source: PetPackageSource.local,
        basePath: directory.path,
      );
      if (pet == null) {
        return null;
      }

      final spritesheet = File(pet.resolvedSpritesheetPath);
      if (!await spritesheet.exists()) {
        return null;
      }

      return pet;
    } on FileSystemException {
      return null;
    } on FormatException {
      return null;
    }
  }

  PetPackage? _parsePetPackage(
    String manifest, {
    required PetPackageSource source,
    required String basePath,
  }) {
    final decoded = jsonDecode(manifest);
    if (decoded is! Map) {
      return null;
    }

    return PetPackage.fromJson(
      Map<String, Object?>.from(decoded),
      source: source,
      basePath: basePath,
    );
  }

  String? _defaultLocalPetsDirectory() {
    final codexHome = Platform.environment['CODEX_HOME'];
    if (codexHome != null && codexHome.isNotEmpty) {
      return '$codexHome/pets';
    }

    final home = Platform.environment['HOME'];
    if (home == null || home.isEmpty) {
      return null;
    }

    return '$home/.codex/pets';
  }
}
