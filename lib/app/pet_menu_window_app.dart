import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import '../desktop/desktop_auxiliary_window_controller.dart';
import '../pet/model/pet_menu_action.dart';
import '../pet/model/pet_settings_snapshot.dart';
import '../pet/view/pet_context_menu.dart';

class PetMenuWindowApp extends StatefulWidget {
  const PetMenuWindowApp({required this.snapshot, super.key});

  final PetSettingsSnapshot snapshot;

  @override
  State<PetMenuWindowApp> createState() => _PetMenuWindowAppState();
}

class _PetMenuWindowAppState extends State<PetMenuWindowApp>
    with WindowListener {
  static const WindowMethodChannel _petMenuActionChannel = WindowMethodChannel(
    DesktopAuxiliaryWindowController.petMenuActionChannelName,
    mode: ChannelMode.unidirectional,
  );

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      color: Colors.transparent,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.transparent,
        canvasColor: Colors.transparent,
      ),
      home: Scaffold(
        backgroundColor: Colors.transparent,
        body: Align(
          alignment: Alignment.topLeft,
          child: PetContextMenu(
            snapshot: widget.snapshot,
            onAction: _sendAction,
          ),
        ),
      ),
    );
  }

  Future<void> _sendAction(PetMenuAction action) async {
    if (!action.enabled) {
      return;
    }

    await _petMenuActionChannel.invokeMethod<void>(
      'petMenuAction',
      action.toJson(),
    );
  }

  @override
  void onWindowBlur() {
    windowManager.close();
  }
}
