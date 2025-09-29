import 'package:flutter/material.dart';

class AppColors {
  // Primary colors
  static const Color primaryBlue = Color(0xFF6366F1);
  static const Color primaryPurple = Color(0xFF8B5CF6);
  static const Color primaryPink = Color(0xFFEC4899);
  
  // Background colors
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF1E293B);
  
  // Text colors
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textLight = Color(0xFFFFFFFF);
  
  // Game colors
  static const Color fixedCell = Color(0xFFE2E8F0);
  static const Color selectedCell = Color(0xFF3B82F6);
  static const Color highlightedCell = Color(0xFFDEF7EC);
  static const Color errorCell = Color(0xFFEF4444);
  static const Color completedCell = Color(0xFF10B981);
  
  // Difficulty colors
  static const Color easyColor = Color(0xFF10B981);
  static const Color mediumColor = Color(0xFFF59E0B);
  static const Color hardColor = Color(0xFFEF4444);
  static const Color extremeColor = Color(0xFF8B5CF6);
  
  // Gradient colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryBlue, primaryPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

class AppDimensions {
  // Padding and margins
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXL = 32.0;
  
  // Border radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXL = 24.0;
  
  // Cell sizes
  static const double cellSize = 40.0;
  static const double cellBorderWidth = 1.0;
  static const double thickBorderWidth = 2.0;
  
  // Button sizes
  static const double buttonHeight = 48.0;
  static const double smallButtonHeight = 36.0;
  static const double iconButtonSize = 44.0;
}

class AppTextStyles {
  static const TextStyle heading1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle heading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle heading3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );
  
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textLight,
  );
  
  static const TextStyle cellNumber = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle cellNote = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );
}

class AppAnimations {
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  
  static const Curve defaultCurve = Curves.easeInOutCubic;
  static const Curve bounceCurve = Curves.bounceOut;
}

class AppStrings {
  static const String appName = "Sudoku Master";
  static const String welcome = "Welcome to Sudoku";
  static const String playGame = "Play Game";
  static const String selectDifficulty = "Select Difficulty";
  static const String newGame = "New Game";
  static const String pause = "Pause";
  static const String resume = "Resume";
  static const String hint = "Hint";
  static const String reset = "Reset";
  static const String settings = "Settings";
  static const String statistics = "Statistics";
  static const String completed = "Completed!";
  static const String congratulations = "Congratulations!";
  static const String timePlayed = "Time: ";
  static const String hintsUsed = "Hints Used: ";
  static const String noHintsLeft = "No hints left";
}
