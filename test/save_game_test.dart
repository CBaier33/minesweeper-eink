import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:minesweeper/models/saved_game.dart';
import 'package:minesweeper/services/save_service.dart';
import 'package:minesweeper/ui/game/view_models/game_viewmodel.dart';
import 'package:minesweeper/ui/game/widgets/cell.dart';
import 'package:minesweeper/ui/page/view_models/options_view_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

GameViewModel _newGame(DifficultyLevel d) =>
    GameViewModel(options: OptionsViewModel()..setDifficulty(d));

/// A board of blanks with a single mine at (0,0), so a tap there always loses.
SavedGame _boardWithOneMine(DifficultyLevel d, {int time = 0}) {
  final board = List.generate(
    d.rows,
    (_) => List.generate(d.cols, (_) => CellItem(value: 0)),
  );
  board[0][0].value = 9;

  return SavedGame(
    difficulty: d,
    board: board,
    time: time,
    questionMarks: true,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('a saved game comes back cell for cell', () async {
    final game = _newGame(DifficultyLevel.medium);
    game.time = 92;

    // Leave a mix of opened, flagged and question-marked cells behind.
    game.onTapCell(const CellPoint(x: 4, y: 4));
    game.onLongPressCell(const CellPoint(x: 0, y: 0));
    game.boardState[1][1].flagType = FlagType.questionMark;

    final expected = game.boardState;

    await SaveService().save(
      SavedGame(
        difficulty: DifficultyLevel.medium,
        board: expected,
        time: game.time,
        questionMarks: false,
      ),
    );

    final restored = await SaveService().load(DifficultyLevel.medium);

    expect(restored, isNotNull);
    expect(restored!.time, 92);
    expect(restored.questionMarks, isFalse);
    expect(restored.difficulty, DifficultyLevel.medium);

    for (int x = 0; x < DifficultyLevel.medium.rows; x++) {
      for (int y = 0; y < DifficultyLevel.medium.cols; y++) {
        final actual = restored.board[x][y];
        final want = expected[x][y];
        expect(actual.value, want.value, reason: 'value at $x,$y');
        expect(actual.open, want.open, reason: 'open at $x,$y');
        expect(actual.flagType, want.flagType, reason: 'flag at $x,$y');
      }
    }

    game.dispose();
  });

  test('resuming restores the clock and the flag count', () async {
    final save = _boardWithOneMine(DifficultyLevel.hard, time: 137);
    save.board[5][5].flagType = FlagType.flag;
    save.board[6][6].flagType = FlagType.flag;

    final game = GameViewModel.resume(
      options: OptionsViewModel()..setDifficulty(DifficultyLevel.hard),
      save: save,
    );

    expect(game.time, 137);
    expect(game.mineCount, DifficultyLevel.hard.mines - 2);
    expect(game.gameState, 0);

    game.dispose();
  });

  test('one slot per difficulty, and saving again overwrites it', () async {
    final saves = SaveService();

    await saves.save(_boardWithOneMine(DifficultyLevel.easy, time: 5));
    await saves.save(_boardWithOneMine(DifficultyLevel.hard, time: 10));
    expect((await saves.loadAll()).keys, [
      DifficultyLevel.easy,
      DifficultyLevel.hard,
    ]);

    await saves.save(_boardWithOneMine(DifficultyLevel.easy, time: 60));
    final all = await saves.loadAll();
    expect(all.length, 2);
    expect(all[DifficultyLevel.easy]!.time, 60);
  });

  test('finishing a resumed game frees its slot', () async {
    final saves = SaveService();
    final save = _boardWithOneMine(DifficultyLevel.easy);
    await saves.save(save);

    final game = GameViewModel.resume(
      options: OptionsViewModel()..setDifficulty(DifficultyLevel.easy),
      save: save,
    );

    game.onTapCell(const CellPoint(x: 0, y: 0));
    expect(game.gameState, 1, reason: 'tapping the mine should lose');

    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(await saves.load(DifficultyLevel.easy), isNull);

    game.dispose();
  });

  test('winning a resumed game frees its slot', () async {
    const d = DifficultyLevel.easy;
    final saves = SaveService();

    // A real board this time — the win check counts against d.mines.
    final board = List.generate(
      d.rows,
      (_) => List.generate(d.cols, (_) => CellItem(value: 0)),
    );
    for (int i = 0; i < d.mines; i++) {
      board[i ~/ d.cols][i % d.cols].value = 9;
    }

    final save = SavedGame(
      difficulty: d,
      board: board,
      time: 0,
      questionMarks: true,
    );
    await saves.save(save);

    final game = GameViewModel.resume(
      options: OptionsViewModel()..setDifficulty(d),
      save: save,
    );

    // Open every safe cell but one, then take the last one.
    const last = CellPoint(x: 8, y: 8);
    for (int x = 0; x < d.rows; x++) {
      for (int y = 0; y < d.cols; y++) {
        if (game.boardState[x][y].value == 9) continue;
        if (x == last.x && y == last.y) continue;
        game.boardState[x][y].open = true;
      }
    }
    game.onTapCell(last);
    expect(game.gameState, 2, reason: 'every safe cell is open');

    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(await saves.load(d), isNull);

    game.dispose();
  });

  test('leaving a resumed game without saving frees its slot', () async {
    final saves = SaveService();
    final save = _boardWithOneMine(DifficultyLevel.easy, time: 42);
    await saves.save(save);

    final game = GameViewModel.resume(
      options: OptionsViewModel()..setDifficulty(DifficultyLevel.easy),
      save: save,
    );
    game.onTapCell(const CellPoint(x: 4, y: 4));

    // What the options screen does once the game screen is gone.
    await game.discardSave();

    expect(await saves.load(DifficultyLevel.easy), isNull);

    game.dispose();
  });

  test('saving on the way out keeps the game resumable', () async {
    final saves = SaveService();
    final save = _boardWithOneMine(DifficultyLevel.easy, time: 42);
    await saves.save(save);

    final game = GameViewModel.resume(
      options: OptionsViewModel()..setDifficulty(DifficultyLevel.easy),
      save: save,
    );
    game.time = 90;

    await game.saveGame();
    await game.discardSave(); // must not undo the save

    expect((await saves.load(DifficultyLevel.easy))?.time, 90);

    game.dispose();
  });

  test('finishing a fresh game leaves an unrelated save alone', () async {
    final saves = SaveService();
    await saves.save(_boardWithOneMine(DifficultyLevel.easy, time: 42));

    final game = _newGame(DifficultyLevel.easy);
    // Force a loss without caring where the mines landed.
    game.boardState[0][0].value = 9;
    game.onTapCell(const CellPoint(x: 0, y: 0));
    expect(game.gameState, 1);

    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect((await saves.load(DifficultyLevel.easy))?.time, 42);

    game.dispose();
  });

  test('leaving a fresh game leaves an unrelated save alone', () async {
    final saves = SaveService();
    await saves.save(_boardWithOneMine(DifficultyLevel.easy, time: 42));

    final game = _newGame(DifficultyLevel.easy);
    await game.discardSave();

    expect((await saves.load(DifficultyLevel.easy))?.time, 42);

    game.dispose();
  });

  test('an unreadable save is dropped rather than surfaced', () async {
    SharedPreferences.setMockInitialValues({'savedGame_hard': 'not json'});

    expect(await SaveService().load(DifficultyLevel.hard), isNull);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('savedGame_hard'), isNull);
  });

  test('a save whose board no longer fits its difficulty is dropped', () async {
    // e.g. a board stored before a difficulty's dimensions changed.
    final stale = _boardWithOneMine(DifficultyLevel.easy).toJson();
    stale['difficulty'] = DifficultyLevel.hard.name;
    SharedPreferences.setMockInitialValues({
      'savedGame_hard': jsonEncode(stale),
    });

    expect(await SaveService().load(DifficultyLevel.hard), isNull);
  });
}
