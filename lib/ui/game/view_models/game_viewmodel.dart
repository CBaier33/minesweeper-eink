import 'dart:math';

import 'package:flutter/material.dart';
import 'package:minesweeper/ui/game/widgets/cell.dart';
import 'package:minesweeper/ui/page/view_models/options_view_model.dart';

class GameViewModel extends ChangeNotifier {
  GameViewModel({required this.options});

  final OptionsViewModel options;

  late List<List<CellItem>> boardState = generateBoard(options.difficulty);

  List<List<CellItem>> generateBoard(DifficultyLevel diff) {
    List<List<CellItem>> board = _buildDefaultBoard(diff);
    return _shuffleBoard(board, diff);
  }

  List<List<CellItem>> _buildDefaultBoard(DifficultyLevel diff) {

    var cols = diff.cols;
    var rows = diff.rows;

    List<List<CellItem>> board = List.generate(rows, (_) => List.generate(cols, (_) => CellItem(value: 0)));

    var mine = diff.mines;

    for (int i = 0; i < mine; i++) {
      var x = (i ~/ rows);
      var y = (i % cols);

      CellItem cell = board[x][y];

      cell.value = 9; 
    }

    return board;
  }

  // Shuffling using the Fisher-Yates algorithm
  List<List<CellItem>> _shuffleBoard(List<List<CellItem>> board, DifficultyLevel diff) {

    int cols = diff.cols;
    int rows = diff.rows;
    int gridSize = rows*cols;

    final random = Random();

    for (int i=gridSize-1; i > 0; i--) {
      int j = random.nextInt(i+1);

      var iX = (i ~/ rows);
      var iY = (i % cols);

      var jX = (j ~/ rows);
      var jY = (j % cols);

      int temp = board[iX][iY].value;
      board[iX][iY].value = board[jX][jY].value;
      board[jX][jY].value = temp;

    }

    return board;
    
  }

  

  CellItem getCell(CellPoint p) {
    return boardState[p.x][p.y];
  }

  void _setCell(CellPoint p, CellItem newCell) {

    boardState[p.x][p.y] = newCell;
  }

  // if cell content is positive int (closed) make it negative (opened (permenantly))
  void onTapCell(CellPoint p) {

    CellItem cell = getCell(p);
    cell.open = true;

    notifyListeners();
  }

  void onLongPressCell(CellPoint p) {

    CellItem cell = getCell(p);

    cell.flagType = _getNewFlagType(cell.flagType);

    _setCell(p, cell);

    notifyListeners();

  }

  FlagType _getNewFlagType(FlagType currFlag) {
    
    FlagType newFlag = switch (currFlag) {
      FlagType.empty => FlagType.flag,
      FlagType.flag => (options.questionMarks) ? FlagType.questionMark : FlagType.empty,
      FlagType.questionMark => FlagType.empty,
    };

    return newFlag;

  }

}

class CellItem {
  CellItem({required this.value});

  int value = 0;
  bool open = false;
  FlagType flagType = FlagType.empty;

}

enum FlagType {
  empty,
  flag,
  questionMark,
}
