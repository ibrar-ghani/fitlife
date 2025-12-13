import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import '../../../controllers/progress_controoler.dart';

class ProgressChart extends StatelessWidget {
  ProgressChart({super.key});

  final ProgressController controller = Get.find<ProgressController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const SizedBox(
          height: 220,
          child: Center(child: CircularProgressIndicator()),
        );
      }

      if (controller.progressList.isEmpty) {
        return const SizedBox(
          height: 220,
          child: Center(child: Text("Add your first progress entry 🚀")),
        );
      }

      final data = controller.progressList;

      return SizedBox(
        height: 220,
        child: LineChart(
          LineChartData(
            gridData: FlGridData(show: true),
            lineBarsData: [
              LineChartBarData(
                isCurved: true,
                spots: data
                    .asMap()
                    .entries
                    .map(
                      (e) => FlSpot(
                        e.key.toDouble(),
                        e.value,
                      ),
                    )
                    .toList(),
                barWidth: 3,
                color: Colors.purple,
                dotData: const FlDotData(show: true),
                belowBarData: BarAreaData(
                  show: true,
                  color: Colors.purple.withOpacity(0.2),
                ),
              ),
            ],
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  getTitlesWidget: (value, meta) =>
                      Text('${value.toInt() + 1}'),
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: _calculateInterval(data),
                  getTitlesWidget: (value, meta) =>
                      Text(value.toStringAsFixed(1)),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  double _calculateInterval(List<double> data) {
    final max = data.reduce((a, b) => a > b ? a : b);
    return max <= 0 ? 1 : (max / 5);
  }
}
