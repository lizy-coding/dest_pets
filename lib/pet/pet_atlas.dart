class PetAtlas {
  static const int columns = 8;
  static const int rows = 9;
  static const int cellWidth = 192;
  static const int cellHeight = 208;
  static const int width = columns * cellWidth;
  static const int height = rows * cellHeight;

  static const int idleRow = 0;
  static const List<Duration> idleFrameDurations = [
    Duration(milliseconds: 280),
    Duration(milliseconds: 110),
    Duration(milliseconds: 110),
    Duration(milliseconds: 140),
    Duration(milliseconds: 140),
    Duration(milliseconds: 320),
  ];

  const PetAtlas._();
}
