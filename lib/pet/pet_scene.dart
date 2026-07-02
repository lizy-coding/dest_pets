import 'package:flutter/material.dart';

import '../desktop/desktop_window_controller.dart';
import 'pet_actor.dart';
import 'pet_hit_area.dart';

class PetScene extends StatelessWidget {
  const PetScene({required this.windowController, super.key});

  static const List<String> _idleFrames = [
    'assets/pets/default/idle_0.png',
    'assets/pets/default/idle_1.png',
    'assets/pets/default/idle_2.png',
    'assets/pets/default/idle_3.png',
  ];

  final DesktopWindowController windowController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: RepaintBoundary(
          child: SizedBox.square(
            dimension: 200,
            child: PetHitArea(
              windowController: windowController,
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: PetActor(idleFrames: _idleFrames),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
