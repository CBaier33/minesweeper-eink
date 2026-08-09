import 'package:minesweeper/ui/game/view_models/game_viewmodel.dart';
import 'package:minesweeper/ui/page/view_models/options_view_model.dart';

/// A game paused mid-play, restorable by [GameViewModel.resume].
///
/// One save is kept per difficulty, so [difficulty] doubles as the slot id.
class SavedGame {
  const SavedGame({
    required this.difficulty,
    required this.board,
    required this.time,
    required this.questionMarks,
  });

  final DifficultyLevel difficulty;
  final BoardState board;
  final int time;
  final bool questionMarks;

  Map<String, dynamic> toJson() => {
    'difficulty': difficulty.name,
    'time': time,
    'questionMarks': questionMarks,
    'cells': [
      for (final row in board)
        for (final cell in row) _encodeCell(cell),
    ],
  };

  /// Throws if the stored shape no longer matches its difficulty; callers
  /// treat that as "no save".
  factory SavedGame.fromJson(Map<String, dynamic> json) {
    final difficulty = DifficultyLevel.values.byName(
      json['difficulty'] as String,
    );
    final cells = (json['cells'] as List).cast<int>();

    final rows = difficulty.rows;
    final cols = difficulty.cols;

    if (cells.length != rows * cols) {
      throw FormatException(
        'expected ${rows * cols} cells for ${difficulty.name}, got ${cells.length}',
      );
    }

    return SavedGame(
      difficulty: difficulty,
      board: List.generate(
        rows,
        (x) => List.generate(cols, (y) => _decodeCell(cells[x * cols + y])),
      ),
      time: json['time'] as int,
      questionMarks: json['questionMarks'] as bool,
    );
  }
}

// A cell packs into one int: value in bits 0-3, open in bit 4, flag in 5-6.
int _encodeCell(CellItem cell) =>
    cell.value | (cell.open ? 1 << 4 : 0) | (cell.flagType.index << 5);

CellItem _decodeCell(int code) {
  return CellItem(value: code & 0xF)
    ..open = (code & 0x10) != 0
    ..flagType = FlagType.values[(code >> 5) & 0x3];
}
