import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';

class NumberPad extends StatelessWidget {
  final Function(int number) onNumberSelected;
  final VoidCallback onErasePressed;
  final bool isNoteMode;

  const NumberPad({
    Key? key,
    required this.onNumberSelected,
    required this.onErasePressed,
    required this.isNoteMode,
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
      child: Column(
        children: [
          // Numbers 1-9
          Expanded(
            child: Row(
              children: List.generate(9, (index) {
                int number = index + 1;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: _buildNumberButton(number),
                  ),
                );
              }),
            ),
          ),
          
          const SizedBox(height: AppDimensions.paddingSmall),
          
          // Erase button
          SizedBox(
            width: double.infinity,
            height: 44,
            child: _buildEraseButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberButton(int number) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onNumberSelected(number),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        child: Container(
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBlue.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  number.toString(),
                  style: AppTextStyles.cellNumber.copyWith(
                    color: AppColors.textLight,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isNoteMode) ...[
                  const SizedBox(height: 2),
                  Container(
                    width: 12,
                    height: 2,
                    decoration: BoxDecoration(
                      color: AppColors.textLight.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEraseButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onErasePressed,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.errorCell.withOpacity(0.1),
            border: Border.all(
              color: AppColors.errorCell.withOpacity(0.3),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.backspace_outlined,
                  color: AppColors.errorCell,
                  size: 20,
                ),
                const SizedBox(width: AppDimensions.paddingSmall),
                Text(
                  "Erase",
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.errorCell,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
