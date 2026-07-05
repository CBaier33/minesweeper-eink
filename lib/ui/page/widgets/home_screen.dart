import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:minesweeper/ui/core/widgets/page_route.dart';
import 'package:minesweeper/ui/core/widgets/simple_button.dart';
import 'package:minesweeper/ui/page/widgets/options_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                child: Center(
                  child: SizedBox(
                    height: 250,
                    width: 250,
                    child: SvgPicture.asset(
                      'assets/mine.svg',
                      fit: BoxFit.contain,
                    ),
                  ),
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
                          builder: (context) => OptionsScreen(),
                        ),
                      );
                    },
                    onLongPress: () {},
                  ),
                  SimpleButton(
                    text: "Statistics",
                    filled: false,
                    onPressed: () {},
                    onLongPress: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
