import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'pet_atlas.dart';
import 'pet_animation_controller.dart';
import 'model/pet_resource.dart';

class PetActor extends StatefulWidget {
  const PetActor({required this.pet, super.key});

  final PetResource pet;

  @override
  State<PetActor> createState() => _PetActorState();
}

class _PetActorState extends State<PetActor> {
  late PetAnimationController _animation;

  @override
  void initState() {
    super.initState();
    _animation = _createAnimation();
  }

  @override
  void didUpdateWidget(PetActor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pet.resourceId != widget.pet.resourceId) {
      _animation.dispose();
      _animation = _createAnimation();
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
        return _PetAtlasFrame(
          pet: widget.pet,
          row: PetAtlas.idleRow,
          column: _animation.currentFrame,
        );
      },
    );
  }

  PetAnimationController _createAnimation() {
    return PetAnimationController(frameDurations: PetAtlas.idleFrameDurations)
      ..startIdleLoop();
  }
}

class _PetAtlasFrame extends StatefulWidget {
  const _PetAtlasFrame({
    required this.pet,
    required this.row,
    required this.column,
  });

  final PetResource pet;
  final int row;
  final int column;

  @override
  State<_PetAtlasFrame> createState() => _PetAtlasFrameState();
}

class _PetAtlasFrameState extends State<_PetAtlasFrame> {
  ImageInfo? _atlasInfo;
  ImageStream? _imageStream;
  ImageStreamListener? _imageStreamListener;
  String? _resolvedPetKey;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolveAtlasIfNeeded();
  }

  @override
  void didUpdateWidget(_PetAtlasFrame oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_petKey(oldWidget.pet) != _petKey(widget.pet)) {
      _resolveAtlasIfNeeded(force: true);
    }
  }

  @override
  void dispose() {
    _removeImageListener();
    _atlasInfo?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.contain,
      child: SizedBox(
        width: PetAtlas.cellWidth.toDouble(),
        height: PetAtlas.cellHeight.toDouble(),
        child: _atlasInfo == null
            ? const SizedBox.shrink()
            : CustomPaint(
                painter: _PetAtlasPainter(
                  atlas: _atlasInfo!.image,
                  row: widget.row,
                  column: widget.column,
                ),
              ),
      ),
    );
  }

  void _resolveAtlasIfNeeded({bool force = false}) {
    final petKey = _petKey(widget.pet);
    if (!force && _resolvedPetKey == petKey && _atlasInfo != null) {
      return;
    }

    _resolvedPetKey = petKey;
    _removeImageListener();
    final imageProvider = _imageProviderFor(widget.pet);
    final imageStream = imageProvider.resolve(
      createLocalImageConfiguration(context),
    );
    final listener = ImageStreamListener(
      (imageInfo, synchronousCall) {
        if (!mounted) {
          imageInfo.dispose();
          return;
        }

        setState(() {
          final previousInfo = _atlasInfo;
          _atlasInfo = imageInfo;
          previousInfo?.dispose();
        });
      },
      onError: (exception, stackTrace) {
        if (!mounted) {
          return;
        }

        setState(() {
          _atlasInfo?.dispose();
          _atlasInfo = null;
        });
      },
    );

    _imageStream = imageStream;
    _imageStreamListener = listener;
    imageStream.addListener(listener);
  }

  ImageProvider<Object> _imageProviderFor(PetResource pet) {
    if (pet.source == PetResourceSource.bundled) {
      return AssetImage(pet.resolvedSpritesheetPath);
    }

    return FileImage(File(pet.resolvedSpritesheetPath));
  }

  String _petKey(PetResource pet) {
    return '${pet.source.name}:${pet.resolvedSpritesheetPath}';
  }

  void _removeImageListener() {
    final listener = _imageStreamListener;
    if (listener != null) {
      _imageStream?.removeListener(listener);
    }

    _imageStream = null;
    _imageStreamListener = null;
  }
}

class _PetAtlasPainter extends CustomPainter {
  const _PetAtlasPainter({
    required this.atlas,
    required this.row,
    required this.column,
  });

  final ui.Image atlas;
  final int row;
  final int column;

  @override
  void paint(Canvas canvas, Size size) {
    final source = Rect.fromLTWH(
      column * PetAtlas.cellWidth.toDouble(),
      row * PetAtlas.cellHeight.toDouble(),
      PetAtlas.cellWidth.toDouble(),
      PetAtlas.cellHeight.toDouble(),
    );
    final destination = Offset.zero & size;
    final paint = Paint()
      ..filterQuality = FilterQuality.medium
      ..isAntiAlias = true;

    canvas.drawImageRect(atlas, source, destination, paint);
  }

  @override
  bool shouldRepaint(covariant _PetAtlasPainter oldDelegate) {
    return oldDelegate.atlas != atlas ||
        oldDelegate.row != row ||
        oldDelegate.column != column;
  }
}
