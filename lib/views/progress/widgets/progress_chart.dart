import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import '../../../controllers/auth_controller.dart';
import '../../../controllers/goal_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProgressChart extends StatefulWidget {
  const ProgressChart({Key? key}) : super(key: key);

  @override
  State<ProgressChart> createState() => _ProgressChartState();
}

class _ProgressChartState extends State<ProgressChart> {
  final AuthController auth = Get.find();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RxList<double> data = <double>[].obs;

  String get _progressPath => 'users/${auth.user?.uid}/progress/entries';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (auth.user == null) return;

    try {
      final snapshot = await _firestore.collection(_progressPath).get();
      final progress = snapshot.docs.map((doc) {
        final val = doc.data()['value'];
        return val is num ? val.toDouble() : 0.0;
      }).where((v) => v >= 0).toList();

      data.assignAll(progress);
    } catch (e) {
      print("Error loading progress chart: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
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
                      belowBarData: BarAreaData(
                          show: true, color: Colors.purpleAccent.withOpacity(0.2)),
                    ),
                  ],
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      interval: 1,
                      getTitlesWidget: (value, meta) => Text('${value.toInt() + 1}'),
                    )),
                    leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: data.isEmpty ? 1 : (data.reduce((a, b) => a > b ? a : b) / 5),
                      getTitlesWidget: (value, meta) => Text(value.toStringAsFixed(1)),
                    )),
                  ),
                ),
              ),
      );
    });
  }
}
