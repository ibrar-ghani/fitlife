// lib/views/progress/widgets/progress_chart.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProgressChart extends StatefulWidget {
  const ProgressChart({Key? key}) : super(key: key);

  @override
  State<ProgressChart> createState() => _ProgressChartState();
}

class _ProgressChartState extends State<ProgressChart> {
  List<double> data = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('progressData') ?? [];
    setState(() => data = saved.map((e) => double.parse(e)).toList());
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: data.isEmpty
          ? const Center(child: Text("Add your first km run!"))
          : LineChart(
              LineChartData(
                lineBarsData: [
                  LineChartBarData(
                    isCurved: true,
                    spots: data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                    color: Colors.purple,
                    barWidth: 3,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(show: true, color: Colors.purpleAccent.withOpacity(0.2)),
                  )
                ],
              ),
            ),
    );
  }
}
