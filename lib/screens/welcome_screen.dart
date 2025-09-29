import 'package:flutter/material.dart' show AnimatedBuilder, Animation, AnimationController, AnimationStatus, BorderRadius, BorderSide, BoxConstraints, BoxDecoration, BoxShadow, BuildContext, Canvas, Center, Color, Colors, Column, ConstrainedBox, Container, CurvedAnimation, Curves, CustomPaint, CustomPainter, EdgeInsets, ElevatedButton, FontWeight, Icon, IconData, Icons, Key, MainAxisSize, MaterialApp, MaterialPageRoute, Navigator, Offset, Padding, Paint, PaintingStyle, RoundedRectangleBorder, Scaffold, SingleChildScrollView, SingleTickerProviderStateMixin, Size, SizedBox, State, StatefulWidget, StatelessWidget, Text, TextDirection, TextPainter, TextSpan, TextStyle, ThemeData, VoidCallback, Widget, runApp, showModalBottomSheet;
import 'dart:math' as math;
import 'package:sudoku_game/screens/game_screen.dart'; // Import GameScreen
import 'package:sudoku_game/screens/widgets/difficulty_selector.dart'; // Import LevelSelectorPopup
import 'package:sudoku_game/screens/widgets/scale_transition.dart';
import 'package:sudoku_game/screens/widgets/achievements_screen.dart'; // This is the correct import for AchievementsScreen
import 'package:sudoku_game/utils/storage_service.dart'; // Add this import for the StorageService

void main() {
  runApp(const SudokuApp());
}

// The main application widget.
class SudokuApp extends StatelessWidget {
  const SudokuApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sudoku App',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        fontFamily: 'Inter',
      ),
      home: const WelcomeScreen(),
    );
  }
}

