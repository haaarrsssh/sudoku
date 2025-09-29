import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../../models/sudoku_game.dart';

class SudokuGrid extends StatelessWidget {
  final SudokuGame game;
  final int? selectedRow;
  final int? selectedCol;
  final Function(int row, int col) onCellTapped;

  const SudokuGrid({
    super.key,
    required this.game,
    required this.selectedRow,
    required this.selectedCol,
    required this.onCellTapped,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardLight,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
          child: Container(
            padding: const EdgeInsets.all(AppDimensions.paddingSmall),
            child: Column(
              children: List.generate(9, (row) => _buildRow(row)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRow(int row) {
    return Expanded(
      child: Row(
        children: List.generate(9, (col) => _buildCell(row, col)),
      ),
    );
  }

  Widget _buildCell(int row, int col) {
    final cell = game.grid[row][col];
    final isSelected = selectedRow == row && selectedCol == col;
    final isHighlighted = cell.isHighlighted && !isSelected;

    Color backgroundColor = AppColors.cardLight;
    if (isSelected) {
      backgroundColor = AppColors.selectedCell;
    } else if (isHighlighted) {
      backgroundColor = AppColors.highlightedCell;
    } else if (cell.isFixed) {
      backgroundColor = AppColors.fixedCell;
    }

    if (cell.hasError) {
      backgroundColor = AppColors.errorCell.withOpacity(0.3);
    }

    return Expanded(
      child: GestureDetector(
        onTap: () => onCellTapped(row, col),
        child: Container(
          margin: EdgeInsets.all(0.5),
          decoration: BoxDecoration(
            color: backgroundColor,
            border: _getCellBorder(row, col),
          ),
          child: Center(
            child: _buildCellContent(cell, isSelected),
          ),
        ),
      ),
    );
  }

  Widget _buildCellContent(SudokuCell cell, bool isSelected) {
    if (cell.value != null) {
      return Text(
        cell.value.toString(),
        style: AppTextStyles.cellNumber.copyWith(
          color: cell.hasError
              ? AppColors.errorCell
              : cell.isFixed
                  ? AppColors.textPrimary
                  : isSelected
                      ? AppColors.textLight
                      : AppColors.primaryBlue,
          fontSize: 18,
          fontWeight: cell.isFixed ? FontWeight.normal : FontWeight.bold,
        ),
      );
    } else if (cell.notes.isNotEmpty) {
      return GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: List.generate(9, (index) {
          int number = index + 1;
          bool hasNote = cell.notes.contains(number);
          return hasNote
              ? Center(
                  child: Text(
                    number.toString(),
                    style: AppTextStyles.cellNote.copyWith(
                      color: isSelected
                          ? AppColors.textLight.withOpacity(0.8)
                          : AppColors.textSecondary,
                      fontSize: 8,
                    ),
                  ),
                )
              : const SizedBox.shrink();
        }),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Border _getCellBorder(int row, int col) {
    double leftWidth = col % 3 == 0 ? AppDimensions.thickBorderWidth : AppDimensions.cellBorderWidth;
    double rightWidth = col == 8 ? AppDimensions.thickBorderWidth : 
                       (col + 1) % 3 == 0 ? AppDimensions.thickBorderWidth : 0;
    double topWidth = row % 3 == 0 ? AppDimensions.thickBorderWidth : AppDimensions.cellBorderWidth;
    double bottomWidth = row == 8 ? AppDimensions.thickBorderWidth : 
                        (row + 1) % 3 == 0 ? AppDimensions.thickBorderWidth : 0;

    Color borderColor = AppColors.textSecondary.withOpacity(0.3);

    return Border(
      left: BorderSide(
        color: borderColor,
        width: leftWidth,
      ),
      right: BorderSide(
        color: borderColor,
        width: rightWidth,
      ),
      top: BorderSide(
        color: borderColor,
        width: topWidth,
      ),
      bottom: BorderSide(
        color: borderColor,
        width: bottomWidth,
      ),
    );
  }
}
