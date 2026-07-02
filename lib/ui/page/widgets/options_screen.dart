import 'package:flutter/material.dart';
import 'package:minesweeper/ui/core/widgets/page_route.dart';
import 'package:minesweeper/ui/core/widgets/simple_appbar.dart';
import 'package:minesweeper/ui/core/widgets/simple_button.dart';
import 'package:minesweeper/ui/game/view_models/game_viewmodel.dart';
import 'package:minesweeper/ui/game/widgets/game_screen.dart';
import 'package:minesweeper/ui/page/view_models/options_view_model.dart';
import 'package:minesweeper/ui/core/widgets/difficulty_selector.dart';
import 'package:provider/provider.dart';

class OptionsScreen extends StatefulWidget {
  const OptionsScreen({super.key});

  @override
  State<OptionsScreen> createState() => _OptionsScreenState();
}

class _OptionsScreenState extends State<OptionsScreen> {

  late final OptionsViewModel optionsViewModel;
  
  @override
  void initState() {
    super.initState();
    optionsViewModel = OptionsViewModel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SimpleAppBar(title: "Options"),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Select Difficulty",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  ChangeNotifierProvider.value(
                    value: optionsViewModel,
                    child: DifficultySelector(),
                  ),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 16,
              children: [
                SimpleButton(
                  text: "Play",
                  filled: true,
                  onPressed: () {
                    Navigator.push(
                      context,
                      SimplePageRoute<void>(
                        builder: (context) => GameScreen(
                          viewModel: GameViewModel(options: optionsViewModel),
                        ),
                      ),
                    );
                  },
                  onLongPress: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
