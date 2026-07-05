import 'package:desktop_pet/app/app.dart';
import 'package:desktop_pet/desktop/auxiliary_window_controller.dart';
import 'package:desktop_pet/desktop/desktop_window_controller.dart';
import 'package:desktop_pet/pet/model/pet_settings_snapshot.dart';
import 'package:desktop_pet/pet/view/pet_actor.dart';
import 'package:desktop_pet/resources/data/pet_resource_repository.dart';
import 'package:desktop_pet/resources/model/pet_manifest.dart';
import 'package:desktop_pet/resources/model/pet_resource.dart';
import 'package:desktop_pet/settings/settings_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakePetResourceRepository extends PetResourceRepository {
  FakePetResourceRepository(this.resources) : super(localPetsDirectory: '');

  final List<PetResource> resources;

  @override
  Future<List<PetResource>> loadAvailableResources() async {
    return resources;
  }
}

class FakeAuxiliaryWindowController implements AuxiliaryWindowController {
  @override
  Future<void> initializePetMenuActionHandler(
    PetMenuActionHandler handler,
  ) async {}

  @override
  Future<void> showContextMenu({
    required Offset anchorGlobalPosition,
    required PetSettingsSnapshot snapshot,
  }) async {}

  @override
  Future<void> closeContextMenu() async {}

  @override
  void dispose() {}
}

void main() {
  testWidgets('renders the desktop pet view', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final settingsStore = SettingsStore();
    final windowController = DesktopWindowController(
      settingsStore: settingsStore,
    );
    final pet = _resource();

    await tester.pumpWidget(
      App(
        windowController: windowController,
        auxiliaryWindowController: FakeAuxiliaryWindowController(),
        settingsStore: settingsStore,
        resourceRepository: FakePetResourceRepository([pet]),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(PetActor), findsOneWidget);

    windowController.dispose();
  });
}

PetResource _resource() {
  final manifest = PetManifest.fromJson({
    'id': 'default_pet',
    'name': 'Default Pet',
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
    source: PetResourceSource.bundled,
    basePath: PetResourceRepository.defaultBundledBasePath,
    manifest: manifest,
  );
}
