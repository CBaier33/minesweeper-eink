import 'package:flutter/material.dart';
import 'package:minesweeper/ui/game/view_models/game_viewmodel.dart';
import 'package:minesweeper/ui/game/widgets/cell.dart';
import 'package:minesweeper/ui/page/view_models/options_view_model.dart';
import 'package:provider/provider.dart';

class Board extends StatelessWidget {
  const Board({super.key});

  @override
  Widget build(BuildContext context) {
    GameViewModel currentGame = Provider.of<GameViewModel>(context);

    DifficultyLevel d = currentGame.options.difficulty;

    final gridSize = GridSize(x: d.cols, y: d.rows);

    return Center(
      child: SizedBox(
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: gridSize.x,
          ),
          itemBuilder: (context, index) => _buildCells(context, index, gridSize),
          itemCount: gridSize.count(),
        ),
      ),
    );
  }
}

Widget _buildCells(BuildContext context, int index, GridSize grid) {

  GameViewModel currentGame = Provider.of<GameViewModel>(context);

  int x = (index % grid.x);
  int y = (index ~/ grid.y);
  CellPoint cell = CellPoint(x: x, y: y);
  
  return GestureDetector(
    onLongPress: () => currentGame.onLongPressCell(cell),
    onTap: () => currentGame.onTapCell(cell),
    child: GridTile(child: Cell(gridPoint: cell)),
  );
}

class GridSize {
  const GridSize({
    required this.x,
    required this.y
  });

  final int x;
  final int y;

  int count() {
    return x * y;
  }
}
