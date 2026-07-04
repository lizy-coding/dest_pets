import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../desktop/desktop_window_controller.dart';
import '../controller/pet_controller.dart';
import 'pet_actor.dart';
import 'pet_hit_area.dart';

class PetView extends StatelessWidget {
  const PetView({required this.windowController, super.key});

  final DesktopWindowController windowController;

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
                    controller.startDragging();
                    windowController.startDragging();
                  },
                  onPanEnd: (_) async {
                    final position =
                        await windowController.getPosition() ??
                        controller.state.config.windowPosition ??
                        Offset.zero;
                    await controller.endDragging(position);
                  },
                  onSecondaryTapDown: (details) {
                    _showPetMenu(context, details);
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

  Future<void> _showPetMenu(
    BuildContext context,
    TapDownDetails details,
  ) async {
    final controller = context.read<PetController>();
    final resources = controller.state.availableResources;
    if (resources.isEmpty) {
      return;
    }

    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final selectedAction = await showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromPoints(details.globalPosition, details.globalPosition),
        Offset.zero & overlay.size,
      ),
      items: [
        for (final resource in resources)
          CheckedPopupMenuItem<String>(
            value: 'pet:${resource.id}',
            checked: resource.id == controller.state.config.petId,
            child: Text(resource.menuLabel),
          ),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(
          value: 'scale:increase',
          child: Text('Increase size'),
        ),
        const PopupMenuItem<String>(
          value: 'scale:decrease',
          child: Text('Decrease size'),
        ),
        const PopupMenuItem<String>(
          value: 'scale:reset',
          child: Text('Reset size'),
        ),
      ],
    );

    if (!context.mounted || selectedAction == null) {
      return;
    }

    final petController = context.read<PetController>();
    if (selectedAction.startsWith('pet:')) {
      await petController.switchPet(selectedAction.substring(4));
    } else if (selectedAction == 'scale:increase') {
      await petController.increaseScale();
    } else if (selectedAction == 'scale:decrease') {
      await petController.decreaseScale();
    } else if (selectedAction == 'scale:reset') {
      await petController.resetScale();
    }
  }
}
