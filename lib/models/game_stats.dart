import 'package:minesweeper/ui/page/view_models/options_view_model.dart';

class GameStats {
  final int gamesPlayed;

  final Map<DifficultyLevel, int> wins;
  final Map<DifficultyLevel, int> losses;
  final Map<DifficultyLevel, int> streaks;
  final Map<DifficultyLevel, int> bestTimes;

  const GameStats({
    required this.gamesPlayed,
    required this.wins,
    required this.losses,
    required this.streaks,
    required this.bestTimes,
  });

  const GameStats.empty()
      : gamesPlayed = 0,
        wins = const {
          DifficultyLevel.easy: 0,
          DifficultyLevel.medium: 0,
          DifficultyLevel.hard: 0,
        },
        losses = const {
          DifficultyLevel.easy: 0,
          DifficultyLevel.medium: 0,
          DifficultyLevel.hard: 0,
        },
        streaks = const {
          DifficultyLevel.easy: 0,
          DifficultyLevel.medium: 0,
          DifficultyLevel.hard: 0,
        },
        bestTimes = const {
          DifficultyLevel.easy: 0,
          DifficultyLevel.medium: 0,
          DifficultyLevel.hard: 0,
        };
}
