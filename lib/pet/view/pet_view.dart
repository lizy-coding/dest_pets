import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../desktop/desktop_window_controller.dart';
import '../controller/pet_appearance_controller.dart';
import '../pet_actor.dart';
import '../pet_hit_area.dart';

class PetView extends StatelessWidget {
  const PetView({required this.windowController, super.key});

  final DesktopWindowController windowController;

  @override
  Widget build(BuildContext context) {
    return Consumer<PetAppearanceController>(
      builder: (context, controller, child) {
        final state = controller.state;
        final selectedResource = state.selectedResource;

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: RepaintBoundary(
              child: SizedBox.square(
                dimension: 200,
                child: PetHitArea(
                  windowController: windowController,
                  onSecondaryTapDown: (details) {
                    _showPetMenu(context, details);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: selectedResource == null
                        ? const SizedBox.shrink()
                        : Transform.scale(
                            scale: state.scale,
                            child: PetActor(pet: selectedResource),
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
    final controller = context.read<PetAppearanceController>();
    final resources = controller.state.availableResources;
    if (resources.isEmpty) {
      return;
    }

    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final selectedResourceId = await showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromPoints(details.globalPosition, details.globalPosition),
        Offset.zero & overlay.size,
      ),
      items: [
        for (final resource in resources)
          CheckedPopupMenuItem<String>(
            value: resource.resourceId,
            checked: resource.resourceId == controller.state.currentResourceId,
            child: Text(resource.menuLabel),
          ),
      ],
    );

    if (!context.mounted || selectedResourceId == null) {
      return;
    }

    await context.read<PetAppearanceController>().apply(
      resourceId: selectedResourceId,
    );
  }
}
