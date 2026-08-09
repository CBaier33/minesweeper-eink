import 'package:flutter/material.dart';
import 'package:minesweeper/models/saved_game.dart';
import 'package:minesweeper/services/save_service.dart';
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

  final SaveService _saveService = SaveService();
  Map<DifficultyLevel, SavedGame> _saves = {};

  @override
  void initState() {
    super.initState();
    optionsViewModel = OptionsViewModel();
    _loadSaves();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _precacheImages();
    });
  }

  Future<void> _loadSaves() async {
    final saves = await _saveService.loadAll();
    if (!mounted) return;
    setState(() => _saves = saves);
  }

  /// Plays [viewModel], then refreshes the list.
  ///
  /// However the player left — exit, back, a win or a loss — a resumed game
  /// is dropped here unless they saved it again. Doing it after the pop also
  /// catches the paths no button handler sees, like the system back gesture.
  Future<void> _play(GameViewModel viewModel) async {
    await Navigator.push(
      context,
      SimplePageRoute<void>(
        builder: (context) => GameScreen(viewModel: viewModel),
      ),
    );
    await viewModel.discardSave();
    await _loadSaves();
  }

  Future<void> _precacheImages() async {
    const assets = [
      'assets/flag.png',
      'assets/mine.png',
      'assets/engaged-smile.png',
      'assets/lose-smile.png',
      'assets/normal-smile.png',
      'assets/win-smile.png',
    ];

    for (final asset in assets) {
      try {
        await precacheImage(AssetImage(asset), context);
      } catch (e) {
        debugPrint('Failed loading $asset: $e');
      }
    }
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
              child: SingleChildScrollView(
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
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              "Use Question Marks",
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                optionsViewModel.questionMarks =
                                    !optionsViewModel.questionMarks;
                              });
                            },
                            child: Container(
                              width: 48,
                              height: 28,
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: optionsViewModel.questionMarks
                                    ? Colors.black
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(13),
                                border: Border.all(color: Colors.black),
                              ),
                              child: AnimatedAlign(
                                duration: Duration.zero, // <- kills motion
                                alignment: optionsViewModel.questionMarks
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: optionsViewModel.questionMarks
                                        ? Colors.white
                                        : Colors.black,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 16,
              children: [
                for (final save in _saves.values)
                  SimpleButton(
                    text: "Continue ${save.difficulty.label}",
                    filled: false,
                    onPressed: () {
                      setState(() {
                        optionsViewModel.setDifficulty(save.difficulty);
                        optionsViewModel.questionMarks = save.questionMarks;
                      });
                      _play(
                        GameViewModel.resume(
                          options: optionsViewModel,
                          save: save,
                        ),
                      );
                    },
                    onLongPress: () {},
                  ),
                SimpleButton(
                  text: "Play",
                  filled: true,
                  onPressed: () {
                    _play(GameViewModel(options: optionsViewModel));
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
