import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:minesweeper/models/saved_game.dart';
import 'package:minesweeper/services/save_service.dart';
import 'package:minesweeper/services/stats_service.dart';
import 'package:minesweeper/ui/game/widgets/cell.dart';
import 'package:minesweeper/ui/page/view_models/options_view_model.dart';

class GameViewModel extends ChangeNotifier {
  GameViewModel({required this.options}) {
    _generateBoard();
  }

  /// Picks up a game stored by [SaveService] rather than dealing a new board.
  ///
  /// Resuming claims the slot: the stored copy only survives if the player
  /// saves again on the way out.
  GameViewModel.resume({required this.options, required SavedGame save}) {
    boardState = save.board;
    time = save.time;
    _slotHoldsThisGame = true;
    _countFlags();
  }

  final OptionsViewModel options;
  final StatsService _stats = StatsService();
  final SaveService _saves = SaveService();

  int gameState = 0;
  late BoardState boardState;

  // True while the stored slot holds *this* game, still in progress. Any way
  // out other than saving again has to clear it, or a game the player already
  // finished or walked away from stays offered in the menu. A game started
  // fresh never sets this, so it can't delete someone else's save.
  bool _slotHoldsThisGame = false;

  late int mineCount = options.difficulty.mines;
  bool cellPressedDown = false;

  Timer? _timer;
  int time = 0;
  bool _running = false;
  bool _paused = false;
  bool _disposed = false;

  bool menuOpen = false;

  void openMenu() {
    pauseTimer();
    menuOpen = true;
    notifyListeners();
  }

  void _checkGame() {
    _countFlags();

    int opened = 0;

    // Check for open mines (Lose Case)
    for (final row in boardState) {
      for (final cell in row) {
        if (cell.open) {
          if (cell.value == 9) {
            _endGame(1);
            return;
          }
          opened++;
        }
      }
    }

    int gridSize = options.difficulty.rows * options.difficulty.cols;
    int totalMines = options.difficulty.mines;

    // Win Case
    if (opened == (gridSize - totalMines)) {
      _endGame(2);
      return;
    }
  }

  void _endGame(int result) {
    pauseTimer();
    gameState = result;
    bool win = (result == 2);
    _stats.recordGame(time, options.difficulty, win);

    // Won or lost, there is nothing left to come back to.
    unawaited(discardSave());

    if (!win) _openAllMines();

    notifyListeners();
  }

  /// Parks the game in its difficulty's slot so it can be resumed later.
  Future<void> saveGame() async {
    pauseTimer();

    await _saves.save(
      SavedGame(
        difficulty: options.difficulty,
        board: boardState,
        time: time,
        questionMarks: options.questionMarks,
      ),
    );

    // The stored copy is now a deliberate snapshot, not this live game.
    _slotHoldsThisGame = false;
  }

  /// Clears the slot unless the player saved on the way out. Safe to call on
  /// any exit path, including twice.
  Future<void> discardSave() async {
    if (!_slotHoldsThisGame) return;

    _slotHoldsThisGame = false;
    await _saves.delete(options.difficulty);
  }

  void _openAllMines() {
    for (final row in boardState) {
      for (final cell in row) {
        if (cell.value == 9) {
          cell.open = true;
        }
      }
    }
  }

  //
  // BOARD ACTIONS
  //

  void _generateBoard() {
    boardState = _buildDefaultBoard();
    _shuffleBoard();
    _enrichBoard();
  }

  void printBoard() {
    for (final row in boardState) {
      print(
        row
            .map((cell) => cell.value == 9 ? 'MINE' : cell.value.toString())
            .join(' '),
      );
    }
  }

  // resets the board without resetting the current options
  void resetGame() {
    // Reset Board
    _generateBoard();

    // Reset Mine Counter
    mineCount = options.difficulty.mines;

    // reset game state (and smiley!)
    gameState = 0;

    // Reset Timer
    resetTimer();

    notifyListeners();
  }

  BoardState _buildDefaultBoard() {
    var cols = options.difficulty.cols;
    var rows = options.difficulty.rows;

    BoardState board = List.generate(
      rows,
      (_) => List.generate(cols, (_) => CellItem(value: 0)),
    );

    var mine = options.difficulty.mines;

    for (int i = 0; i < mine; i++) {
      var x = (i ~/ cols);
      var y = (i % cols);
      board[x][y].value = 9;
    }

    return board;
  }

  // Shuffling using the Fisher-Yates algorithm
  void _shuffleBoard() {
    int cols = options.difficulty.cols;
    int rows = options.difficulty.rows;
    int gridSize = rows * cols;

    final random = Random();

    for (int i = gridSize - 1; i > 0; i--) {
      int j = random.nextInt(i);

      var iX = (i ~/ cols);
      var iY = (i % cols);

      var jX = (j ~/ cols);
      var jY = (j % cols);

      int temp = boardState[iX][iY].value;
      boardState[iX][iY].value = boardState[jX][jY].value;
      boardState[jX][jY].value = temp;
    }
  }

