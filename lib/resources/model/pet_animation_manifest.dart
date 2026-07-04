class PetAnimationManifest {
  const PetAnimationManifest({
    required this.row,
    required this.frames,
    required this.durationsMs,
    required this.loop,
  });

  final int row;
  final List<int> frames;
  final List<int> durationsMs;
  final bool loop;

  List<Duration> get frameDurations {
    return [
      for (final durationMs in durationsMs) Duration(milliseconds: durationMs),
    ];
  }

  static PetAnimationManifest? fromJson(
    Map<String, Object?> json, {
    required int atlasRows,
    required int atlasColumns,
  }) {
    final row = json['row'];
    final frames = json['frames'];
    final durationsMs = json['durationsMs'];
    final loop = json['loop'];

    if (row is! int ||
        frames is! List ||
        durationsMs is! List ||
        loop is! bool ||
        row < 0 ||
        row >= atlasRows ||
        frames.isEmpty ||
        frames.length != durationsMs.length) {
      return null;
    }

    final normalizedFrames = <int>[];
    for (final frame in frames) {
      if (frame is! int || frame < 0 || frame >= atlasColumns) {
        return null;
      }
      normalizedFrames.add(frame);
    }

    final normalizedDurations = <int>[];
    for (final durationMs in durationsMs) {
      if (durationMs is! int || durationMs <= 0) {
        return null;
      }
      normalizedDurations.add(durationMs);
    }

    return PetAnimationManifest(
      row: row,
      frames: List.unmodifiable(normalizedFrames),
      durationsMs: List.unmodifiable(normalizedDurations),
      loop: loop,
    );
  }
}
