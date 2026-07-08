import 'package:desktop_pet/pet/controller/pet_controller.dart';
import 'package:desktop_pet/pet/model/pet_config.dart';
import 'package:desktop_pet/pet/model/pet_runtime_mode.dart';
import 'package:desktop_pet/resources/data/pet_resource_repository.dart';
import 'package:desktop_pet/resources/model/pet_manifest.dart';
import 'package:desktop_pet/resources/model/pet_resource.dart';
import 'package:desktop_pet/settings/settings_store.dart';
import 'package:flutter_test/flutter_test.dart';

class FakePetResourceRepository extends PetResourceRepository {
  FakePetResourceRepository(this.resources, {this.shouldThrow = false})
    : super(localPetsDirectory: '');

  List<PetResource> resources;
  final bool shouldThrow;
  int loadCalls = 0;

  @override
  Future<List<PetResource>> loadAvailableResources() async {
    loadCalls += 1;
    if (shouldThrow) {
      throw StateError('load failed');
    }

    return resources;
  }
}

class FakeSettingsStore extends SettingsStore {
  FakeSettingsStore([this.config]);

  PetConfig? config;
  bool resetCalled = false;

  @override
  Future<PetConfig?> loadConfig() async {
    return config;
  }

  @override
  Future<void> saveConfig(PetConfig config) async {
    this.config = config;
  }

  @override
  Future<void> resetConfig() async {
    resetCalled = true;
    config = null;
  }
}