  void _enrichBoard() {
    final cols = options.difficulty.cols;
    final rows = options.difficulty.rows;

    for (int i = 0; i < rows * cols; i++) {
      final x = i ~/ cols;
      final y = i % cols;

      if (boardState[x][y].value == 9) {
        _incrementNeighbors(x, y);
      }
    }
  }

  void _incrementNeighbors(int x, int y) {
    for (int dx = -1; dx <= 1; dx++) {
      for (int dy = -1; dy <= 1; dy++) {
        if (dx == 0 && dy == 0) continue;

        final nx = x + dx;
        final ny = y + dy;

        if (_inBounds(nx, ny) && getCell(CellPoint(x: nx, y: ny)).value != 9) {
          boardState[nx][ny].value += 1;
        }
      }
    }
  }

  //
  // CELL ACTIONS
  //

  bool _inBounds(int x, int y) {
    final cols = options.difficulty.cols;
    final rows = options.difficulty.rows;

    return x >= 0 && x < rows && y >= 0 && y < cols;
  }

  CellItem getCell(CellPoint p) {
    return boardState[p.x][p.y];
  }

  void _setCell(CellPoint p, CellItem newCell) {
    boardState[p.x][p.y] = newCell;
  }

  void setCellPressed(bool p) {
    cellPressedDown = p;
    notifyListeners();
  }

  void onTapCell(CellPoint p) {
    if (gameState != 0) {
      return;
    }

    startTimer();

    CellItem cell = getCell(p);

    switch (cell.flagType) {
      case FlagType.flag:
        cell.flagType = FlagType.questionMark;
        return;
      case FlagType.questionMark:
        cell.flagType = FlagType.flag;
        return;
      case FlagType.empty:
      // continue
    }

    _openCell(p);

    _checkGame();

    if (cell.value == 0 || cell.value == 9 && gameState == 0) {
      _openCellys(p);
    }
  }

  void _openCellys(CellPoint c) {
    for (int dx = -1; dx <= 1; dx++) {
      for (int dy = -1; dy <= 1; dy++) {
        if (dx == 0 && dy == 0) continue;

        final nx = c.x + dx;
        final ny = c.y + dy;

        if (!_inBounds(nx, ny)) continue;

        CellPoint neighbor = CellPoint(x: nx, y: ny);
        CellItem nCell = getCell(neighbor);

        if (!nCell.open && nCell.value != 9) {
          _openCell(neighbor);

          if (nCell.value == 0) {
            _openCellys(neighbor);
          }
        }
      }
    }
  }

  void _openCell(CellPoint c) {
    CellItem cell = getCell(c);

    cell.open = true;
    cell.flagType = FlagType.empty;

    _setCell(c, cell);

    notifyListeners();
  }

  void onLongPressCell(CellPoint p) {
    if (gameState != 0) {
      return;
    }

    CellItem cell = getCell(p);

    if (cell.open) {
      return;
    }

    cell.flagType = (cell.flagType == FlagType.empty)
        ? FlagType.flag
        : FlagType.empty;

    _setCell(p, cell);

    _checkGame();

    notifyListeners();
  }

  void _countFlags() {
    int mc = 0;
    for (final row in boardState) {
      for (final cell in row) {
        if (cell.flagType == FlagType.flag) mc++;
      }
    }

    // flags indicate how many potential mines remain
    mineCount = options.difficulty.mines - mc;
  }

  String getCurrentSmiley() {
    String smileType = 'normal';

    switch (gameState) {
      case 0:
        smileType = (cellPressedDown) ? 'engaged' : smileType;
      case 1:
        smileType = 'lose';
      case 2:
        smileType = 'win';
    }

    return "assets/$smileType-smile.png";
  }

  //
  // TIMER
  //

  void startTimer() {
    if (_running) return;

    _running = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_paused) return;
      time++;
      notifyListeners();
    });
  }

  void pauseTimer() {
    _paused = true;
    notifyListeners();
  }

  void resumeTimer() {
    _paused = false;
  }

  void stopTimer() {
    _timer?.cancel();
    _timer = null;
    _running = false;
    notifyListeners();
  }

  void resetTimer() {
    stopTimer();
    time = 0;
    _running = false;
    _paused = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }

  // Leaving the screen can outrun a pending callback (the delayed cell
  // release, most easily), so swallow notifications once we're gone.
  @override
  void notifyListeners() {
    if (_disposed) return;
    super.notifyListeners();
  }
}

typedef BoardState = List<List<CellItem>>;

class CellItem {
  CellItem({required this.value});

  int value = 0;
  bool open = false;
  FlagType flagType = FlagType.empty;
}

enum FlagType { empty, flag, questionMark }
