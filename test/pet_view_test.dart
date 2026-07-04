import 'package:desktop_pet/desktop/desktop_window_controller.dart';
import 'package:desktop_pet/pet/controller/pet_appearance_controller.dart';
import 'package:desktop_pet/pet/data/pet_resource_repository.dart';
import 'package:desktop_pet/pet/data/pet_settings_store.dart';
import 'package:desktop_pet/pet/model/pet_appearance_settings.dart';
import 'package:desktop_pet/pet/model/pet_resource.dart';
import 'package:desktop_pet/pet/pet_actor.dart';
import 'package:desktop_pet/pet/pet_hit_area.dart';
import 'package:desktop_pet/pet/view/pet_view.dart';
import 'package:desktop_pet/settings/pet_settings.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class FakePetResourceRepository extends PetResourceRepository {
  FakePetResourceRepository(this.resources) : super(localPetsDirectory: '');

  final List<PetResource> resources;

  @override
  Future<List<PetResource>> loadAvailableResources() async {
    return resources;
  }
}

class FakePetSettingsStore extends PetSettingsStore {
  PetAppearanceSettings? settings;

  @override
  Future<PetAppearanceSettings?> loadAppearanceSettings() async {
    return settings;
  }

  @override
  Future<void> saveAppearanceSettings(PetAppearanceSettings settings) async {
    this.settings = settings;
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

  testWidgets('renders the current resource', (tester) async {
    final controller = PetAppearanceController(
      resourceRepository: FakePetResourceRepository([bundledResource]),
      settingsStore: FakePetSettingsStore(),
    );
    addTearDown(controller.dispose);
    await controller.load();

    final windowController = DesktopWindowController(settings: PetSettings());
    addTearDown(windowController.dispose);

    await tester.pumpWidget(
      _PetViewHarness(
        controller: controller,
        windowController: windowController,
      ),
    );
    await tester.pump();

    expect(find.byType(PetActor), findsOneWidget);
  });

  testWidgets('right click menu shows available resources', (tester) async {
    final controller = PetAppearanceController(
      resourceRepository: FakePetResourceRepository([
        bundledResource,
        localResource,
      ]),
      settingsStore: FakePetSettingsStore(),
    );
    addTearDown(controller.dispose);
    await controller.load();

    final windowController = DesktopWindowController(settings: PetSettings());
    addTearDown(windowController.dispose);

    await tester.pumpWidget(
      _PetViewHarness(
        controller: controller,
        windowController: windowController,
      ),
    );

    await tester.tap(
      find.byType(PetHitArea),
      buttons: kSecondaryMouseButton,
      kind: PointerDeviceKind.mouse,
    );
    await tester.pumpAndSettle();

    expect(find.text('MQ (Default)'), findsOneWidget);
    expect(find.text('Local Pet'), findsOneWidget);
  });

  testWidgets('selecting a menu item updates controller state', (tester) async {
    final controller = PetAppearanceController(
      resourceRepository: FakePetResourceRepository([
        bundledResource,
        localResource,
      ]),
      settingsStore: FakePetSettingsStore(),
    );
    addTearDown(controller.dispose);
    await controller.load();

    final windowController = DesktopWindowController(settings: PetSettings());
    addTearDown(windowController.dispose);

    await tester.pumpWidget(
      _PetViewHarness(
        controller: controller,
        windowController: windowController,
      ),
    );

    await tester.tap(
      find.byType(PetHitArea),
      buttons: kSecondaryMouseButton,
      kind: PointerDeviceKind.mouse,
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.widgetWithText(CheckedPopupMenuItem<String>, 'Local Pet'),
    );
    await tester.pumpAndSettle();

    expect(controller.state.selectedResource, localResource);
    expect(controller.state.currentResourceId, localResource.resourceId);
  });
}

class _PetViewHarness extends StatelessWidget {
  const _PetViewHarness({
    required this.controller,
    required this.windowController,
  });

  final PetAppearanceController controller;
  final DesktopWindowController windowController;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PetAppearanceController>.value(
      value: controller,
      child: MaterialApp(home: PetView(windowController: windowController)),
    );
  }
}
