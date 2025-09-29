import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';

class GameControls extends StatelessWidget {
  final VoidCallback onNewGame;
  final VoidCallback onHint;
  final int hintsRemaining;
  final bool isNoteMode;
  final VoidCallback onNoteModeToggle;

  const GameControls({
    Key? key,
    required this.onNewGame,
    required this.onHint,
    required this.hintsRemaining,
    required this.isNoteMode,
    required this.onNoteModeToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.cardLight,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
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
          // New Game Button
          Expanded(
            child: _buildControlButton(
              icon: Icons.refresh,
              label: AppStrings.newGame,
              onTap: onNewGame,
              color: AppColors.primaryBlue,
            ),
          ),

          const SizedBox(width: AppDimensions.paddingMedium),

          // Hint Button
          Expanded(
            child: _buildControlButton(
              icon: Icons.lightbulb_outline,
              label: "${AppStrings.hint} ($hintsRemaining)",
              onTap: hintsRemaining > 0 ? onHint : null,
              color: hintsRemaining > 0 
                  ? AppColors.mediumColor 
                  : AppColors.textSecondary,
            ),
          ),

          const SizedBox(width: AppDimensions.paddingMedium),

          // Note Mode Toggle
          Expanded(
            child: _buildControlButton(
              icon: isNoteMode ? Icons.edit : Icons.edit_outlined,
              label: "Notes",
              onTap: onNoteModeToggle,
              color: isNoteMode ? AppColors.primaryPurple : AppColors.textSecondary,
              isActive: isNoteMode,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
    required Color color,
    bool isActive = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingSmall,
            vertical: AppDimensions.paddingMedium,
          ),
          decoration: BoxDecoration(
            color: isActive 
                ? color.withOpacity(0.1)
                : Colors.transparent,
            border: Border.all(
              color: onTap != null 
                  ? color.withOpacity(0.3) 
                  : AppColors.textSecondary.withOpacity(0.2),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: onTap != null ? color : AppColors.textSecondary,
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: onTap != null ? color : AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
