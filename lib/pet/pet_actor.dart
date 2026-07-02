import 'package:flutter/material.dart';

import 'pet_animation_controller.dart';

class PetActor extends StatefulWidget {
  const PetActor({required this.idleFrames, super.key});

  final List<String> idleFrames;

  @override
  State<PetActor> createState() => _PetActorState();
}

class _PetActorState extends State<PetActor>
    with SingleTickerProviderStateMixin {
  late PetAnimationController _animation;

  @override
  void initState() {
    super.initState();
    _animation = PetAnimationController(
      vsync: this,
      frameCount: widget.idleFrames.length,
    )..startIdleLoop();
  }

  @override
  void didUpdateWidget(PetActor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.idleFrames.length != widget.idleFrames.length) {
      _animation.dispose();
      _animation = PetAnimationController(
        vsync: this,
        frameCount: widget.idleFrames.length,
      )..startIdleLoop();
    }
  }

  @override
  void dispose() {
    _animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation.listenable,
      builder: (context, child) {
        final frameAsset = widget.idleFrames[_animation.currentFrame];

        return Image.asset(
          frameAsset,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.medium,
          gaplessPlayback: true,
          isAntiAlias: true,
        );
      },
    );
  }
}
