import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StorageService {
  static const _statsKey = "game_stats_data";

  // Default, empty stats data to use if no data is found in storage.
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

  /// Loads all game stats for every difficulty level from SharedPreferences.
  Future<Map<String, Map<String, dynamic>>> loadAllStats() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_statsKey);

    if (jsonString != null) {
      // Decode the JSON string back into a Map
      final decodedData = Map<String, dynamic>.from(jsonDecode(jsonString));

      // This ensures we have all difficulty levels, even if some were not saved yet.
      final Map<String, Map<String, dynamic>> mergedData = Map.from(_defaultStats);
      decodedData.forEach((key, value) {
        if (mergedData.containsKey(key)) {
          mergedData[key] = Map<String, dynamic>.from(value);
        }
      });
      return mergedData;
    }

    // If no data is found, return the default stats
    return _defaultStats;
  }

  /// Saves the updated game stats to SharedPreferences.
  Future<void> saveStats(Map<String, Map<String, dynamic>> stats) async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonString = jsonEncode(stats);
    await prefs.setString(_statsKey, jsonString);
  }

  /// Updates a specific stat (e.g., 'wins' for 'Easy' difficulty)
  Future<void> updateStat(String level, String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, Map<String, dynamic>> currentStats = await loadAllStats();

    if (currentStats.containsKey(level)) {
      currentStats[level]![key] = value;
      await saveStats(currentStats);
    }
  }

  /// Resets all stats (for testing or game reset feature).
  Future<void> resetAllStats() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_statsKey);
  }
}