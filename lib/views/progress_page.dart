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
  String _selectedFilter = "All Time";

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

  List<double> _getFilteredData() {
    if (_selectedFilter == "Last 7 Days") {
      return _progressData.takeLast(7);
    } else if (_selectedFilter == "Last 30 Days") {
      return _progressData.takeLast(30);
    }
    return _progressData;
  }

  double _calculateAverage(List<double> data) {
    if (data.isEmpty) return 0;
    return data.reduce((a, b) => a + b) / data.length;
  }

  @override
  Widget build(BuildContext context) {
    final filteredData = _getFilteredData();
    final average = _calculateAverage(filteredData);
    final maxProgress = filteredData.isEmpty ? 0 : filteredData.reduce((a, b) => a > b ? a : b);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Daily Progress Tracker',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            // Dropdown filter
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.filter_alt, color: Colors.purple),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: _selectedFilter,
                  items: const [
                    DropdownMenuItem(value: "All Time", child: Text("All Time")),
                    DropdownMenuItem(value: "Last 7 Days", child: Text("Last 7 Days")),
                    DropdownMenuItem(value: "Last 30 Days", child: Text("Last 30 Days")),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedFilter = value!);
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Summary card
            Card(
              color: Colors.purple.shade50,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'Summary (${_selectedFilter})',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildSummaryItem('Entries', filteredData.length.toString()),
                        _buildSummaryItem('Average', '${average.toStringAsFixed(1)}'),
                        _buildSummaryItem('Max', '${maxProgress.toStringAsFixed(1)}'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: filteredData.isEmpty
                  ? const Center(
                      child: Text('No data available for this range.'),
                    )
                  : LineChart(
                      LineChartData(
                        gridData: FlGridData(show: true),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                        ),
                        borderData: FlBorderData(show: true),
                        lineBarsData: [
                          LineChartBarData(
                            spots: filteredData.asMap().entries.map((e) {
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
                        ],
                      ),
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
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
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

  Widget _buildSummaryItem(String title, String value) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 16)),
      ],
    );
  }
}

extension TakeLastExtension<E> on List<E> {
  List<E> takeLast(int n) => length <= n ? this : sublist(length - n);
}
