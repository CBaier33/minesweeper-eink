import 'package:flutter/material.dart';
import 'package:minesweeper/ui/game/view_models/game_viewmodel.dart';
import 'package:minesweeper/ui/game/widgets/cell.dart';
import 'package:minesweeper/ui/page/view_models/options_view_model.dart';
import 'package:provider/provider.dart';

class Board extends StatelessWidget {
  const Board({super.key});

  // Every difficulty uses the tile size of a full-width easy board, so cells
  // stay equally tappable. Bigger boards overflow the screen and scroll.
  static double tileSizeFor(double availableWidth) =>
      availableWidth / DifficultyLevel.easy.cols;

  @override
  Widget build(BuildContext context) {
    GameViewModel currentGame = Provider.of<GameViewModel>(context);

    DifficultyLevel d = currentGame.options.difficulty;

    final gridSize = GridSize(x: d.cols, y: d.rows);

    return LayoutBuilder(
      builder: (context, constraints) {
        final tileSize = tileSizeFor(constraints.maxWidth);

        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const ClampingScrollPhysics(),
            child: SizedBox(
              width: tileSize * gridSize.x,
              height: tileSize * gridSize.y,
              child: GridView.builder(
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: gridSize.x,
                ),
                itemBuilder: (context, index) =>
                    _buildCells(context, index, gridSize),
                itemCount: gridSize.count(),
              ),
            ),
          ),
        );
      },
    );
  }
}

Widget _buildCells(BuildContext context, int index, GridSize grid) {
  GameViewModel currentGame = Provider.of<GameViewModel>(context);

  int y = (index % grid.x);
  int x = (index ~/ grid.x);
  CellPoint cell = CellPoint(x: x, y: y);

  return GestureDetector(
    onTapDown: (_) => currentGame.setCellPressed(true),
    onTapUp: (_) async {
      await Future.delayed(const Duration(milliseconds: 100));
      currentGame.setCellPressed(false);
    },
    // A press that turns into a scroll never gets a tap/long-press end,
    // which would otherwise leave the smiley stuck on its engaged face.
    onTapCancel: () => currentGame.setCellPressed(false),
    onLongPressCancel: () => currentGame.setCellPressed(false),
    onLongPressStart: (_) {
      currentGame.setCellPressed(true);
      currentGame.onLongPressCell(cell);
    },
    onLongPressEnd: (_) {
      currentGame.setCellPressed(false);
    },
    onTap: () => currentGame.onTapCell(cell),
    child: GridTile(
      child: Cell(gridPoint: cell, i: index),
    ),
  );
}

class GridSize {
  const GridSize({required this.x, required this.y});

  final int x;
  final int y;

  int count() {
    return x * y;
  }
}
