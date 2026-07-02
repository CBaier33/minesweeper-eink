import 'package:flutter/material.dart';
import 'package:minesweeper/ui/core/widgets/difficulty_button.dart';
import 'package:provider/provider.dart';
import 'package:minesweeper/ui/page/view_models/options_view_model.dart';

class DifficultySelector extends StatelessWidget {
  const DifficultySelector({super.key});

  @override
  Widget build(BuildContext context) {
    final currentOptions = Provider.of<OptionsViewModel>(context);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        difficultyButton(
          context,
          difficulty: "Easy",
          size: "9×9",
          value: DifficultyLevel.easy,
          selected: currentOptions.difficulty,
          onSelected: (v) => currentOptions.setDifficulty(v),
        ),
        difficultyButton(
          context,
          difficulty: "Medium",
          size: "16x16",
          value: DifficultyLevel.medium,
          selected: currentOptions.difficulty,
          onSelected: (v) => currentOptions.setDifficulty(v),
        ),
        difficultyButton(
          context,
          difficulty: "Hard",
          size: "16x30",
          value: DifficultyLevel.hard,
          selected: currentOptions.difficulty,
          onSelected: (v) => currentOptions.setDifficulty(v),
        ),
      ],
    );
  }
}
