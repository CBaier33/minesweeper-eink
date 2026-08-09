import 'package:flutter/material.dart';
import 'package:minesweeper/ui/core/widgets/action_modal.dart';
import 'package:minesweeper/ui/core/widgets/simple_button.dart';
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
  // The view model is built for this screen and outlives nothing, so the
  // screen owns tearing its timer down.
  @override
  void dispose() {
    widget.viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: widget.viewModel,
      child: Scaffold(
        appBar: AppBar(
          leadingWidth: 38,
          leading: SizedBox(
            width: 36,
            height: 36,
            child: IconButton(
              iconSize: 36,
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
              style: IconButton.styleFrom(overlayColor: Colors.transparent),
              hoverColor: Colors.transparent,
              splashColor: Colors.transparent,
              focusColor: Colors.transparent,
            ),
          ),
          title: Text(
            "Minesweeper",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          backgroundColor: Colors.white,
          shape: const Border(top: BorderSide(color: Colors.black, width: 3.0)),
          actionsPadding: EdgeInsets.only(right: 10),
          actions: [
            Container(
              width: 50,
              height: 35,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 2.0),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: IconButton(
                  icon: Image.asset(
                    'assets/pause.png',
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.none,
                  ),
                  iconSize: 70,
                  onPressed: () {
                    widget.viewModel.pauseTimer();
                    actionModal(
                      context,
                      Column(
                        spacing: 10,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Menu",
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                      [
                        SimpleButton(
                          text: "Continue",
                          filled: true,
                          onPressed: () {
                            widget.viewModel.resumeTimer();
                            Navigator.pop(context);
                          },
                          onLongPress: () => {},
                        ),

                        // A finished game has nothing left to come back to.
                        if (widget.viewModel.gameState == 0)
                          SimpleButton(
                            text: "Save & Quit",
                            filled: false,
                            onPressed: () async {
                              final navigator = Navigator.of(context);
                              await widget.viewModel.saveGame();
                              navigator.popUntil((route) => route.isFirst);
                            },
                            onLongPress: () => {},
                          ),

                        SimpleButton(
                          text: "Exit",
                          filled: false,
                          onPressed: () => {
                            Navigator.of(
                              context,
                            ).popUntil((route) => route.isFirst),
                          },
                          onLongPress: () => {},
                        ),
                      ],
                    );
                  },
                  style: IconButton.styleFrom(overlayColor: Colors.transparent),
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GameBar(),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.black, width: 5.0),
                      ),
                    ),
                    child: Board(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> oldactionModal(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      barrierColor: Colors.transparent,
      constraints: BoxConstraints.expand(width: double.infinity),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      sheetAnimationStyle: AnimationStyle.noAnimation,
      enableDrag: false,
      builder: (BuildContext context) {
        return SizedBox.expand(
          child: Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.black, width: 3.0)),
            ),
            child: Column(
              children: [
                Text("Menu", style: Theme.of(context).textTheme.titleLarge),

                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      spacing: 10,
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SimpleButton(
                          text: "Resume",
                          filled: true,
                          onPressed: () {
                            widget.viewModel.resumeTimer();
                            Navigator.pop(context);
                          },
                          onLongPress: () => {},
                        ),

                        SimpleButton(
                          text: "Exit",
                          filled: false,
                          onPressed: () => {
                            Navigator.of(
                              context,
                            ).popUntil((route) => route.isFirst),
                          },
                          onLongPress: () => {},
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
