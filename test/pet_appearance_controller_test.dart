import 'package:desktop_pet/pet/controller/pet_appearance_controller.dart';
import 'package:desktop_pet/pet/data/pet_resource_repository.dart';
import 'package:desktop_pet/pet/data/pet_settings_store.dart';
import 'package:desktop_pet/pet/model/pet_appearance_settings.dart';
import 'package:desktop_pet/pet/model/pet_appearance_state.dart';
import 'package:desktop_pet/pet/model/pet_resource.dart';
import 'package:flutter_test/flutter_test.dart';

class FakePetResourceRepository extends PetResourceRepository {
  FakePetResourceRepository(this.resources) : super(localPetsDirectory: '');

  final List<PetResource> resources;

  @override
  Future<List<PetResource>> loadAvailableResources() async {
    return resources;
  }
}

class FakePetSettingsStore extends PetSettingsStore {
  FakePetSettingsStore([this.settings]);

  PetAppearanceSettings? settings;
  bool resetCalled = false;

  @override
  Future<PetAppearanceSettings?> loadAppearanceSettings() async {
    return settings;
  }

  @override
  Future<void> saveAppearanceSettings(PetAppearanceSettings settings) async {
    this.settings = settings;
  }

  @override
  Future<void> resetAppearanceSettings() async {
    resetCalled = true;
    settings = null;
  }
}

void main() {
  final bundledResource = PetResource(
    source: PetResourceSource.bundled,
    basePath: PetResourceRepository.defaultBundledBasePath,
    id: 'mq',
    displayName: 'MQ',
    description: 'A calm gray amber-eyed companion cat.',
    spritesheetPath: 'spritesheet.webp',
  );
  final localResource = PetResource(
    source: PetResourceSource.local,
    basePath: '/tmp/local_pet',
    id: 'local',
    displayName: 'Local Pet',
    description: 'A local pet.',
    spritesheetPath: 'spritesheet.webp',
  );

  test('loads bundled fallback on first launch', () async {
    final controller = PetAppearanceController(
      resourceRepository: FakePetResourceRepository([
        bundledResource,
        localResource,
      ]),
      settingsStore: FakePetSettingsStore(),
    );
    addTearDown(controller.dispose);

    await controller.load();

    expect(controller.state.selectedResource, bundledResource);
    expect(controller.state.currentResourceId, bundledResource.resourceId);
    expect(controller.state.availableResources, [
      bundledResource,
      localResource,
    ]);
    expect(controller.state.scale, PetAppearanceState.defaultScale);
  });

  test('restores saved resource id when it exists', () async {
    final controller = PetAppearanceController(
      resourceRepository: FakePetResourceRepository([
        bundledResource,
        localResource,
      ]),
      settingsStore: FakePetSettingsStore(
        PetAppearanceSettings(resourceId: localResource.resourceId, scale: 1.5),
      ),
    );
    addTearDown(controller.dispose);

    await controller.load();

    expect(controller.state.selectedResource, localResource);
    expect(controller.state.scale, 1.5);
  });

  test(
    'falls back to bundled resource when saved resource is missing',
    () async {
      final controller = PetAppearanceController(
        resourceRepository: FakePetResourceRepository([
          bundledResource,
          localResource,
        ]),
        settingsStore: FakePetSettingsStore(
          const PetAppearanceSettings(resourceId: 'local:missing', scale: 1.25),
        ),
      );
      addTearDown(controller.dispose);

      await controller.load();

      expect(controller.state.selectedResource, bundledResource);
      expect(controller.state.scale, 1.25);
    },
  );

  test('apply resource id updates state and persists settings', () async {
    final store = FakePetSettingsStore();
    final controller = PetAppearanceController(
      resourceRepository: FakePetResourceRepository([
        bundledResource,
        localResource,
      ]),
      settingsStore: store,
    );
    addTearDown(controller.dispose);
    await controller.load();

    await controller.apply(resourceId: localResource.resourceId);

    expect(controller.state.selectedResource, localResource);
    expect(store.settings?.resourceId, localResource.resourceId);
    expect(store.settings?.scale, PetAppearanceState.defaultScale);
  });

  test('apply scale updates state and persists settings', () async {
    final store = FakePetSettingsStore();
    final controller = PetAppearanceController(
      resourceRepository: FakePetResourceRepository([bundledResource]),
      settingsStore: store,
    );
    addTearDown(controller.dispose);
    await controller.load();

    await controller.apply(scale: 2);

    expect(controller.state.selectedResource, bundledResource);
    expect(controller.state.scale, 2);
    expect(store.settings?.resourceId, bundledResource.resourceId);
    expect(store.settings?.scale, 2);
  });

  test('reset restores default resource and scale', () async {
    final store = FakePetSettingsStore(
      PetAppearanceSettings(resourceId: localResource.resourceId, scale: 2),
    );
    final controller = PetAppearanceController(
      resourceRepository: FakePetResourceRepository([
        bundledResource,
        localResource,
      ]),
      settingsStore: store,
    );
    addTearDown(controller.dispose);
    await controller.load();

    await controller.reset();

    expect(controller.state.selectedResource, bundledResource);
    expect(controller.state.scale, PetAppearanceState.defaultScale);
    expect(store.resetCalled, isTrue);
    expect(store.settings, isNull);
  });
}
