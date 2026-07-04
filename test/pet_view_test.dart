import 'package:desktop_pet/desktop/desktop_window_controller.dart';
import 'package:desktop_pet/pet/controller/pet_controller.dart';
import 'package:desktop_pet/pet/model/pet_config.dart';
import 'package:desktop_pet/pet/model/pet_state.dart';
import 'package:desktop_pet/pet/view/pet_actor.dart';
import 'package:desktop_pet/pet/view/pet_hit_area.dart';
import 'package:desktop_pet/pet/view/pet_view.dart';
import 'package:desktop_pet/resources/data/pet_resource_repository.dart';
import 'package:desktop_pet/resources/model/pet_manifest.dart';
import 'package:desktop_pet/resources/model/pet_resource.dart';
import 'package:desktop_pet/settings/settings_store.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class FakePetController extends PetController {
  FakePetController(this.testState)
    : super(
        resourceRepository: PetResourceRepository(localPetsDirectory: ''),
        settingsStore: SettingsStore(),
      );

  PetState testState;
  String? switchedPetId;
  int increaseCalls = 0;
  int decreaseCalls = 0;
  int resetCalls = 0;

  @override
  PetState get state {
    return testState;
  }

  @override
  Future<void> switchPet(String petId) async {
    switchedPetId = petId;
  }

  @override
  Future<void> increaseScale() async {
    increaseCalls += 1;
  }

  @override
  Future<void> decreaseScale() async {
    decreaseCalls += 1;
  }

  @override
  Future<void> resetScale() async {
    resetCalls += 1;
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

  testWidgets('renders current resource with config scale', (tester) async {
    final controller = FakePetController(
      PetState(
        config: const PetConfig(scale: 1.5),
        resource: bundledResource,
        availableResources: [bundledResource],
      ),
    );
    addTearDown(controller.dispose);

    final windowController = DesktopWindowController(
      settingsStore: SettingsStore(),
    );
    addTearDown(windowController.dispose);

    await tester.pumpWidget(
      _PetViewHarness(
        controller: controller,
        windowController: windowController,
      ),
    );
    await tester.pump();

    expect(find.byType(PetActor), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) => widget is Transform && widget.transform.storage[0] == 1.5,
      ),
      findsOneWidget,
    );
  });

  testWidgets('right click menu switches resources', (tester) async {
    final controller = FakePetController(
      PetState(
        config: const PetConfig(),
        resource: bundledResource,
        availableResources: [bundledResource, localResource],
      ),
    );
    addTearDown(controller.dispose);

    final windowController = DesktopWindowController(
      settingsStore: SettingsStore(),
    );
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

    expect(controller.switchedPetId, 'local_pet');
  });

  testWidgets('right click menu dispatches size operations', (tester) async {
    final controller = FakePetController(
      PetState(
        config: const PetConfig(),
        resource: bundledResource,
        availableResources: [bundledResource],
      ),
    );
    addTearDown(controller.dispose);

    final windowController = DesktopWindowController(
      settingsStore: SettingsStore(),
    );
    addTearDown(windowController.dispose);

    await tester.pumpWidget(
      _PetViewHarness(
        controller: controller,
        windowController: windowController,
      ),
    );

    await _openMenu(tester);
    await tester.tap(find.text('Increase size'));
    await tester.pumpAndSettle();
    expect(controller.increaseCalls, 1);

    await _openMenu(tester);
    await tester.tap(find.text('Decrease size'));
    await tester.pumpAndSettle();
    expect(controller.decreaseCalls, 1);

    await _openMenu(tester);
    await tester.tap(find.text('Reset size'));
    await tester.pumpAndSettle();
    expect(controller.resetCalls, 1);
  });
}

Future<void> _openMenu(WidgetTester tester) async {
  await tester.tap(
    find.byType(PetHitArea),
    buttons: kSecondaryMouseButton,
    kind: PointerDeviceKind.mouse,
  );
  await tester.pumpAndSettle();
}

class _PetViewHarness extends StatelessWidget {
  const _PetViewHarness({
    required this.controller,
    required this.windowController,
  });

  final PetController controller;
  final DesktopWindowController windowController;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PetController>.value(
      value: controller,
      child: MaterialApp(home: PetView(windowController: windowController)),
    );
  }
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
