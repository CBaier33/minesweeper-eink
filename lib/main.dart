import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:minesweeper/ui/home/widgets/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'minesweeper',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.black),
        textTheme: TextTheme(
          titleLarge: GoogleFonts.lato(
            fontWeight: FontWeight.w900,
            fontSize: 21,
          ),
          displaySmall: GoogleFonts.lato(
            fontWeight: FontWeight.w900,
            fontSize: 21,
          ),
        ),
      ),

      home: const HomePage(title: 'Minesweeper'),
      debugShowCheckedModeBanner: false,
    );
  }
}
