import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:minesweeper/ui/game/view_models/game_viewmodel.dart';
import 'package:provider/provider.dart';

class Cell extends StatelessWidget {
  const Cell({super.key, required this.gridPoint});

  final CellPoint gridPoint;

  // KEY
  // 0 -> Empty
  // 1-8 -> 1-8
  // 9 -> Mine

  @override
  Widget build(BuildContext context) {
    GameViewModel currentGame = Provider.of<GameViewModel>(context);

    CellItem cell = currentGame.getCell(gridPoint);

    if (!cell.open) {
      switch (cell.flagType) {
        case FlagType.questionMark:
          return Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.black, width: 2.0),
                bottom: BorderSide(color: Colors.black, width: 2.0),
                left: BorderSide(color: Colors.black, width: 2.0),
                right: BorderSide(color: Colors.black, width: 2.0),
              ),
            ),
            child: Center(
              child: SizedBox(
                height: 25,
                width: 25,
                child: Text(
                  "?",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),
          );
        case FlagType.flag:
          return Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.black, width: 2.0),
                bottom: BorderSide(color: Colors.black, width: 2.0),
                left: BorderSide(color: Colors.black, width: 2.0),
                right: BorderSide(color: Colors.black, width: 2.0),
              ),
            ),
            child: Center(
              child: SizedBox(
                height: 25,
                width: 25,
                child: SvgPicture.asset('assets/flag.svg', fit: BoxFit.contain),
              ),
            ),
          );

        default:
          return Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.black, width: 2.0),
                bottom: BorderSide(color: Colors.black, width: 2.0),
                left: BorderSide(color: Colors.black, width: 2.0),
                right: BorderSide(color: Colors.black, width: 2.0),
              ),
            ),
          );
      }
      
    } else {

      switch (cell.value) {
        case 0:
          return Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: Colors.grey,
              border: Border(
                top: BorderSide(color: Colors.black, width: 2.0),
                bottom: BorderSide(color: Colors.black, width: 2.0),
                left: BorderSide(color: Colors.black, width: 2.0),
                right: BorderSide(color: Colors.black, width: 2.0),
              ),
            ),
          );
        case 9:
          return Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: Colors.grey,
              border: Border(
                top: BorderSide(color: Colors.black, width: 2.0),
                bottom: BorderSide(color: Colors.black, width: 2.0),
                left: BorderSide(color: Colors.black, width: 2.0),
                right: BorderSide(color: Colors.black, width: 2.0),
              ),
            ),
            child: Center(
              child: SizedBox(
                height: 25,
                width: 25,
                child: SvgPicture.asset('assets/mine.svg', fit: BoxFit.contain),
              ),
            ),
          );
        default:
          return Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: Colors.grey,
              border: Border(
                top: BorderSide(color: Colors.black, width: 2.0),
                bottom: BorderSide(color: Colors.black, width: 2.0),
                left: BorderSide(color: Colors.black, width: 2.0),
                right: BorderSide(color: Colors.black, width: 2.0),
              ),
            ),
            child: Center(
              child: SizedBox(
                height: 25,
                width: 25,
                child: Text(
                  (cell.value).toString(),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),
          );
      }
    }
  }
}

class CellPoint {
  const CellPoint({required this.x, required this.y});

  final int x;
  final int y;
}
