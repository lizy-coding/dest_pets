import 'package:flutter/widgets.dart';

import '../pet/model/pet_menu_action.dart';
import '../pet/model/pet_settings_snapshot.dart';

typedef PetMenuActionHandler = Future<void> Function(PetMenuAction action);

abstract class AuxiliaryWindowController {
  Future<void> initializePetMenuActionHandler(
    PetMenuActionHandler handler,
  ) async {
    return;
  }

  Future<void> showContextMenu({
    required Offset anchorGlobalPosition,
    required PetSettingsSnapshot snapshot,
  });

  Future<void> closeContextMenu();

  void dispose() {}
}
