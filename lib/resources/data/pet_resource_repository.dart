import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../model/pet_manifest.dart';
import '../model/pet_resource.dart';

class PetResourceRepository {
  PetResourceRepository({
    AssetBundle? assetBundle,
    this.localPetsDirectory,
    this.bundledBasePath = defaultBundledBasePath,
  }) : _assetBundle = assetBundle ?? rootBundle;

  static const String defaultBundledBasePath = 'assets/pets/default_pet';

  final AssetBundle _assetBundle;
  final String? localPetsDirectory;
  final String bundledBasePath;

  Future<List<PetResource>> loadAvailableResources() async {
    final bundledResource = await loadBundledResource();
    final localResources = await discoverLocalResources();

    return [bundledResource, ...localResources];
  }

  Future<PetResource> loadBundledResource() async {
    final resource = await _loadBundledResource();
    if (resource == null) {
      throw StateError('Bundled pet resource is invalid.');
    }

    return resource;
  }

  Future<List<PetResource>> discoverLocalResources() async {
    final directoryPath = localPetsDirectory ?? _defaultLocalPetsDirectory();
    if (directoryPath == null) {
      return const [];
    }

    final directory = Directory(directoryPath);
    if (!await directory.exists()) {
      return const [];
    }

    final resources = <PetResource>[];
    try {
      await for (final entity in directory.list(followLinks: false)) {
        if (entity is! Directory) {
          continue;
        }

        final resource = await _loadLocalResource(entity);
        if (resource != null) {
          resources.add(resource);
        }
      }
    } on FileSystemException {
      return const [];
    }

    resources.sort((left, right) {
      final nameCompare = left.name.compareTo(right.name);
      if (nameCompare != 0) {
        return nameCompare;
      }

      return left.id.compareTo(right.id);
    });

    return resources;
  }

  PetResource resolveResource(List<PetResource> resources, String petId) {
    if (resources.isEmpty) {
      throw StateError('No pet resources are available.');
    }

    final normalizedPetId = petId.trim();
    if (normalizedPetId.isNotEmpty) {
      for (final resource in resources) {
        if (resource.id == normalizedPetId) {
          return resource;
        }
      }
    }

    for (final resource in resources) {
      if (resource.source == PetResourceSource.bundled) {
        return resource;
      }
    }

    return resources.first;
  }

  Future<PetResource?> _loadBundledResource() async {
    try {
      final manifest = await _assetBundle.loadString(
        '$bundledBasePath/pet.json',
      );
      final resource = _parseResource(
        manifest,
        source: PetResourceSource.bundled,
        basePath: bundledBasePath,
      );
      if (resource == null) {
        return null;
      }

      await _assetBundle.load(resource.resolvedSpritesheetPath);
      return resource;
    } on FlutterError {
      return null;
    } on FormatException {
      return null;
    }
  }

  Future<PetResource?> _loadLocalResource(Directory directory) async {
    final manifestFile = File('${directory.path}/pet.json');
    if (!await manifestFile.exists()) {
      return null;
    }

    try {
      final manifest = await manifestFile.readAsString();
      final resource = _parseResource(
        manifest,
        source: PetResourceSource.local,
        basePath: directory.path,
      );
      if (resource == null) {
        return null;
      }

      final spritesheet = File(resource.resolvedSpritesheetPath);
      if (!await spritesheet.exists()) {
        return null;
      }

      return resource;
    } on FileSystemException {
      return null;
    } on FormatException {
      return null;
    }
  }

  PetResource? _parseResource(
    String manifest, {
    required PetResourceSource source,
    required String basePath,
  }) {
    final decoded = jsonDecode(manifest);
    if (decoded is! Map) {
      return null;
    }

    final petManifest = PetManifest.fromJson(
      Map<String, Object?>.from(decoded),
    );
    if (petManifest == null) {
      return null;
    }

    return PetResource(
      source: source,
      basePath: basePath,
      manifest: petManifest,
    );
  }

  String? _defaultLocalPetsDirectory() {
    final codexHome = Platform.environment['CODEX_HOME'];
    if (codexHome != null && codexHome.isNotEmpty) {
      return '$codexHome/pets';
    }

    final home =
        Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];
    if (home == null || home.isEmpty) {
      return null;
    }

    return '$home/.codex/pets';
  }
}
