import 'dart:convert';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:screen_retriever/screen_retriever.dart';

import '../pet/model/pet_menu_action.dart';
import '../pet/model/pet_settings_snapshot.dart';
import 'auxiliary_window_arguments.dart';
import 'auxiliary_window_controller.dart';
import 'platform_capabilities.dart';

typedef CursorScreenPointProvider = Future<Offset> Function();
typedef AuxiliaryWindowOpener =
    Future<void> Function(AuxiliaryWindowArguments arguments);
typedef ContextMenuCloser = Future<void> Function();

class DesktopAuxiliaryWindowController implements AuxiliaryWindowController {
  DesktopAuxiliaryWindowController({
    @visibleForTesting CursorScreenPointProvider? cursorScreenPointProvider,
    @visibleForTesting AuxiliaryWindowOpener? auxiliaryWindowOpener,
    @visibleForTesting ContextMenuCloser? contextMenuCloser,
    @visibleForTesting bool? supportsAuxiliaryWindowsOverride,
    PlatformCapabilities? capabilities,
  }) : _cursorScreenPointProvider =
           cursorScreenPointProvider ?? screenRetriever.getCursorScreenPoint,
       _auxiliaryWindowOpener = auxiliaryWindowOpener ?? _openAuxiliaryWindow,
       _contextMenuCloser = contextMenuCloser ?? _closeContextMenuWindows,
       _supportsAuxiliaryWindowsOverride = supportsAuxiliaryWindowsOverride,
       _capabilities = capabilities ?? PlatformCapabilities.current();

  static const String petMenuActionChannelName = 'desktop_pet/pet_menu_actions';

  final WindowMethodChannel _petMenuActionChannel = const WindowMethodChannel(
    petMenuActionChannelName,
    mode: ChannelMode.unidirectional,
  );

  final CursorScreenPointProvider _cursorScreenPointProvider;
  final AuxiliaryWindowOpener _auxiliaryWindowOpener;
  final ContextMenuCloser _contextMenuCloser;
  final bool? _supportsAuxiliaryWindowsOverride;
  final PlatformCapabilities _capabilities;
  PetMenuActionHandler? _petMenuActionHandler;
  bool _actionChannelInitialized = false;

  bool get supportsAuxiliaryWindows =>
      _supportsAuxiliaryWindowsOverride ??
      _capabilities.supportsAuxiliaryWindows;

  @override
  Future<void> initializePetMenuActionHandler(
    PetMenuActionHandler handler,
  ) async {
    _petMenuActionHandler = handler;
    if (_actionChannelInitialized || !supportsAuxiliaryWindows) {
      return;
    }

    await _petMenuActionChannel.setMethodCallHandler((call) async {
      if (call.method != 'petMenuAction') {
        throw MissingPluginException('Unknown method ${call.method}');
      }

      final action = PetMenuAction.fromJson(
        Map<String, dynamic>.from(call.arguments as Map),
      );
      await _petMenuActionHandler?.call(action);
      await closeContextMenu();
      return null;
    });
    _actionChannelInitialized = true;
  }

  @override
  Future<void> showContextMenu({
    required Offset anchorGlobalPosition,
    required PetSettingsSnapshot snapshot,
  }) async {
    if (!supportsAuxiliaryWindows) {
      return;
    }

    await closeContextMenu();
    final cursorScreenPoint = await _cursorScreenPointProvider();
    final arguments = AuxiliaryWindowArguments.contextMenu(
      anchorGlobalPosition: cursorScreenPoint,
      snapshot: snapshot,
    );

    await _auxiliaryWindowOpener(arguments);
  }

  @override
  Future<void> closeContextMenu() async {
    if (!supportsAuxiliaryWindows) {
      return;
    }

    await _contextMenuCloser();
  }

  @override
  void dispose() {
    if (_actionChannelInitialized) {
      _petMenuActionChannel.setMethodCallHandler(null);
    }
    _actionChannelInitialized = false;
    _petMenuActionHandler = null;
  }
}

Future<void> _openAuxiliaryWindow(AuxiliaryWindowArguments arguments) async {
  final controller = await WindowController.create(
    WindowConfiguration(
      hiddenAtLaunch: true,
      arguments: arguments.toJsonString(),
    ),
  );
  await controller.show();
}

Future<void> _closeContextMenuWindows() async {
  for (final controller in await WindowController.getAll()) {
    final type = _typeFromWindowArguments(controller.arguments);
    if (type == AuxiliaryWindowType.contextMenu) {
      await controller.invokeMethod<void>('window_close');
    }
  }
}

AuxiliaryWindowType? _typeFromWindowArguments(String arguments) {
  if (arguments.isEmpty) {
    return null;
  }

  try {
    final json = jsonDecode(arguments) as Map<String, dynamic>;
    final type = json['type'];
    if (type is! String) {
      return null;
    }
    for (final value in AuxiliaryWindowType.values) {
      if (value.name == type) {
        return value;
      }
    }
  } on FormatException {
    return null;
  }

  return null;
}
