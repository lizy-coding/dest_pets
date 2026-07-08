import 'package:desktop_pet/app/app.dart';
import 'package:desktop_pet/desktop/auxiliary_window_controller.dart';
import 'package:desktop_pet/desktop/desktop_window_controller.dart';
import 'package:desktop_pet/desktop/platform_capabilities.dart';
import 'package:desktop_pet/pet/controller/pet_controller.dart';
import 'package:desktop_pet/pet/model/pet_config.dart';
import 'package:desktop_pet/pet/model/pet_menu_action.dart';
import 'package:desktop_pet/pet/model/pet_runtime_mode.dart';
import 'package:desktop_pet/pet/model/pet_settings_snapshot.dart';
import 'package:desktop_pet/pet/model/pet_state.dart';
import 'package:desktop_pet/pet/view/pet_actor.dart';
import 'package:desktop_pet/pet/view/pet_context_menu.dart';
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
  int refreshResourcesCalls = 0;
  int resetConfigCalls = 0;
  int recoverFromErrorCalls = 0;
  bool draggingStarted = false;
  bool? alwaysOnTopValue;

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

  @override
  Future<void> setAlwaysOnTop(bool value) async {
    alwaysOnTopValue = value;
    testState = testState.copyWith(
      config: testState.config.copyWith(alwaysOnTop: value),
    );
  }

  @override
  Future<void> refreshResources() async {
    refreshResourcesCalls += 1;
  }

  @override
  Future<void> resetConfig() async {
    resetConfigCalls += 1;
    testState = testState.copyWith(config: const PetConfig());
  }

  @override
  Future<void> recoverFromError() async {
    recoverFromErrorCalls += 1;
  }

  @override
  void startDragging() {
    draggingStarted = true;
    testState = testState.copyWith(runtimeMode: PetRuntimeMode.dragging);
  }
}

class FakeDesktopWindowController extends DesktopWindowController {
  FakeDesktopWindowController() : super();

  bool closeCalled = false;
  bool startDraggingCalled = false;
  bool? alwaysOnTopValue;

  @override
  PlatformCapabilities get capabilities {
    return const PlatformCapabilities(
      supportsTransparency: true,
      supportsClickThrough: false,
      supportsTray: false,
      supportsLaunchAtStartup: false,
      supportsGlobalShortcut: false,
    );
  }

  @override
  Future<void> startDragging() async {
    startDraggingCalled = true;
  }

  @override
  Future<void> setAlwaysOnTop(bool value) async {
    alwaysOnTopValue = value;
  }

  @override
  Future<void> close() async {
    closeCalled = true;
  }
}

class FakeAuxiliaryWindowController implements AuxiliaryWindowController {
  int showContextMenuCalls = 0;
  int closeContextMenuCalls = 0;
  Offset? anchorGlobalPosition;
  PetSettingsSnapshot? snapshot;
  PetMenuActionHandler? handler;

  @override
  Future<void> initializePetMenuActionHandler(
    PetMenuActionHandler handler,
  ) async {
    this.handler = handler;
  }

  @override
  Future<void> showContextMenu({
    required Offset anchorGlobalPosition,
    required PetSettingsSnapshot snapshot,
  }) async {
    showContextMenuCalls += 1;
    this.anchorGlobalPosition = anchorGlobalPosition;
    this.snapshot = snapshot;
  }

  @override
  Future<void> closeContextMenu() async {
    closeContextMenuCalls += 1;
  }

  @override
  void dispose() {}
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

    final windowController = FakeDesktopWindowController();
    addTearDown(windowController.dispose);

