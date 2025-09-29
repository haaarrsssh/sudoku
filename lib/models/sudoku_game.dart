// lib/models/sudoku_game.dart

enum Difficulty {
  easy(30, "Easy"),
  medium(40, "Medium"),
  hard(50, "Hard"),
  extreme(60, "Extreme");

  const Difficulty(this.cellsToRemove, this.displayName);
  final int cellsToRemove;
  final String displayName;
}

class SudokuCell {
  int? value;
  bool isFixed;
  bool hasError;
  bool isHighlighted;
  Set<int> notes;

  SudokuCell({
    this.value,
    this.isFixed = false,
    this.hasError = false,
    this.isHighlighted = false,
    Set<int>? notes,
  }) : notes = notes ?? <int>{};

  SudokuCell copy() {
    return SudokuCell(
      value: value,
      isFixed: isFixed,
      hasError: hasError,
      isHighlighted: isHighlighted,
      notes: Set<int>.from(notes),
    );
  }
}

class SudokuGame {
  late List<List<SudokuCell>> grid;
  late List<List<int?>> solution;
  Difficulty difficulty;
  int secondsElapsed;
  bool isPaused;
  bool isCompleted;
  int hintsUsed;
  int maxHints;

  SudokuGame({required this.difficulty})
      : secondsElapsed = 0,
        isPaused = false,
        isCompleted = false,
        hintsUsed = 0,
        maxHints = 3 {
    _initializeGame();
  }

  // Private constructor to create an instance with provided state
  SudokuGame._internal({
    required this.difficulty,
    required this.grid,
    required this.solution,
    this.secondsElapsed = 0,
    this.isPaused = false,
    this.isCompleted = false,
    this.hintsUsed = 0,
    this.maxHints = 3,
  });

  void _initializeGame() {
    grid = List<List<SudokuCell>>.generate(
        9, (i) => List<SudokuCell>.generate(9, (j) => SudokuCell()));
    _generateCompleteSudoku();
    _createPuzzle();
  }

