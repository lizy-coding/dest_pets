import 'package:flutter/material.dart';

import '../desktop/desktop_window_controller.dart';
import '../pet/pet_scene.dart';

class PetApp extends StatelessWidget {
  const PetApp({required this.windowController, super.key});

  final DesktopWindowController windowController;

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
      builder: (context, child) {
        return ColoredBox(
          color: Colors.transparent,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: PetScene(windowController: windowController),
    );
  }
}
