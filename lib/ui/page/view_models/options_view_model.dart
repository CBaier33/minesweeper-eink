import 'package:flutter/material.dart';

class OptionsViewModel extends ChangeNotifier {
  OptionsViewModel();

  DifficultyLevel difficulty = DifficultyLevel.easy;
  bool questionMarks = true;

  void setDifficulty(DifficultyLevel diff) {
    difficulty = diff;
    notifyListeners();
  }

  OptionsViewModel.clone(OptionsViewModel other) {
    difficulty = other.difficulty;
    questionMarks = other.questionMarks;
  }
  
}

enum DifficultyLevel {
  easy(cols: 9, rows: 9, mines: 10),
  medium(cols: 16, rows: 16, mines: 40),
  hard(cols: 16, rows: 30, mines: 99);

  const DifficultyLevel({
    required this.cols,
    required this.rows,
    required this.mines,
  });

  final int cols;
  final int rows;
  final int mines;
}