    await tester.pumpWidget(
      _PetViewHarness(
        controller: controller,
        windowController: windowController,
        auxiliaryWindowController: FakeAuxiliaryWindowController(),
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

  testWidgets('secondary tap requests auxiliary context menu with snapshot', (
    tester,
  ) async {
    final controller = FakePetController(
      PetState(
        config: const PetConfig(scale: 1.25, alwaysOnTop: false),
        resource: bundledResource,
        availableResources: [bundledResource, localResource],
      ),
    );
    addTearDown(controller.dispose);

    final windowController = FakeDesktopWindowController();
    addTearDown(windowController.dispose);
    final auxiliaryWindowController = FakeAuxiliaryWindowController();

    await tester.pumpWidget(
      _PetViewHarness(
        controller: controller,
        windowController: windowController,
        auxiliaryWindowController: auxiliaryWindowController,
      ),
    );

    await _openMenu(tester);

    expect(auxiliaryWindowController.showContextMenuCalls, 1);
    expect(auxiliaryWindowController.snapshot?.petId, 'default_pet');
    expect(auxiliaryWindowController.snapshot?.scale, 1.25);
    expect(auxiliaryWindowController.snapshot?.alwaysOnTop, isFalse);
    expect(auxiliaryWindowController.snapshot?.resourceOptions, hasLength(2));
    expect(find.byType(PetContextMenu), findsNothing);
  });

  testWidgets('dragging closes auxiliary context menu', (tester) async {
    final controller = FakePetController(
      PetState(
        config: const PetConfig(),
        resource: bundledResource,
        availableResources: [bundledResource],
        runtimeMode: PetRuntimeMode.idle,
      ),
    );
    addTearDown(controller.dispose);

    final windowController = FakeDesktopWindowController();
    addTearDown(windowController.dispose);
    final auxiliaryWindowController = FakeAuxiliaryWindowController();

    await tester.pumpWidget(
      _PetViewHarness(
        controller: controller,
        windowController: windowController,
        auxiliaryWindowController: auxiliaryWindowController,
      ),
    );

    await tester.drag(find.byType(PetHitArea), const Offset(10, 0));
    await tester.pump();

    expect(auxiliaryWindowController.closeContextMenuCalls, 1);
    expect(controller.draggingStarted, isTrue);
    expect(windowController.startDraggingCalled, isTrue);
  });

  testWidgets('context menu emits recovery action in error state', (
    tester,
  ) async {
    final actions = <PetMenuAction>[];
    final snapshot = PetSettingsSnapshot.fromState(
      PetState(
        config: const PetConfig(),
        resource: null,
        availableResources: [bundledResource, localResource],
        runtimeMode: PetRuntimeMode.error,
        errorMessage: 'load failed',
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PetContextMenu(snapshot: snapshot, onAction: actions.add),
        ),
      ),
    );

    await tester.tap(find.text('Recover'));

    expect(actions[0].type, PetMenuActionType.recoverFromError);
  });

  testWidgets('context menu emits switch action in idle state', (tester) async {
    final actions = <PetMenuAction>[];
    final snapshot = PetSettingsSnapshot.fromState(
      PetState(
        config: const PetConfig(),
        resource: bundledResource,
        availableResources: [bundledResource, localResource],
        runtimeMode: PetRuntimeMode.idle,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PetContextMenu(snapshot: snapshot, onAction: actions.add),
        ),
      ),
    );

    await tester.tap(find.text('Local Pet'));

    expect(actions.single.type, PetMenuActionType.switchPet);
    expect(actions.single.petId, 'local_pet');
  });

  testWidgets('app handles auxiliary menu actions', (tester) async {
    final controller = FakePetController(
      PetState(
        config: const PetConfig(),
        resource: bundledResource,
        availableResources: [bundledResource, localResource],
      ),
    );

    final windowController = FakeDesktopWindowController();
    addTearDown(windowController.dispose);
    final auxiliaryWindowController = FakeAuxiliaryWindowController();

    await tester.pumpWidget(
      App(
        windowController: windowController,
        auxiliaryWindowController: auxiliaryWindowController,
        petController: controller,
      ),
    );
    await tester.pump();

    await auxiliaryWindowController.handler!(
      const PetMenuAction(PetMenuActionType.switchPet, petId: 'local_pet'),
    );
    await auxiliaryWindowController.handler!(
      const PetMenuAction(PetMenuActionType.toggleAlwaysOnTop),
    );
    await auxiliaryWindowController.handler!(
      const PetMenuAction(PetMenuActionType.refreshResources),
    );
    await auxiliaryWindowController.handler!(
      const PetMenuAction(PetMenuActionType.resetConfig),
    );
    await auxiliaryWindowController.handler!(
      const PetMenuAction(PetMenuActionType.quit),
    );

    expect(controller.switchedPetId, 'local_pet');
    expect(controller.alwaysOnTopValue, isFalse);
    expect(windowController.alwaysOnTopValue, isTrue);
    expect(controller.refreshResourcesCalls, 1);
    expect(controller.resetConfigCalls, 1);
    expect(windowController.closeCalled, isTrue);
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
    required this.auxiliaryWindowController,
  });

  final PetController controller;
  final DesktopWindowController windowController;
  final AuxiliaryWindowController auxiliaryWindowController;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PetController>.value(
      value: controller,
      child: MaterialApp(
        home: PetView(
          windowController: windowController,
          auxiliaryWindowController: auxiliaryWindowController,
        ),
      ),
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
