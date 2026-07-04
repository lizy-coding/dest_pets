import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../resources/model/pet_animation_manifest.dart';
import '../../resources/model/pet_resource.dart';
import '../animation/pet_animation_controller.dart';
import '../model/pet_animation_state.dart';

class PetActor extends StatefulWidget {
  const PetActor({
    required this.resource,
    required this.animationState,
    super.key,
  });

  final PetResource resource;
  final PetAnimationState animationState;

  @override
  State<PetActor> createState() => _PetActorState();
}

class _PetActorState extends State<PetActor> {
  late PetAnimationController _animation;

  @override
  void initState() {
    super.initState();
    _animation = _createAnimation()..startLoop();
  }

  @override
  void didUpdateWidget(PetActor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.resource.id != widget.resource.id ||
        oldWidget.animationState.animationId !=
            widget.animationState.animationId) {
      _animation.dispose();
      _animation = _createAnimation()..startLoop();
    }
  }

  @override
  void dispose() {
    _animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final animation = _animationManifest();

    return AnimatedBuilder(
      animation: _animation.listenable,
      builder: (context, child) {
        final frameSlot = widget.animationState.isPlaying
            ? _animation.currentFrame
            : widget.animationState.frameIndex;
        final frameIndex = frameSlot.clamp(0, animation.frames.length - 1);

        return _PetAtlasFrame(
          resource: widget.resource,
          row: animation.row,
          column: animation.frames[frameIndex],
        );
      },
    );
  }

  PetAnimationController _createAnimation() {
    return PetAnimationController(
      frameDurations: _animationManifest().frameDurations,
    );
  }

  PetAnimationManifest _animationManifest() {
    return widget.resource.manifest.animations[widget
            .animationState
            .animationId] ??
        widget.resource.manifest.animations[PetAnimationState.idleAnimationId]!;
  }
}

class _PetAtlasFrame extends StatefulWidget {
  const _PetAtlasFrame({
    required this.resource,
    required this.row,
    required this.column,
  });

  final PetResource resource;
  final int row;
  final int column;

  @override
  State<_PetAtlasFrame> createState() => _PetAtlasFrameState();
}

class _PetAtlasFrameState extends State<_PetAtlasFrame> {
  ImageInfo? _atlasInfo;
  ImageStream? _imageStream;
  ImageStreamListener? _imageStreamListener;
  String? _resolvedResourceKey;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolveAtlasIfNeeded();
  }

  @override
  void didUpdateWidget(_PetAtlasFrame oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_resourceKey(oldWidget.resource) != _resourceKey(widget.resource)) {
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
    final atlas = widget.resource.manifest.atlas;

    return FittedBox(
      fit: BoxFit.contain,
      child: SizedBox(
        width: atlas.frameWidth.toDouble(),
        height: atlas.frameHeight.toDouble(),
        child: _atlasInfo == null
            ? const SizedBox.shrink()
            : CustomPaint(
                painter: _PetAtlasPainter(
                  atlas: _atlasInfo!.image,
                  frameWidth: atlas.frameWidth,
                  frameHeight: atlas.frameHeight,
                  row: widget.row,
                  column: widget.column,
                ),
              ),
      ),
    );
  }

  void _resolveAtlasIfNeeded({bool force = false}) {
    final resourceKey = _resourceKey(widget.resource);
    if (!force && _resolvedResourceKey == resourceKey && _atlasInfo != null) {
      return;
    }

    _resolvedResourceKey = resourceKey;
    _removeImageListener();
    final imageStream = _imageProviderFor(
      widget.resource,
    ).resolve(createLocalImageConfiguration(context));
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

  ImageProvider<Object> _imageProviderFor(PetResource resource) {
    if (resource.source == PetResourceSource.bundled) {
      return AssetImage(resource.resolvedSpritesheetPath);
    }

    return FileImage(File(resource.resolvedSpritesheetPath));
  }

  String _resourceKey(PetResource resource) {
    return '${resource.source.name}:${resource.resolvedSpritesheetPath}';
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
    required this.frameWidth,
    required this.frameHeight,
    required this.row,
    required this.column,
  });

  final ui.Image atlas;
  final int frameWidth;
  final int frameHeight;
  final int row;
  final int column;

  @override
  void paint(Canvas canvas, Size size) {
    final source = Rect.fromLTWH(
      column * frameWidth.toDouble(),
      row * frameHeight.toDouble(),
      frameWidth.toDouble(),
      frameHeight.toDouble(),
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
        oldDelegate.frameWidth != frameWidth ||
        oldDelegate.frameHeight != frameHeight ||
        oldDelegate.row != row ||
        oldDelegate.column != column;
  }
}
