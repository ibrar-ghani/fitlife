// lib/views/progress/widgets/progress_summary.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../controllers/goal_controller.dart';

class ProgressSummary extends StatefulWidget {
  const ProgressSummary({Key? key}) : super(key: key);

  @override
  State<ProgressSummary> createState() => _ProgressSummaryState();
}

class _ProgressSummaryState extends State<ProgressSummary> {
  final GoalController goalController = Get.find();
  List<double> _data = [];

  @override
  void initState() {
    super.initState();
    _loadData();
    // reload when goal changes so completion % updates immediately
    ever<double>(goalController.goal, (_) => _loadData());
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('progressData') ?? [];
    setState(() {
      _data = saved.map((e) {
        final parsed = double.tryParse(e);
        return parsed ?? 0.0;
      }).where((v) => v >= 0).toList();
    });
  }

  int get entries => _data.length;
  double get average => _data.isEmpty ? 0.0 : _data.reduce((a, b) => a + b) / _data.length;
  double get maxValue => _data.isEmpty ? 0.0 : _data.reduce((a, b) => a > b ? a : b);

  /// Completion percentage based on last entry vs goal
  double completionPercent() {
    final g = goalController.goal.value;
    if (g <= 0 || _data.isEmpty) return 0.0;
    final last = _data.last;
    return (last / g).clamp(0.0, 1.0);
  }

  String completionLabel() {
    final g = goalController.goal.value;
    if (g <= 0) return 'Set a daily goal';
    if (_data.isEmpty) return 'No entry yet';
    return '${(completionPercent() * 100).toStringAsFixed(0)}% of ${g.toStringAsFixed(1)} km';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            children: [
              const Expanded(child: Text('Progress Summary', style: TextStyle(fontWeight: FontWeight.bold))),
              IconButton(
                onPressed: _loadData,
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh summary',
              )
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _smallStat('Entries', entries.toString()),
              _smallStat('Average', average.toStringAsFixed(2) + ' km'),
              _smallStat('Max', maxValue.toStringAsFixed(2) + ' km'),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          Text(completionLabel(), style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: completionPercent(),
            minHeight: 10,
            backgroundColor: Colors.grey.shade200,
            color: Colors.purple,
          ),
        ]),
      ),
    );
  }

  Widget _smallStat(String title, String value) {
    return Column(
      children: [
        Text(title, style: const TextStyle(color: Colors.black54)),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
