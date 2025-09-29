import 'dart:ui';
import 'package:flutter/material.dart';

class AchievementsScreen extends StatefulWidget {
  // Holds the game stats data
  final Map<String, Map<String, dynamic>>? gameStats;

  const AchievementsScreen({super.key, this.gameStats});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  String selectedLevel = "Easy";
  final List<String> levels = ["Easy", "Medium", "Hard", "Master"];

  // ✅ Default stats (without quits)
  final Map<String, Map<String, dynamic>> defaultStats = {
    "Easy": {"wins": 0, "bestTime": "--:--", "progress": 0.0},
    "Medium": {"wins": 0, "bestTime": "--:--", "progress": 0.0},
    "Hard": {"wins": 0, "bestTime": "--:--", "progress": 0.0},
    "Master": {"wins": 0, "bestTime": "--:--", "progress": 0.0},
  };

  late int wins;
  late String bestTime;
  late double progress;

  @override
  void initState() {
    super.initState();
    _loadStatsFor(selectedLevel);
  }

  void _loadStatsFor(String level) {
    final gameData = widget.gameStats ?? defaultStats;
    final stats = gameData[level]!;
    setState(() {
      wins = stats["wins"];
      bestTime = stats["bestTime"];
      progress = stats["progress"];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Achievements",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Difficulty Tabs
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: levels.map((level) {
                final bool isSelected = selectedLevel == level;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedLevel = level;
                      _loadStatsFor(level);
                    });
                  },
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.black.withOpacity(0.7)
                          : Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      level,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : Colors.black54,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 30),
            // Stats Card
            _glassContainer(
              child: Column(
                children: [
                  const Text(
                    "Stats",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _StatRow(label: "Wins", value: wins.toString()),
                  _StatRow(label: "Best Time", value: bestTime),
                ],
              ),
            ),
            const SizedBox(height: 30),
            // Progress Bar
            _glassContainer(
              child: Column(
                children: [
                  const Text(
                    "Progress",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 15),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 12,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.blueAccent,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${(progress * 100).toStringAsFixed(0)}%",
                    style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _glassContainer({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.1), width: 1),
        color: Colors.black.withOpacity(0.05),
      ),
      child: child,
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: Colors.black87, fontSize: 16)),
          Text(value,
              style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
