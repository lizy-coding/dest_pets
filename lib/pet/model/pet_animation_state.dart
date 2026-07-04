class PetAnimationState {
  const PetAnimationState({
    this.animationId = idleAnimationId,
    this.frameIndex = 0,
    this.isPlaying = true,
  });

  static const String idleAnimationId = 'idle';

  final String animationId;
  final int frameIndex;
  final bool isPlaying;

  PetAnimationState copyWith({
    String? animationId,
    int? frameIndex,
    bool? isPlaying,
  }) {
    return PetAnimationState(
      animationId: animationId ?? this.animationId,
      frameIndex: frameIndex ?? this.frameIndex,
      isPlaying: isPlaying ?? this.isPlaying,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is PetAnimationState &&
        other.animationId == animationId &&
        other.frameIndex == frameIndex &&
        other.isPlaying == isPlaying;
  }

  @override
  int get hashCode {
    return Object.hash(animationId, frameIndex, isPlaying);
  }
}
