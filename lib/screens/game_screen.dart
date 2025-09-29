import 'dart:async';
import 'package:flutter/material.dart';
import '../models/sudoku_game.dart';
import 'widgets/sudoku_grid.dart';
import 'widgets/number_pad.dart';
import '../utils/achievements_service.dart';

class DailyChallenge {
  final String id;
  final List<List<int?>>? puzzle;
  final List<List<int?>>? solution;
  final String difficulty;

  DailyChallenge({
    required this.id,
    this.puzzle,
    this.solution,
    this.difficulty = 'medium',
  });
}

class GameScreen extends StatefulWidget {
  final bool isDailyChallenge;
  final DailyChallenge? dailyChallenge;
  final String difficulty;
  final List<List<int?>>? initialPuzzle;
  final List<List<int?>>? solution;

  const GameScreen({
    Key? key,
    this.isDailyChallenge = false,
    this.dailyChallenge,
    required this.difficulty,
    this.initialPuzzle,
    this.solution,
  }) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late SudokuGame game;
  Timer? timer;
  int? selectedRow;
  int? selectedCol;
  bool isNoteMode = false;

  // Add GameStatsManager instance
  final GameStatsManager _gameStatsManager = GameStatsManager();
  bool _gameWasCompleted = false; // Track if game was completed to avoid double-recording

  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeGame();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeGame() {
    game = SudokuGame(difficulty: _getDifficultyFromString(widget.difficulty));
    _gameWasCompleted = false; // Reset completion flag for new game
    _startTimer();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _fadeController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _scaleController.forward();
  }

  Difficulty _getDifficultyFromString(String difficultyString) {
    switch (difficultyString.toLowerCase()) {
      case 'easy':
        return Difficulty.easy;
      case 'medium':
        return Difficulty.medium;
      case 'hard':
        return Difficulty.hard;
      case 'expert':
      case 'extreme':
      case 'master':
        return Difficulty.extreme;
      default:
        return Difficulty.medium;
    }
  }

  void _startTimer() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      if (!mounted) return;
      if (!game.isPaused && !game.isCompleted) {
        setState(() {
          game.secondsElapsed++;
        });
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _onCellTapped(int row, int col) {
    setState(() {
      selectedRow = row;
      selectedCol = col;
      game.highlightRelated(row, col);
    });
  }

  void _onNumberSelected(int number) {
    if (selectedRow == null || selectedCol == null) return;
    setState(() {
      if (isNoteMode) {
        game.toggleNote(selectedRow!, selectedCol!, number);
      } else {
        game.makeMove(selectedRow!, selectedCol!, number);
        if (game.isCompleted && !_gameWasCompleted) {
          _gameWasCompleted = true; // Prevent double recording
          _showCompletionDialog();
        }
      }
    });
  }

  void _onErasePressed() {
    if (selectedRow == null || selectedCol == null) return;
    setState(() {
      game.makeMove(selectedRow!, selectedCol!, null);
      if (game.isCompleted && !_gameWasCompleted) {
        _gameWasCompleted = true; // Prevent double recording
        _showCompletionDialog();
      }
    });
  }

  void _toggleNoteMode() {
    setState(() {
      isNoteMode = !isNoteMode;
    });
  }

  void _useHint() {
    setState(() {
      game.useHint();
      if (game.isCompleted && !_gameWasCompleted) {
        _gameWasCompleted = true; // Prevent double recording
        _showCompletionDialog();
      }
    });
  }

  void _pauseGame() {
    setState(() {
      game.isPaused = !game.isPaused;
    });
  }

  void _newGame() {
    setState(() {
      game.resetGame();
      selectedRow = null;
      selectedCol = null;
      isNoteMode = false;
      _gameWasCompleted = false; // Reset completion flag
      timer?.cancel();
      _startTimer();
    });
  }

  // UPDATED: Record win achievement when game is completed
  void _showCompletionDialog() async {
    // Record the win in achievements
    final gameTime = _formatTime(game.secondsElapsed);
    final difficulty = _getDifficultyForAchievements();

    try {
      await _gameStatsManager.recordWin(difficulty, gameTime);
    } catch (e) {
      print('Error recording win: $e');
    }

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Congratulations!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Puzzle completed!'),
              const SizedBox(height: 16),
              Text('Time: ${_formatTime(game.secondsElapsed)}'),
              Text('Hints used: ${game.hintsUsed}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // close dialog
                _newGame();
              },
              child: const Text('New Game'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // close dialog
                Navigator.of(context).pop(); // back to menu
              },
              child: const Text('Back to Menu'),
            ),
          ],
        );
      },
    );
  }

  // UPDATED: Record quit achievement when back button is pressed
  void _onBackButtonPressed() async {
    // Only record quit if game was in progress and not completed
    if (!_gameWasCompleted && game.secondsElapsed > 0) {
      final difficulty = _getDifficultyForAchievements();

      try {
        await _gameStatsManager.recordQuit(difficulty);
      } catch (e) {
        print('Error recording quit: $e');
      }
    }

    if (!mounted) return;
    Navigator.pop(context);
  }

  // Helper method to convert widget.difficulty to the format expected by achievements
  String _getDifficultyForAchievements() {
    switch (widget.difficulty.toLowerCase()) {
      case 'easy':
        return 'Easy';
      case 'medium':
        return 'Medium';
      case 'hard':
        return 'Hard';
      case 'expert':
      case 'extreme':
      case 'master':
        return 'Master';
      default:
        return 'Medium';
    }
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Expanded(
                          flex: 3,
                          child: ScaleTransition(
                            scale: _scaleAnimation,
                            child: SudokuGrid(
                              game: game,
                              selectedRow: selectedRow,
                              selectedCol: selectedCol,
                              onCellTapped: _onCellTapped,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildGameControls(),
                        const SizedBox(height: 16),
                        Expanded(
                          flex: 1,
                          child: ScaleTransition(
                            scale: _scaleAnimation,
                            child: NumberPad(
                              onNumberSelected: _onNumberSelected,
                              onErasePressed: _onErasePressed,
                              isNoteMode: isNoteMode,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // UPDATED: Use the new _onBackButtonPressed method
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: _onBackButtonPressed, // CHANGED: Now records quit
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  _getDifficultyDisplayName(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  _formatTime(game.secondsElapsed),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _pauseGame,
            icon: Icon(
              game.isPaused ? Icons.play_arrow : Icons.pause,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  String _getDifficultyDisplayName() {
    final n = widget.difficulty;
    return n.substring(0, 1).toUpperCase() + n.substring(1);
  }

  Widget _buildGameControls() {
    final remainingHints = (game.maxHints - game.hintsUsed).clamp(0, game.maxHints);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildControlButton(
          icon: Icons.edit_note,
          label: 'Notes',
          isActive: isNoteMode,
          onPressed: _toggleNoteMode,
        ),
        _buildControlButton(
          icon: Icons.lightbulb_outline,
          label: 'Hint (${remainingHints})',
          isActive: false,
          onPressed: remainingHints <= 0 ? null : _useHint,
        ),
        _buildControlButton(
          icon: Icons.refresh,
          label: 'New Game',
          isActive: false,
          onPressed: _newGame,
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required bool isActive,
    VoidCallback? onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.blue.withOpacity(0.8) : Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: onPressed == null ? Colors.white.withOpacity(0.3) : Colors.white,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: onPressed == null ? Colors.white.withOpacity(0.3) : Colors.white,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}