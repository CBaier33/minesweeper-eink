import 'dart:convert';

import 'package:minesweeper/models/saved_game.dart';
import 'package:minesweeper/ui/page/view_models/options_view_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Holds one suspended game per difficulty, so there are at most three.
class SaveService {
  String _key(DifficultyLevel d) => 'savedGame_${d.name}';

  Future<void> save(SavedGame game) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key(game.difficulty), jsonEncode(game.toJson()));
  }

  Future<SavedGame?> load(DifficultyLevel d) async {
    final prefs = await SharedPreferences.getInstance();

    final raw = prefs.getString(_key(d));
    if (raw == null) return null;

    try {
      return SavedGame.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      // A save we can't read is worse than none — drop it.
      await prefs.remove(_key(d));
      return null;
    }
  }

  Future<void> delete(DifficultyLevel d) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key(d));
  }

  /// Every stored game, in difficulty order.
  Future<Map<DifficultyLevel, SavedGame>> loadAll() async {
    final saves = <DifficultyLevel, SavedGame>{};

    for (final d in DifficultyLevel.values) {
      final game = await load(d);
      if (game != null) saves[d] = game;
    }

    return saves;
  }
}
