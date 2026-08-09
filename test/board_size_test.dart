import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minesweeper/ui/game/view_models/game_viewmodel.dart';
import 'package:minesweeper/ui/game/widgets/board.dart';
import 'package:minesweeper/ui/game/widgets/cell.dart';
import 'package:minesweeper/ui/page/view_models/options_view_model.dart';
import 'package:provider/provider.dart';

Widget _boardFor(DifficultyLevel d) {
  final options = OptionsViewModel()..setDifficulty(d);
  return MaterialApp(
    home: Scaffold(
      body: ChangeNotifierProvider.value(
        value: GameViewModel(options: options),
        child: const Board(),
      ),
    ),
  );
}

void main() {
  // Mudita Kompakt: 480x800 physical at density 213 -> ~360.6x601 logical.
  const kompakt = Size(360.6, 601);

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  for (final d in DifficultyLevel.values) {
    testWidgets('${d.name} tiles are the same size', (tester) async {
      tester.view.physicalSize = kompakt;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_boardFor(d));

      final tile = tester.getSize(find.byType(Cell).first);
      expect(tile.width, closeTo(kompakt.width / 9, 0.01));
      expect(tile.height, closeTo(kompakt.width / 9, 0.01));
    });
  }

  testWidgets('big boards scroll on both axes', (tester) async {
    tester.view.physicalSize = kompakt;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_boardFor(DifficultyLevel.hard));

    final scrollables = tester.widgetList<Scrollable>(find.byType(Scrollable));
    expect(
      scrollables.map((s) => s.axisDirection),
      containsAll([AxisDirection.down, AxisDirection.right]),
    );

    final before = tester.getTopLeft(find.byType(Cell).first);
    await tester.drag(find.byType(Board), const Offset(-100, -100));
    await tester.pumpAndSettle();
    final after = tester.getTopLeft(find.byType(Cell).first);
    expect(after, isNot(before));
  });
}
