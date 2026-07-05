import 'package:desktop_pet/desktop/auxiliary_window_arguments.dart';
import 'package:desktop_pet/desktop/desktop_auxiliary_window_controller.dart';
import 'package:desktop_pet/pet/model/pet_runtime_mode.dart';
import 'package:desktop_pet/pet/model/pet_settings_snapshot.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('showContextMenu anchors to cursor screen point', () async {
    var closeCalls = 0;
    var cursorCalls = 0;
    AuxiliaryWindowArguments? openedArguments;

    final controller = DesktopAuxiliaryWindowController(
      supportsAuxiliaryWindowsOverride: true,
      contextMenuCloser: () async {
        closeCalls += 1;
      },
      cursorScreenPointProvider: () async {
        cursorCalls += 1;
        return const Offset(900, 700);
      },
      auxiliaryWindowOpener: (arguments) async {
        openedArguments = arguments;
      },
    );

    await controller.showContextMenu(
      anchorGlobalPosition: const Offset(12, 34),
      snapshot: const PetSettingsSnapshot(
        petId: 'default_pet',
        scale: 1,
        alwaysOnTop: true,
        resourceOptions: [],
        runtimeMode: PetRuntimeMode.idle,
      ),
    );

    expect(closeCalls, 1);
    expect(cursorCalls, 1);
    expect(openedArguments?.type, AuxiliaryWindowType.contextMenu);
    expect(openedArguments?.anchorGlobalPosition, const Offset(900, 700));
    expect(openedArguments?.snapshot?.petId, 'default_pet');
  });
}
