import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:minesweeper/ui/page/widgets/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'minesweeper',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.black),
        textTheme: TextTheme(
          titleLarge: GoogleFonts.lato(
            fontWeight: FontWeight.w900,
            fontSize: 24,
          ),
          displaySmall: GoogleFonts.lato(
            fontWeight: FontWeight.w900,
            fontSize: 24,
          ),
          bodyMedium: GoogleFonts.lato(
            fontWeight: FontWeight.w900,
            fontSize: 22,
          ),
          bodySmall: GoogleFonts.lato(
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
      ),

      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
