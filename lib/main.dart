import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart';

void main() {
  runApp(const SudokuApp());
}

class SudokuApp extends StatelessWidget {
  const SudokuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sudoku Game',
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: const Color(0xFFF0F4F8), // A light background color
      ),
      home: const WelcomeScreen(),
    );
  }
}