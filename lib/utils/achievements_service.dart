import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class GameStatsManager {
  final StorageService _storageService = StorageService();
  final AchievementsService _achievementsService = AchievementsService();

  /// Call this when a game is WON
  Future<void> recordWin(String difficulty, String gameTime) async {
    // Update game statistics
    final stats = await _storageService.loadAllStats();

    // Increment wins
    stats[difficulty]!['wins'] = (stats[difficulty]!['wins'] as int) + 1;

    // Update best time if better
    final currentBestTime = stats[difficulty]!['bestTime'] as String;
    if (currentBestTime == '--:--' || _isTimeBetter(gameTime, currentBestTime)) {
      stats[difficulty]!['bestTime'] = gameTime;
    }

    // Calculate and update progress (based on games played)
    stats[difficulty]!['progress'] = _calculateProgress(
      stats[difficulty]!['wins'] as int,
    );

    // Save updated stats
    await _storageService.saveStats(stats);

    // Update achievements
    await _updateAchievements('win', difficulty, gameTime);
  }

  /// Call this when a game is QUIT
  Future<void> recordQuit(String difficulty) async {
    // Update game statistics
    final stats = await _storageService.loadAllStats();

    // Just update progress (based on games played)
    stats[difficulty]!['progress'] = _calculateProgress(
      stats[difficulty]!['wins'] as int,
    );

    // Save updated stats
    await _storageService.saveStats(stats);

    // Update achievements for games played
    await _updateAchievements('quit', difficulty);
  }

  /// Calculate progress based only on total wins
  double _calculateProgress(int wins) {
    // Example: progress = wins / 100 (100 wins = 100%)
    return (wins / 100.0).clamp(0.0, 1.0);
  }

  /// Check if new time is better than current best time
  bool _isTimeBetter(String newTime, String currentBest) {
    if (currentBest == '--:--') return true;

    final newSeconds = _timeToSeconds(newTime);
    final currentSeconds = _timeToSeconds(currentBest);

    return newSeconds < currentSeconds;
  }

  /// Convert time string (MM:SS) to seconds
  int _timeToSeconds(String timeStr) {
    final parts = timeStr.split(':');
    if (parts.length != 2) return 9999; // Invalid format

    final minutes = int.tryParse(parts[0]) ?? 0;
    final seconds = int.tryParse(parts[1]) ?? 0;

    return minutes * 60 + seconds;
  }

  /// Update achievements based on game events
  Future<void> _updateAchievements(String event, String difficulty, [String? gameTime]) async {
    await _achievementsService.loadAchievements();

    try {
      if (event == 'win') {
        // Update "First Victory" achievement
        await _achievementsService.updateAchievement('first_win', 1);

        // Check for speed runner achievement (under 5 minutes)
        if (gameTime != null && _timeToSeconds(gameTime) < 300) {
          await _achievementsService.updateAchievement('fast_finish', 1);
        }
      }

      // Update games played achievement (both win and quit count as games played)
      await _achievementsService.updateAchievement('ten_games', 1);

    } catch (e) {
      // Achievement not found or already completed - continue silently
      print('Achievement update error: $e');
    }
  }

  /// Get current stats for achievements screen
  Future<Map<String, Map<String, dynamic>>> getGameStats() async {
    return await _storageService.loadAllStats();
  }

  /// Reset all statistics and achievements (for testing)
  Future<void> resetAll() async {
    await _storageService.resetAllStats();
    await _achievementsService.resetAchievements();
  }
}

// StorageService (no "quits")
class StorageService {
  static const _statsKey = "game_stats_data";

  final Map<String, Map<String, dynamic>> _defaultStats = {
    "Easy": {
      "wins": 0,
      "bestTime": "--:--",
      "progress": 0.0,
    },
    "Medium": {
      "wins": 0,
      "bestTime": "--:--",
      "progress": 0.0,
    },
    "Hard": {
      "wins": 0,
      "bestTime": "--:--",
      "progress": 0.0,
    },
    "Master": {
      "wins": 0,
      "bestTime": "--:--",
      "progress": 0.0,
    },
  };

  Future<Map<String, Map<String, dynamic>>> loadAllStats() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_statsKey);

    if (jsonString != null) {
      try {
        final decodedData = Map<String, dynamic>.from(jsonDecode(jsonString));
        final Map<String, Map<String, dynamic>> mergedData = Map.from(_defaultStats);
        decodedData.forEach((key, value) {
          if (mergedData.containsKey(key)) {
            mergedData[key] = Map<String, dynamic>.from(value);
          }
        });
        return mergedData;
      } catch (e) {
        // If JSON is corrupted, reset to defaults
        return _defaultStats;
      }
    }

    return _defaultStats;
  }

  Future<void> saveStats(Map<String, Map<String, dynamic>> stats) async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonString = jsonEncode(stats);
    await prefs.setString(_statsKey, jsonString);
  }

  Future<void> updateStat(String level, String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, Map<String, dynamic>> currentStats = await loadAllStats();

    if (currentStats.containsKey(level)) {
      currentStats[level]![key] = value;
      await saveStats(currentStats);
    }
  }

  Future<void> resetAllStats() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_statsKey);
  }
}

// AchievementsService (unchanged)
class Achievement {
  final String id;
  final String title;
  final String description;
  final int goal;
  int progress;
  bool completed;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.goal,
    this.progress = 0,
    this.completed = false,
  });

  void updateProgress(int value) {
    progress += value;
    if (progress >= goal) {
      progress = goal;
      completed = true;
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'goal': goal,
    'progress': progress,
    'completed': completed,
  };

  factory Achievement.fromJson(Map<String, dynamic> json) => Achievement(
    id: json['id'],
    title: json['title'],
    description: json['description'],
    goal: json['goal'],
    progress: json['progress'],
    completed: json['completed'],
  );
}

class AchievementsService {
  static const _storageKey = 'achievements';

  List<Achievement> _achievements = [
    Achievement(
      id: 'first_win',
      title: 'First Victory',
      description: 'Win your first Sudoku game',
      goal: 1,
    ),
    Achievement(
      id: 'ten_games',
      title: 'Sudoku Explorer',
      description: 'Complete 10 games',
      goal: 10,
    ),
    Achievement(
      id: 'fast_finish',
      title: 'Speed Runner',
      description: 'Complete a game in under 5 minutes',
      goal: 1,
    ),
  ];

  Future<void> loadAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_storageKey);

    if (data != null) {
      try {
        final List<dynamic> decoded = jsonDecode(data);
        _achievements = decoded.map((e) => Achievement.fromJson(e)).toList();
      } catch (e) {
        // If decode fails, reset achievements
        _achievements = [
          Achievement(
            id: 'first_win',
            title: 'First Victory',
            description: 'Win your first Sudoku game',
            goal: 1,
          ),
          Achievement(
            id: 'ten_games',
            title: 'Sudoku Explorer',
            description: 'Complete 10 games',
            goal: 10,
          ),
          Achievement(
            id: 'fast_finish',
            title: 'Speed Runner',
            description: 'Complete a game in under 5 minutes',
            goal: 1,
          ),
        ];
      }
    }
  }

  Future<void> _saveAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_achievements.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }

  List<Achievement> getAchievements() => _achievements;

  Future<void> updateAchievement(String id, int value) async {
    final achievement = _achievements.firstWhere(
            (a) => a.id == id,
        orElse: () => throw Exception('Achievement not found'));

    achievement.updateProgress(value);
    await _saveAchievements();
  }

  Future<void> resetAchievements() async {
    for (var a in _achievements) {
      a.progress = 0;
      a.completed = false;
    }
    await _saveAchievements();
  }
}
