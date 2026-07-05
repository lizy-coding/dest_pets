import 'package:desktop_pet/desktop/auxiliary_window_arguments.dart';
import 'package:desktop_pet/pet/model/pet_menu_action.dart';
import 'package:desktop_pet/pet/model/pet_resource_option.dart';
import 'package:desktop_pet/pet/model/pet_runtime_mode.dart';
import 'package:desktop_pet/pet/model/pet_settings_snapshot.dart';
import 'package:desktop_pet/resources/model/pet_resource.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('PetMenuAction JSON round trips', () {
    const action = PetMenuAction(
      PetMenuActionType.switchPet,
      petId: 'local_pet',
      enabled: false,
    );

    final decoded = PetMenuAction.fromJson(action.toJson());

    expect(decoded.type, PetMenuActionType.switchPet);
    expect(decoded.petId, 'local_pet');
    expect(decoded.enabled, isFalse);
  });

  test('PetResourceOption JSON round trips', () {
    const option = PetResourceOption(
      id: 'local_pet',
      label: 'Local Pet',
      source: PetResourceSource.local,
      selected: true,
    );

    final decoded = PetResourceOption.fromJson(option.toJson());

    expect(decoded.id, 'local_pet');
    expect(decoded.label, 'Local Pet');
    expect(decoded.source, PetResourceSource.local);
    expect(decoded.selected, isTrue);
  });

  test('PetSettingsSnapshot JSON round trips', () {
    const snapshot = PetSettingsSnapshot(
      petId: 'default_pet',
      scale: 1.4,
      alwaysOnTop: false,
      resourceOptions: [
        PetResourceOption(
          id: 'default_pet',
          label: 'Default Pet (Default)',
          source: PetResourceSource.bundled,
          selected: true,
        ),
      ],
      runtimeMode: PetRuntimeMode.error,
      errorMessage: 'load failed',
    );

    final decoded = PetSettingsSnapshot.fromJson(snapshot.toJson());

    expect(decoded.petId, 'default_pet');
    expect(decoded.scale, 1.4);
    expect(decoded.alwaysOnTop, isFalse);
    expect(decoded.resourceOptions.single.source, PetResourceSource.bundled);
    expect(decoded.runtimeMode, PetRuntimeMode.error);
    expect(decoded.errorMessage, 'load failed');
  });

  test('AuxiliaryWindowArguments JSON string round trips', () {
    const snapshot = PetSettingsSnapshot(
      petId: 'default_pet',
      scale: 1,
      alwaysOnTop: true,
      resourceOptions: [],
      runtimeMode: PetRuntimeMode.idle,
    );
    const arguments = AuxiliaryWindowArguments.contextMenu(
      anchorGlobalPosition: Offset(20, 30),
      snapshot: snapshot,
    );

    final decoded = AuxiliaryWindowArguments.fromJsonString(
      arguments.toJsonString(),
    );

    expect(decoded.type, AuxiliaryWindowType.contextMenu);
    expect(decoded.anchorGlobalPosition, const Offset(20, 30));
    expect(decoded.snapshot?.petId, 'default_pet');
  });
}
