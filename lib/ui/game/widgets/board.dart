import 'package:flutter/material.dart';

class Board extends StatelessWidget {
  const Board({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 4,
      children: List.generate(16, (index) {
        return Center(
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 2.0),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: TextTheme.of(context).headlineSmall,
              ),
            ),
          ),
        );
      }),
    );
  }
}