// The welcome screen widget, now a StatefulWidget.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _gridAnimationController;
  late Animation<double> _gridAnimation;

  @override
  void initState() {
    super.initState();
    // Initialize animation controller for the Sudoku grid
    _gridAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _gridAnimation = CurvedAnimation(
      parent: _gridAnimationController,
      curve: Curves.easeInOutCubic,
    );

    _gridAnimationController.forward();
    _gridAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _gridAnimationController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _gridAnimationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _gridAnimationController.dispose();
    super.dispose();
  }

  // A helper method to build the common button style.
  Widget _buildActionButton(
      BuildContext context, {
        required String label,
        required IconData icon,
        required Color backgroundColor,
        required Color textColor,
        Color borderColor = Colors.transparent,
        required VoidCallback onPressed,
      }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
            side: BorderSide(color: borderColor, width: 1.0),
          ),
          elevation: backgroundColor == Colors.white ? 1.0 : 4.0,
          shadowColor: backgroundColor == Colors.white ? Colors.transparent : Colors.black.withOpacity(0.15),
        ),
        icon: Icon(icon, size: 24.0, color: (icon == Icons.emoji_events) ? Colors.amber.shade500 : textColor),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // This method handles the navigation to the game screen
  void _startGame(String difficulty) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GameScreen(difficulty: difficulty),
      ),
    );
  }

  // This method shows the level selector popup using a modal bottom sheet
  void _showLevelSelectorPopup() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return LevelSelectorPopup(
          onClose: () => Navigator.of(context).pop(),
          onLevelSelected: _startGame,
        );
      },
    );
  }

  // This new method handles the logic for the Achievements button
  void _showAchievements() async {
    // 1. Create an instance of your StorageService
    final storageService = StorageService();

    // 2. Await the loading of the game stats from storage
    final gameStats = await storageService.loadAllStats();

    // 3. Navigate to the AchievementsScreen and pass the loaded data
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AchievementsScreen(gameStats: gameStats),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Container(
              padding: const EdgeInsets.all(32.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Sudoku-themed Illustration with animation
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.indigo.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(24.0),
                      ),
                      child: Center(
                        child: AnimatedBuilder(
                          animation: _gridAnimation,
                          builder: (context, child) {
                            return CustomPaint(
                              size: const Size(120, 120),
                              painter: _GridPainter(_gridAnimation.value),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  const Text(
                    'Sudoku',
                    style: TextStyle(
                      fontSize: 48.0,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2D3748),
                      letterSpacing: -1.5,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  const Text(
                    'A fresh challenge awaits',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF718096),
                    ),
                  ),
                  const SizedBox(height: 32.0),
                  // "Let's Play" button now shows the level selector
                  _buildActionButton(
                    context,
                    label: "Let's Play",
                    icon: Icons.play_arrow,
                    backgroundColor: Colors.indigo.shade600,
                    textColor: Colors.white,
                    onPressed: _showLevelSelectorPopup, // Call the new method
                  ),
                  const SizedBox(height: 16.0),
                  _buildActionButton(
                    context,
                    label: "Achievements",
                    icon: Icons.emoji_events,
                    backgroundColor: Colors.white,
                    textColor: const Color(0xFF4A5568),
                    borderColor: const Color(0xFFE2E8F0),
                    onPressed: _showAchievements, // Call the new method
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// A custom painter to draw the animated grid and numbers.
class _GridPainter extends CustomPainter {
  final double progress;
  _GridPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    // Clamp progress to ensure it's always between 0.0 and 1.0
    final clampedProgress = progress.clamp(0.0, 1.0);

    final gridPaint = Paint()
      ..color = Colors.indigo.shade300.withOpacity(clampedProgress) // Fixed: clamped opacity
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final boldLinePaint = Paint()
      ..color = Colors.indigo.shade400.withOpacity(clampedProgress) // Fixed: clamped opacity
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;

    const gridSize = 9.0;
    final cellSize = size.width / gridSize;
    const numbers = [
      [5, 3, 4, 6, 7, 8, 9, 1, 2],
      [6, 7, 2, 1, 9, 5, 3, 4, 8],
      [1, 9, 8, 3, 4, 2, 5, 6, 7],
      [8, 5, 9, 7, 6, 1, 4, 2, 3],
      [4, 2, 6, 8, 5, 3, 7, 9, 1],
      [7, 1, 3, 9, 2, 4, 8, 5, 6],
      [9, 6, 1, 5, 3, 7, 2, 8, 4],
      [2, 8, 7, 4, 1, 9, 6, 3, 5],
      [3, 4, 5, 2, 8, 6, 1, 7, 9],
    ];

    // Animate the grid lines
    for (int i = 0; i <= gridSize; i++) {
      final animationFactor = math.min(1.0, clampedProgress * 2 - i / (gridSize));
      final clampedAnimationFactor = animationFactor.clamp(0.0, 1.0);

      canvas.drawLine(
        Offset(0, i * cellSize),
        Offset(size.width * clampedAnimationFactor, i * cellSize), // Fixed: clamped
        (i % 3 == 0) ? boldLinePaint : gridPaint,
      );
      canvas.drawLine(
        Offset(i * cellSize, 0),
        Offset(i * cellSize, size.height * clampedAnimationFactor), // Fixed: clamped
        (i % 3 == 0) ? boldLinePaint : gridPaint,
      );
    }

    // Animate the numbers after the lines have started drawing
    if (clampedProgress > 0.5) {
      for (int row = 0; row < gridSize; row++) {
        for (int col = 0; col < gridSize; col++) {
          final numberProgress = math.max(0.0, (clampedProgress - 0.5) * 2 - (row * gridSize + col) / (gridSize * gridSize));
          // Fixed: Clamp numberProgress to valid opacity range
          final clampedNumberProgress = numberProgress.clamp(0.0, 1.0);

          final numberText = numbers[row][col].toString();

          final numberStyle = TextStyle(
            color: Colors.indigo.shade800,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          );

          final textPainter = TextPainter(
            text: TextSpan(
              text: numberText,
              style: numberStyle.copyWith(
                color: numberStyle.color!.withOpacity(clampedNumberProgress), // Fixed: using clamped value
                fontSize: numberStyle.fontSize! * (0.8 + 0.2 * clampedNumberProgress), // Fixed: using clamped value
              ),
            ),
            textDirection: TextDirection.ltr,
          );
          textPainter.layout();
          textPainter.paint(
            canvas,
            Offset(
              col * cellSize + (cellSize / 2 - textPainter.width / 2),
              row * cellSize + (cellSize / 2 - textPainter.height / 2),
            ),
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}