  void _generateCompleteSudoku() {
    // Initialize solution grid
    solution = List<List<int?>>.generate(9, (i) => List<int?>.filled(9, null));

    // Fill the diagonal 3x3 boxes first
    _fillDiagonalBoxes();

    // Fill remaining cells
    _solveSudoku(solution);

    // Copy solution to grid
    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        grid[i][j].value = solution[i][j];
        grid[i][j].isFixed = true;
      }
    }
  }

  void _fillDiagonalBoxes() {
    for (int i = 0; i < 9; i += 3) {
      _fillBox(i, i);
    }
  }

  void _fillBox(int row, int col) {
    List<int> numbers = List<int>.generate(9, (i) => i + 1);
    numbers.shuffle();

    int index = 0;
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        solution[row + i][col + j] = numbers[index++];
      }
    }
  }

  bool _solveSudoku(List<List<int?>> board) {
    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        if (board[i][j] == null) {
          List<int> numbers = List<int>.generate(9, (i) => i + 1);
          numbers.shuffle();

          for (int num in numbers) {
            if (_isValidMove(board, i, j, num)) {
              board[i][j] = num;
              if (_solveSudoku(board)) {
                return true;
              }
              board[i][j] = null;
            }
          }
          return false;
        }
      }
    }
    return true;
  }

  void _createPuzzle() {
    List<List<int>> positions = [];
    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        positions.add([i, j]);
      }
    }
    positions.shuffle();

    int cellsToRemove = difficulty.cellsToRemove;
    for (int i = 0; i < cellsToRemove && i < positions.length; i++) {
      int row = positions[i][0];
      int col = positions[i][1];
      grid[row][col].value = null;
      grid[row][col].isFixed = false;
    }
  }

  bool _isValidMove(List<List<int?>> board, int row, int col, int num) {
    // Check row
    for (int j = 0; j < 9; j++) {
      if (board[row][j] == num) return false;
    }

    // Check column
    for (int i = 0; i < 9; i++) {
      if (board[i][col] == num) return false;
    }

    // Check 3x3 box
    int boxRow = (row ~/ 3) * 3;
    int boxCol = (col ~/ 3) * 3;
    for (int i = boxRow; i < boxRow + 3; i++) {
      for (int j = boxCol; j < boxCol + 3; j++) {
        if (board[i][j] == num) return false;
      }
    }

    return true;
  }

  bool makeMove(int row, int col, int? value) {
    if (grid[row][col].isFixed) return false;

    // Clear any existing errors
    _clearErrors();

    grid[row][col].value = value;
    grid[row][col].notes.clear();

    // Validate the move
    bool isValid = value == null || _isValidCurrentMove(row, col, value);

    if (!isValid) {
      grid[row][col].hasError = true;
    }

    // Check if game is completed
    _checkCompletion();

    return isValid;
  }

  bool _isValidCurrentMove(int row, int col, int num) {
    // Temporarily remove the current value to check validity
    int? temp = grid[row][col].value;
    grid[row][col].value = null;

    bool isValid = true;

    // Check row
    for (int j = 0; j < 9; j++) {
      if (j != col && grid[row][j].value == num) {
        isValid = false;
        break;
      }
    }

    // Check column
    if (isValid) {
      for (int i = 0; i < 9; i++) {
        if (i != row && grid[i][col].value == num) {
          isValid = false;
          break;
        }
      }
    }

    // Check 3x3 box
    if (isValid) {
      int boxRow = (row ~/ 3) * 3;
      int boxCol = (col ~/ 3) * 3;
      for (int i = boxRow; i < boxRow + 3; i++) {
        for (int j = boxCol; j < boxCol + 3; j++) {
          if ((i != row || j != col) && grid[i][j].value == num) {
            isValid = false;
            break;
          }
        }
        if (!isValid) break;
      }
    }

    // Restore the value
    grid[row][col].value = temp;
    return isValid;
  }

  void _clearErrors() {
    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        grid[i][j].hasError = false;
      }
    }
  }

  void _checkCompletion() {
    bool completed = true;
    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        if (grid[i][j].value == null || grid[i][j].hasError) {
          completed = false;
          break;
        }
      }
      if (!completed) break;
    }
    isCompleted = completed;
  }

  void toggleNote(int row, int col, int number) {
    if (grid[row][col].isFixed || grid[row][col].value != null) return;

    if (grid[row][col].notes.contains(number)) {
      grid[row][col].notes.remove(number);
    } else {
      grid[row][col].notes.add(number);
    }
  }

  void useHint() {
    if (hintsUsed >= maxHints) return;

    List<List<int>> emptyCells = [];
    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        if (grid[i][j].value == null && !grid[i][j].isFixed) {
          emptyCells.add([i, j]);
        }
      }
    }

    if (emptyCells.isNotEmpty) {
      emptyCells.shuffle();
      int row = emptyCells[0][0];
      int col = emptyCells[0][1];
      grid[row][col].value = solution[row][col];
      grid[row][col].isFixed = true;
      hintsUsed++;
      _checkCompletion();
    }
  }

  void resetGame() {
    secondsElapsed = 0;
    isPaused = false;
    isCompleted = false;
    hintsUsed = 0;
    _initializeGame();
  }

  void highlightRelated(int row, int col) {
    // Clear existing highlights
    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        grid[i][j].isHighlighted = false;
      }
    }

    // Highlight row
    for (int j = 0; j < 9; j++) {
      grid[row][j].isHighlighted = true;
    }

    // Highlight column
    for (int i = 0; i < 9; i++) {
      grid[i][col].isHighlighted = true;
    }

    // Highlight 3x3 box
    int boxRow = (row ~/ 3) * 3;
    int boxCol = (col ~/ 3) * 3;
    for (int i = boxRow; i < boxRow + 3; i++) {
      for (int j = boxCol; j < boxCol + 3; j++) {
        grid[i][j].isHighlighted = true;
      }
    }
  }

  void clearHighlights() {
    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        grid[i][j].isHighlighted = false;
      }
    }
  }

  // Create SudokuGame from an existing puzzle and solution
  static SudokuGame fromPuzzle({
    required List<List<int?>> initialPuzzle,
    required List<List<int?>> solution,
    required Difficulty difficulty,
  }) {
    // Build grid from initialPuzzle
    final grid = List<List<SudokuCell>>.generate(9, (i) {
      return List<SudokuCell>.generate(9, (j) {
        int? val = (i < initialPuzzle.length && j < initialPuzzle[i].length)
            ? initialPuzzle[i][j]
            : null;
        return SudokuCell(value: val, isFixed: val != null);
      });
    });

    // Ensure solution is 9x9
    final sol = List<List<int?>>.generate(9, (i) {
      return List<int?>.generate(9, (j) {
        return (i < solution.length && j < solution[i].length) ? solution[i][j] : null;
      });
    });

    return SudokuGame._internal(
      difficulty: difficulty,
      grid: grid,
      solution: sol,
    );
  }
}