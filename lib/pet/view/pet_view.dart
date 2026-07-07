import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../desktop/auxiliary_window_controller.dart';
import '../../desktop/pet_window_service.dart';
import '../controller/pet_controller.dart';
import '../model/pet_settings_snapshot.dart';
import 'pet_actor.dart';
import 'pet_hit_area.dart';

class PetView extends StatefulWidget {
  const PetView({
    required this.windowController,
    required this.auxiliaryWindowController,
    super.key,
  });

  final PetWindowService windowController;
  final AuxiliaryWindowController auxiliaryWindowController;

  @override
  State<PetView> createState() => _PetViewState();
}

class _PetViewState extends State<PetView> {
  @override
  Widget build(BuildContext context) {
    return Consumer<PetController>(
      builder: (context, controller, child) {
        final state = controller.state;
        final resource = state.resource;

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: RepaintBoundary(
              child: SizedBox.square(
                dimension: 200,
                child: PetHitArea(
                  onPanStart: (_) {
                    widget.auxiliaryWindowController.closeContextMenu();
                    controller.startDragging();
                    widget.windowController.startDragging();
                  },
                  onPanEnd: (_) async {
                    final position =
                        await widget.windowController.getPosition() ??
                        controller.state.config.windowPosition ??
                        Offset.zero;
                    await controller.endDragging(position);
                  },
                  onSecondaryTapDown: (details) async {
                    await widget.auxiliaryWindowController.showContextMenu(
                      anchorGlobalPosition: details.globalPosition,
                      snapshot: PetSettingsSnapshot.fromState(state),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: resource == null
                        ? const SizedBox.shrink()
                        : Transform.scale(
                            scale: state.config.scale,
                            child: PetActor(
                              resource: resource,
                              animationState: state.animationState,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