void main() {
  final bundledResource = _resource(
    source: PetResourceSource.bundled,
    id: 'default_pet',
    name: 'Default Pet',
  );
  final localResource = _resource(
    source: PetResourceSource.local,
    id: 'local_pet',
    name: 'Local Pet',
  );

  test('initialize enters idle after loading resources', () async {
    final controller = PetController(
      resourceRepository: FakePetResourceRepository([
        bundledResource,
        localResource,
      ]),
      settingsStore: FakeSettingsStore(),
    );
    addTearDown(controller.dispose);

    await controller.initialize();

    expect(controller.state.runtimeMode, PetRuntimeMode.idle);
    expect(controller.state.resource, bundledResource);
    expect(controller.state.availableResources, [
      bundledResource,
      localResource,
    ]);
  });

  test('initialize enters error when resources fail to load', () async {
    final controller = PetController(
      resourceRepository: FakePetResourceRepository(
        const [],
        shouldThrow: true,
      ),
      settingsStore: FakeSettingsStore(),
    );
    addTearDown(controller.dispose);

    await controller.initialize();

    expect(controller.state.runtimeMode, PetRuntimeMode.error);
    expect(controller.state.errorMessage, contains('load failed'));
  });

  test('switchPet updates config and returns to idle', () async {
    final store = FakeSettingsStore();
    final controller = PetController(
      resourceRepository: FakePetResourceRepository([
        bundledResource,
        localResource,
      ]),
      settingsStore: store,
    );
    addTearDown(controller.dispose);
    await controller.initialize();

    await controller.switchPet(localResource.id);

    expect(controller.state.runtimeMode, PetRuntimeMode.idle);
    expect(controller.state.resource, localResource);
    expect(controller.state.config.petId, localResource.id);
    expect(store.config?.petId, localResource.id);
  });

  test(
    'switchPet enters error when the requested resource is missing',
    () async {
      final controller = PetController(
        resourceRepository: FakePetResourceRepository([bundledResource]),
        settingsStore: FakeSettingsStore(),
      );
      addTearDown(controller.dispose);
      await controller.initialize();

      await controller.switchPet('missing');

      expect(controller.state.runtimeMode, PetRuntimeMode.error);
      expect(controller.state.errorMessage, contains('missing'));
    },
  );

  test('scale methods clamp and persist config', () async {
    final store = FakeSettingsStore();
    final controller = PetController(
      resourceRepository: FakePetResourceRepository([bundledResource]),
      settingsStore: store,
    );
    addTearDown(controller.dispose);
    await controller.initialize();

    await controller.setScale(99);
    expect(controller.state.config.scale, PetController.maxScale);
    expect(store.config?.scale, PetController.maxScale);

    await controller.decreaseScale();
    expect(controller.state.config.scale, closeTo(1.9, 0.0001));

    await controller.setScale(-1);
    expect(controller.state.config.scale, PetController.minScale);

    await controller.increaseScale();
    expect(controller.state.config.scale, closeTo(0.6, 0.0001));

    await controller.resetScale();
    expect(controller.state.config.scale, PetConfig.defaultScale);
  });

  test(
    'refreshResources keeps the selected pet when still available',
    () async {
      final store = FakeSettingsStore();
      final repository = FakePetResourceRepository([
        bundledResource,
        localResource,
      ]);
      final controller = PetController(
        resourceRepository: repository,
        settingsStore: store,
      );
      addTearDown(controller.dispose);
      await controller.initialize();
      await controller.switchPet(localResource.id);

      await controller.refreshResources();

      expect(controller.state.runtimeMode, PetRuntimeMode.idle);
      expect(controller.state.resource, localResource);
      expect(controller.state.config.petId, localResource.id);
      expect(store.config?.petId, localResource.id);
    },
  );

  test(
    'refreshResources falls back when the selected pet is unavailable',
    () async {
      final store = FakeSettingsStore(const PetConfig(petId: 'local_pet'));
      final repository = FakePetResourceRepository([
        bundledResource,
        localResource,
      ]);
      final controller = PetController(
        resourceRepository: repository,
        settingsStore: store,
      );
      addTearDown(controller.dispose);
      await controller.initialize();

      repository.resources = [bundledResource];
      await controller.refreshResources();

      expect(controller.state.runtimeMode, PetRuntimeMode.idle);
      expect(controller.state.resource, bundledResource);
      expect(controller.state.config.petId, bundledResource.id);
      expect(store.config?.petId, bundledResource.id);
    },
  );

  test('refreshResources enters error when resources fail to load', () async {
    final controller = PetController(
      resourceRepository: FakePetResourceRepository(
        const [],
        shouldThrow: true,
      ),
      settingsStore: FakeSettingsStore(),
    );
    addTearDown(controller.dispose);

    await controller.refreshResources();

    expect(controller.state.runtimeMode, PetRuntimeMode.error);
    expect(controller.state.errorMessage, contains('load failed'));
  });

  test('resetConfig clears persisted config and restores defaults', () async {
    final store = FakeSettingsStore(
      const PetConfig(petId: 'local_pet', scale: 1.5, alwaysOnTop: false),
    );
    final controller = PetController(
      resourceRepository: FakePetResourceRepository([
        bundledResource,
        localResource,
      ]),
      settingsStore: store,
    );
    addTearDown(controller.dispose);
    await controller.initialize();

    await controller.resetConfig();

    expect(store.resetCalled, isTrue);
    expect(controller.state.runtimeMode, PetRuntimeMode.idle);
    expect(controller.state.resource, bundledResource);
    expect(controller.state.config, const PetConfig());
  });

  test('startDragging and endDragging update mode and save position', () async {
    final store = FakeSettingsStore();
    final controller = PetController(
      resourceRepository: FakePetResourceRepository([bundledResource]),
      settingsStore: store,
    );
    addTearDown(controller.dispose);
    await controller.initialize();

    controller.startDragging();
    expect(controller.state.runtimeMode, PetRuntimeMode.dragging);

    await controller.endDragging(const Offset(10, 20));

    expect(controller.state.runtimeMode, PetRuntimeMode.idle);
    expect(controller.state.config.windowPosition, const Offset(10, 20));
    expect(store.config?.windowPosition, const Offset(10, 20));
  });
}

PetResource _resource({
  required PetResourceSource source,
  required String id,
  required String name,
}) {
  final manifest = PetManifest.fromJson({
    'id': id,
    'name': name,
    'description': 'A test pet.',
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
  })!;

  return PetResource(
    source: source,
    basePath: source == PetResourceSource.bundled
        ? PetResourceRepository.defaultBundledBasePath
        : '/tmp/$id',
    manifest: manifest,
  );
}
