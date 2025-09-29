import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../../models/sudoku_game.dart';

class GameHeader extends StatelessWidget {
  final Difficulty difficulty;
  final int timeElapsed;
  final bool isPaused;
  final int hintsUsed;
  final int maxHints;
  final VoidCallback onPausePressed;
  final VoidCallback onBackPressed;

  const GameHeader({
    Key? key,
    required this.difficulty,
    required this.timeElapsed,
    required this.isPaused,
    required this.hintsUsed,
    required this.maxHints,
    required this.onPausePressed,
    required this.onBackPressed,
  }) : super(key: key);

  Color _getDifficultyColor() {
    switch (difficulty) {
      case Difficulty.easy:
        return AppColors.easyColor;
      case Difficulty.medium:
        return AppColors.mediumColor;
      case Difficulty.hard:
        return AppColors.hardColor;
      case Difficulty.extreme:
        return AppColors.extremeColor;
    }
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.cardLight,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back Button
          IconButton(
            onPressed: onBackPressed,
            icon: const Icon(Icons.arrow_back_ios),
            color: AppColors.textPrimary,
          ),

          const SizedBox(width: AppDimensions.paddingSmall),

          // Difficulty Badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingMedium,
              vertical: AppDimensions.paddingSmall,
            ),
            decoration: BoxDecoration(
              color: _getDifficultyColor(),
              borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
            ),
            child: Text(
              difficulty.displayName.toUpperCase(),
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textLight,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),

          const Spacer(),

          // Timer
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingMedium,
              vertical: AppDimensions.paddingSmall,
            ),
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.timer,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  _formatTime(timeElapsed),
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: AppDimensions.paddingSmall),

          // Hints Counter
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingMedium,
              vertical: AppDimensions.paddingSmall,
            ),
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  size: 18,
                  color: hintsUsed < maxHints 
                      ? AppColors.primaryBlue 
                      : AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  '${maxHints - hintsUsed}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: hintsUsed < maxHints 
                        ? AppColors.primaryBlue 
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: AppDimensions.paddingSmall),

          // Pause Button
          Container(
            decoration: BoxDecoration(
              gradient: isPaused 
                  ? null 
                  : AppColors.primaryGradient,
              color: isPaused 
                  ? AppColors.backgroundLight 
                  : null,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            ),
            child: IconButton(
              onPressed: onPausePressed,
              icon: Icon(
                isPaused ? Icons.play_arrow : Icons.pause,
              ),
              color: isPaused 
                  ? AppColors.primaryBlue 
                  : AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }
}
