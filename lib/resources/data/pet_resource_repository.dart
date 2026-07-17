import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'local_pets_directory_resolver.dart';
import '../model/pet_manifest.dart';
import '../model/pet_resource.dart';
import '../model/pet_resource_discovery_result.dart';

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
    final discoveryResult = await discoverLocalResourcesWithReports();

    return [bundledResource, ...discoveryResult.validResources];
  }

  Future<PetResourceDiscoveryResult> loadAvailableResourcesWithReports() async {
    final bundledResource = await loadBundledResource();
    final discoveryResult = await discoverLocalResourcesWithReports();

    return PetResourceDiscoveryResult(
      validResources: [bundledResource, ...discoveryResult.validResources],
      ignoredResources: discoveryResult.ignoredResources,
    );
  }

  Future<PetResource> loadBundledResource() async {
    final resource = await _loadBundledResource();
    if (resource == null) {
      throw StateError('Bundled pet resource is invalid.');
    }

    return resource;
  }

  Future<List<PetResource>> discoverLocalResources() async {
    final result = await discoverLocalResourcesWithReports();
    return result.validResources;
  }

  Future<PetResourceDiscoveryResult> discoverLocalResourcesWithReports() async {
    final directoryPath = localPetsDirectory ?? _defaultLocalPetsDirectory();
    if (directoryPath == null) {
      return const PetResourceDiscoveryResult(
        validResources: [],
        ignoredResources: [],
      );
    }

    final directory = Directory(directoryPath);
    if (!await directory.exists()) {
      return const PetResourceDiscoveryResult(
        validResources: [],
        ignoredResources: [],
      );
    }

    final resources = <PetResource>[];
    final reports = <PetResourceValidationReport>[];
    try {
      await for (final entity in directory.list(followLinks: false)) {
        if (entity is! Directory) {
          continue;
        }

        final result = await _loadLocalResource(entity);
        switch (result) {
          case _ValidLocalResource(:final resource):
            resources.add(resource);
          case _InvalidLocalResource(:final report):
            reports.add(report);
        }
      }
    } on FileSystemException {
      return PetResourceDiscoveryResult(
        validResources: const [],
        ignoredResources: [
          PetResourceValidationReport(
            directoryPath: directoryPath,
            severity: PetResourceValidationSeverity.error,
            reason: PetResourceValidationReason.unreadableDirectory,
            message: 'Local pets directory could not be read.',
          ),
        ],
      );
    }

    resources.sort((left, right) {
      final nameCompare = left.name.compareTo(right.name);
      if (nameCompare != 0) {
        return nameCompare;
      }

      return left.id.compareTo(right.id);
    });

    return PetResourceDiscoveryResult(
      validResources: resources,
      ignoredResources: reports,
    );
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

  Future<_LocalResourceLoadResult> _loadLocalResource(
    Directory directory,
  ) async {
    final manifestFile = File('${directory.path}/pet.json');
    if (!await manifestFile.exists()) {
      return _invalidLocalResource(
        directory,
        PetResourceValidationReason.missingManifest,
        'Resource is missing pet.json.',
      );
    }

    try {
      final manifest = await manifestFile.readAsString();
      final resource = _parseResource(
        manifest,
        source: PetResourceSource.local,
        basePath: directory.path,
      );
      if (resource == null) {
        return _invalidLocalResource(
          directory,
          PetResourceValidationReason.invalidManifest,
          'pet.json is not a valid current-version pet manifest.',
        );
      }

      final spritesheet = File(resource.resolvedSpritesheetPath);
      if (!await spritesheet.exists()) {
        return _invalidLocalResource(
          directory,
          PetResourceValidationReason.missingSpritesheet,
          'Resource spritesheet is missing.',
          resourceId: resource.id,
        );
      }

      return _ValidLocalResource(resource);
    } on FileSystemException {
      return _invalidLocalResource(
        directory,
        PetResourceValidationReason.unreadableResource,
        'Resource files could not be read.',
      );
    } on FormatException {
      return _invalidLocalResource(
        directory,
        PetResourceValidationReason.invalidManifest,
        'pet.json is not valid JSON.',
      );
    }
  }

  _InvalidLocalResource _invalidLocalResource(
    Directory directory,
    PetResourceValidationReason reason,
    String message, {
    String? resourceId,
  }) {
    return _InvalidLocalResource(
      PetResourceValidationReport(
        directoryPath: directory.path,
        resourceId: resourceId,
        severity: PetResourceValidationSeverity.warning,
        reason: reason,
        message: message,
      ),
    );
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
    return LocalPetsDirectoryResolver(
      environment: Platform.environment,
      platform: _currentPlatform(),
    ).resolve();
  }
}

sealed class _LocalResourceLoadResult {
  const _LocalResourceLoadResult();
}

class _ValidLocalResource extends _LocalResourceLoadResult {
  const _ValidLocalResource(this.resource);

  final PetResource resource;
}

class _InvalidLocalResource extends _LocalResourceLoadResult {
  const _InvalidLocalResource(this.report);

  final PetResourceValidationReport report;
}

DesktopPlatform _currentPlatform() {
  if (Platform.isMacOS) {
    return DesktopPlatform.macos;
  }

  if (Platform.isWindows) {
    return DesktopPlatform.windows;
  }

  if (Platform.isLinux) {
    return DesktopPlatform.linux;
  }

  return DesktopPlatform.other;
}
