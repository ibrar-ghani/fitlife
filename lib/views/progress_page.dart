import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import '../controllers/badge_controller.dart';
import '../controllers/goal_controller.dart';

class ProgressPage extends StatefulWidget {
  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  final TextEditingController _progressController = TextEditingController();
  final TextEditingController _goalInputController = TextEditingController();

  final BadgeController badgeController = Get.put(BadgeController());
  final GoalController goalController = Get.put(GoalController());

  List<double> _progressData = [];

  @override
  void initState() {
    super.initState();
    _loadProgressData();
  }

  Future<void> _loadProgressData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getStringList('progressData') ?? [];
    setState(() {
      _progressData = savedData.map((e) => double.parse(e)).toList();
    });
  }

  Future<void> _saveProgressData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'progressData',
      _progressData.map((e) => e.toString()).toList(),
    );
  }

  Future<void> _addProgress() async {
    if (_progressController.text.isNotEmpty) {
      final progress = double.tryParse(_progressController.text);
      if (progress != null) {
        setState(() => _progressData.add(progress));
        await _saveProgressData();
        await badgeController.registerDailyActivity(DateTime.now());
        _progressController.clear();
      } else {
        Get.snackbar('Invalid', 'Please enter a valid number',
            snackPosition: SnackPosition.BOTTOM);
      }
    }
  }

  double _calculateAverage(List<double> data) {
    if (data.isEmpty) return 0;
    return data.reduce((a, b) => a + b) / data.length;
  }

  /// Percent toward goal: based on last entry if present, else 0
  double _percentTowardGoal() {
    final g = goalController.goal.value;
    if (g <= 0 || _progressData.isEmpty) return 0.0;
    final last = _progressData.last;
    final percent = (last / g);
    return percent.clamp(0.0, 1.0);
  }

  String _percentLabel() {
    final g = goalController.goal.value;
    if (g <= 0) return 'Set a daily goal';
    if (_progressData.isEmpty) return 'No entry yet';
    final last = _progressData.last;
    final p = (_percentTowardGoal() * 100).toStringAsFixed(0);
    return '$p% of ${g.toStringAsFixed(1)}';
  }

  Future<void> _saveGoalFromInput() async {
    final text = _goalInputController.text;
    final value = double.tryParse(text);
    if (value != null && value > 0) {
      await goalController.setGoal(value);
      _goalInputController.clear();
      Get.snackbar('Saved', 'Daily goal set to ${value.toStringAsFixed(1)}',
          snackPosition: SnackPosition.BOTTOM);
      setState(() {}); // update percent label immediately
    } else {
      Get.snackbar('Invalid', 'Enter a valid number > 0',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredData = _progressData;
    final average = _calculateAverage(filteredData);

    return Scaffold(
      appBar: AppBar(title: const Text('Progress & Goal')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Goal input card
            Card(
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              color: Colors.purple.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Daily Goal',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(
                      child: TextField(
                        controller: _goalInputController,
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          hintText: 'e.g., 5.0 (km) or 50 (reps)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _saveGoalFromInput,
                      style:
                          ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                      child: const Text('Save', style: TextStyle(color: Colors.white)),
                    ),
                  ]),
                  const SizedBox(height: 10),
                  // Show current goal and clear option
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Obx(() => Text(
                          'Current goal: ${goalController.goal.value <= 0 ? "Not set" : goalController.goal.value.toStringAsFixed(1)}')),
                      TextButton(
                          onPressed: () => goalController.clearGoal(),
                          child: const Text('Clear')),
                    ],
                  ),
                ]),
              ),
            ),

            const SizedBox(height: 16),

            // Badges row (kept small)
            SizedBox(
              height: 140,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                children: [
                  Obx(() => _buildSmallBadge(3, '3-day', Icons.looks_3)),
                  const SizedBox(width: 8),
                  Obx(() => _buildSmallBadge(7, '7-day', Icons.filter_7)),
                  const SizedBox(width: 8),
                  Obx(() => _buildSmallBadge(14, '14-day', Icons.celebration)),
                  const SizedBox(width: 8),
                  // streak card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Container(
                      width: 120,
                      padding: const EdgeInsets.all(12),
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.star, color: Colors.purple, size: 30),
                        const SizedBox(height: 6),
                        const Text('Streak', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Obx(() => Text('${badgeController.streak.value}d')),
                      ]),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Chart
            SizedBox(
              height: 220,
              child: filteredData.isEmpty
                  ? const Center(child: Text('No progress yet — add your first entry.'))
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

            // Goal progress display (percent and bar)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(children: [
                  Row(
                    children: [
                      Expanded(
                          child: Text(
                        _percentLabel(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      )),
                      Obx(() => Text(
                          goalController.goal.value <= 0
                              ? ''
                              : '${(_percentTowardGoal() * 100).toStringAsFixed(0)}%')),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Obx(() => LinearProgressIndicator(
                        value: _percentTowardGoal(),
                        minHeight: 10,
                        backgroundColor: Colors.grey.shade200,
                        color: Colors.purple,
                      )),
                ]),
              ),
            ),

            const SizedBox(height: 16),

            // Add progress input + button
            Row(children: [
              Expanded(
                child: TextField(
                  controller: _progressController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Enter today progress (e.g., 2.5)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(onPressed: () async {
                await _addProgress();
                setState(() {}); // update percent display after adding
              }, child: const Text('Add')),
            ]),

            const SizedBox(height: 16),

            // Summary
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(children: [
                      const Text('Entries'),
                      const SizedBox(height: 6),
                      Text('${filteredData.length}')
                    ]),
                    Column(children: [
                      const Text('Average'),
                      const SizedBox(height: 6),
                      Text('${average.toStringAsFixed(1)}')
                    ]),
                    Column(children: [
                      const Text('Max'),
                      const SizedBox(height: 6),
                      Text('${filteredData.isEmpty ? 0 : filteredData.reduce((a, b) => a > b ? a : b)}')
                    ]),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24), // bottom padding
          ],
        ),
      ),
    );
  }

  Widget _buildSmallBadge(int days, String title, IconData icon) {
    final unlocked = badgeController.hasBadge(days);
    return Card(
      elevation: 3,
      color: unlocked ? Colors.amber.shade100 : Colors.grey.shade100,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 110,
        padding: const EdgeInsets.all(12),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 28, color: unlocked ? Colors.orange : Colors.grey),
          const SizedBox(height: 6),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(unlocked ? 'Unlocked' : 'Locked', style: TextStyle(color: unlocked ? Colors.green : Colors.grey)),
        ]),
      ),
    );
  }
}
