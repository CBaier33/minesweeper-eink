import 'package:flutter/material.dart';
import 'package:minesweeper/ui/core/widgets/simple_appbar.dart';
import 'package:minesweeper/ui/game/view_models/game_viewmodel.dart';
import 'package:minesweeper/ui/game/widgets/board.dart';
import 'package:minesweeper/ui/game/widgets/game_bar.dart';
import 'package:provider/provider.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.viewModel});

  final GameViewModel viewModel;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: widget.viewModel,
      child: Scaffold(
        appBar: SimpleAppBar(title: "Minesweeper"),
        backgroundColor: Colors.white,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GameBar(),
            Expanded(child: Board()),
          ],
        ),
      ),
    );
  }
}
