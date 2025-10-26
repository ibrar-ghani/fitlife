import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProgressPage extends StatefulWidget {
  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  final TextEditingController _progressController = TextEditingController();
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

  void _addProgress() {
    if (_progressController.text.isNotEmpty) {
      final progress = double.tryParse(_progressController.text);
      if (progress != null) {
        setState(() {
          _progressData.add(progress);
        });
        _saveProgressData();
        _progressController.clear();
      }
    }
  }

  double _calculateAverage() {
    if (_progressData.isEmpty) return 0;
    return _progressData.reduce((a, b) => a + b) / _progressData.length;
  }

  @override
  Widget build(BuildContext context) {
    final average = _calculateAverage();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Daily Progress Tracker',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _progressData.isEmpty
                  ? const Center(
                      child: Text(
                        'No progress yet. Add your first entry!',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : LineChart(
                      LineChartData(
                        lineTouchData: LineTouchData(
                          enabled: true,
                          touchTooltipData: LineTouchTooltipData(
                            tooltipBorder: BorderSide(color: Colors.purple.withOpacity(0.8)),
                            tooltipPadding: const EdgeInsets.all(8),
                            getTooltipItems: (touchedSpots) {
                              return touchedSpots.map((spot) {
                                return LineTooltipItem(
                                  'Day ${spot.x.toInt() + 1}\nProgress: ${spot.y.toStringAsFixed(1)}',
                                  const TextStyle(color: Colors.white),
                                );
                              }).toList();
                            },
                          ),
                        ),
                        gridData: FlGridData(show: true),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: true),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: true),
                          ),
                        ),
                        borderData: FlBorderData(show: true),
                        lineBarsData: [
                          LineChartBarData(
                            spots: _progressData.asMap().entries.map((e) {
                              return FlSpot(e.key.toDouble(), e.value);
                            }).toList(),
                            isCurved: true,
                            color: Colors.purple,
                            barWidth: 3,
                            dotData: FlDotData(show: true),
                            belowBarData: BarAreaData(
                              show: true,
                              color: Colors.purple.withOpacity(0.2),
                            ),
                          ),
                          // Weekly Average Line
                          LineChartBarData(
                            spots: List.generate(
                              _progressData.length,
                              (index) => FlSpot(index.toDouble(), average),
                            ),
                            isCurved: false,
                            color: Colors.green,
                            barWidth: 2,
                            dashArray: [5, 5],
                            dotData: FlDotData(show: false),
                          ),
                        ],
                      ),
                      duration: const Duration(milliseconds: 600),
                    ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _progressController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Enter today\'s progress (e.g., 2.5 km)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addProgress,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
              ),
              child: const Text(
                'Add Progress',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
