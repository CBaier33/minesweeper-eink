import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:minesweeper/ui/core/button.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        backgroundColor: Colors.white,
        shape: const Border(
          bottom: BorderSide(color: Colors.black, width: 3.0),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            //mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                child: Center(
                  child: SizedBox(
                    height: 200,
                    width: 200,
                    child: SvgPicture.asset('assets/svgs/mine.svg',
                      fit: BoxFit.contain,
                    ),
                  ),
                )
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 12,
                children: [
                  SimpleButton(
                    text: "Play",
                    filled: true,
                    onPressed: () {},
                    onLongPress: () {},
                  ),
                  SimpleButton(
                    text: "Statistics",
                    filled: false,
                    onPressed: () {},
                    onLongPress: () {},
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
