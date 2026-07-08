import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:minesweeper/services/stats_service.dart';
import 'package:minesweeper/ui/game/widgets/cell.dart';
import 'package:minesweeper/ui/page/view_models/options_view_model.dart';

class GameViewModel extends ChangeNotifier {
  GameViewModel({required this.options}) {
    _generateBoard();
  }

  final OptionsViewModel options;
  final StatsService _stats = StatsService();

  int gameState = 0;
  late BoardState boardState;

  late int mineCount = options.difficulty.mines;
  bool cellPressedDown = false;

  Timer? _timer;
  int time = 0;
  bool _running = false;
  bool _paused = false;

  bool menuOpen = false;

  void openMenu() {
    pauseTimer();
    menuOpen = true;
    notifyListeners();
  }

  void _checkGame() {
    _checkFlags();

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

    if (!win) _openAllMines();

    notifyListeners();
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

    cell.flagType = (cell.flagType == FlagType.empty) ? FlagType.flag : FlagType.empty;

    _setCell(p, cell);

    _checkGame();

    notifyListeners();
  }

  void _checkFlags() {
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

    return "assets/$smileType-smile.svg";
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
}

typedef BoardState = List<List<CellItem>>;

class CellItem {
  CellItem({required this.value});

  int value = 0;
  bool open = false;
  FlagType flagType = FlagType.empty;
}

enum FlagType { empty, flag, questionMark }
