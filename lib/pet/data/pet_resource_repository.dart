import '../model/pet_resource.dart';
import '../pet_package_repository.dart';

class PetResourceRepository extends PetPackageRepository {
  PetResourceRepository({
    super.assetBundle,
    super.localPetsDirectory,
    super.bundledBasePath,
  });

  static const String defaultBundledBasePath =
      PetPackageRepository.defaultBundledBasePath;

  Future<List<PetResource>> loadAvailableResources() {
    return loadAvailablePets();
  }

  Future<PetResource> loadBundledResource() {
    return loadBundledPet();
  }

  Future<List<PetResource>> discoverLocalResources() {
    return discoverLocalPets();
  }

  PetResource resolveResource(List<PetResource> resources, String? resourceId) {
    if (resources.isEmpty) {
      throw StateError('No pet resources are available.');
    }

    final normalizedResourceId = resourceId?.trim();
    if (normalizedResourceId != null && normalizedResourceId.isNotEmpty) {
      for (final resource in resources) {
        if (resource.resourceId == normalizedResourceId ||
            resource.id == normalizedResourceId) {
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
}

class PetPackageResourceRepositoryAdapter extends PetResourceRepository {
  PetPackageResourceRepositoryAdapter(this._packageRepository)
    : super(localPetsDirectory: '');

  final PetPackageRepository _packageRepository;

  @override
  Future<List<PetResource>> loadAvailablePets() {
    return _packageRepository.loadAvailablePets();
  }

  @override
  Future<List<PetResource>> loadAvailableResources() {
    return _packageRepository.loadAvailablePets();
  }

  @override
  Future<PetResource> loadBundledPet() {
    return _packageRepository.loadBundledPet();
  }

  @override
  Future<PetResource> loadBundledResource() {
    return _packageRepository.loadBundledPet();
  }

  @override
  Future<List<PetResource>> discoverLocalPets() {
    return _packageRepository.discoverLocalPets();
  }

  @override
  Future<List<PetResource>> discoverLocalResources() {
    return _packageRepository.discoverLocalPets();
  }

  @override
  PetResource resolveSelection(
    List<PetResource> pets,
    PetResourceSelection? selection,
  ) {
    return _packageRepository.resolveSelection(pets, selection);
  }
}
