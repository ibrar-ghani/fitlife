import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import '../controllers/badge_controller.dart';

class ProgressPage extends StatefulWidget {
  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  final TextEditingController _progressController = TextEditingController();
  final BadgeController badgeController = Get.put(BadgeController());

  List<double> _progressData = [];

  @override
  void initState() {
    super.initState();
    _loadProgressData();
  }

  // Load saved progress from SharedPreferences
  Future<void> _loadProgressData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getStringList('progressData') ?? [];
    setState(() {
      _progressData = savedData.map((e) => double.parse(e)).toList();
    });
  }

  // Save progress to SharedPreferences
  Future<void> _saveProgressData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'progressData',
      _progressData.map((e) => e.toString()).toList(),
    );
  }

  // Add new progress entry
  Future<void> _addProgress() async {
    if (_progressController.text.isNotEmpty) {
      final progress = double.tryParse(_progressController.text);
      if (progress != null) {
        setState(() => _progressData.add(progress));
        await _saveProgressData();
        await badgeController.registerDailyActivity(DateTime.now());
        _progressController.clear();
      } else {
        Get.snackbar(
          'Invalid',
          'Please enter a valid number',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  // Calculate average of progress
  double _calculateAverage(List<double> data) {
    if (data.isEmpty) return 0;
    return data.reduce((a, b) => a + b) / data.length;
  }

  // Badge card widget
  Widget _buildBadgeCard(int days, String title, IconData icon) {
    return Obx(() {
      final isUnlocked = badgeController.hasBadge(days);
      return Card(
        elevation: 3,
        color: isUnlocked ? Colors.amber.shade100 : Colors.grey.shade100,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: 110,
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 36, color: isUnlocked ? Colors.orange : Colors.grey),
              const SizedBox(height: 8),
              Text(title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(isUnlocked ? 'Unlocked' : 'Locked',
                  style: TextStyle(color: isUnlocked ? Colors.green : Colors.grey)),
            ],
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredData = _progressData;
    final average = _calculateAverage(filteredData);

    return Scaffold(
      appBar: AppBar(title: const Text('Progress & Badges')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badges row
            SizedBox(
              height: 160,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                children: [
                  _buildBadgeCard(3, '3-Day Streak', Icons.looks_3),
                  const SizedBox(width: 8),
                  _buildBadgeCard(7, '7-Day Streak', Icons.filter_7),
                  const SizedBox(width: 8),
                  _buildBadgeCard(14, '14-Day Streak', Icons.celebration),
                  const SizedBox(width: 8),
                  // Streak summary card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Container(
                      width: 140,
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, color: Colors.purple, size: 36),
                          const SizedBox(height: 8),
                          const Text('Streak', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Obx(() => Text('${badgeController.streak.value} days',
                              style: const TextStyle(fontSize: 16))),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Chart
            SizedBox(
              height: 250,
              child: filteredData.isEmpty
                  ? const Center(child: Text('No progress yet, add your first entry!'))
                  : LineChart(
                      LineChartData(
                        lineTouchData: LineTouchData(enabled: true),
                        gridData: FlGridData(show: true),
                        titlesData: FlTitlesData(show: true),
                        borderData: FlBorderData(show: true),
                        lineBarsData: [
                          LineChartBarData(
                            spots: filteredData
                                .asMap()
                                .entries
                                .map((e) => FlSpot(e.key.toDouble(), e.value))
                                .toList(),
                            isCurved: true,
                            color: Colors.purple,
                            barWidth: 3,
                            dotData: const FlDotData(show: true),
                            belowBarData: BarAreaData(
                              show: true,
                              color: Colors.purple.withOpacity(0.2),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),

            const SizedBox(height: 16),

            // Input row
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _progressController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Enter progress (e.g., km or reps)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(onPressed: _addProgress, child: const Text('Add')),
              ],
            ),

            const SizedBox(height: 16),

            // Summary card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        const Text('Entries'),
                        const SizedBox(height: 6),
                        Text('${filteredData.length}'),
                      ],
                    ),
                    Column(
                      children: [
                        const Text('Average'),
                        const SizedBox(height: 6),
                        Text('${average.toStringAsFixed(1)}'),
                      ],
                    ),
                    Column(
                      children: [
                        const Text('Max'),
                        const SizedBox(height: 6),
                        Text('${filteredData.isEmpty ? 0 : filteredData.reduce((a, b) => a > b ? a : b)}'),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20), // extra space to prevent overflow
          ],
        ),
      ),
    );
  }
}
