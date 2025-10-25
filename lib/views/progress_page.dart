import 'package:fitlife/controllers/progress_controoler.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';


class ProgressPage extends StatelessWidget {
  final ProgressController controller = Get.put(ProgressController());
  final TextEditingController weightController = TextEditingController();

  ProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Progress & Motivation")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Obx(() => Text(
                  controller.quote.value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                    color: Colors.deepPurple,
                  ),
                  textAlign: TextAlign.center,
                )),
            const SizedBox(height: 20),
            Expanded(
              child: Obx(() {
                if (controller.progressList.isEmpty) {
                  return const Center(child: Text("No progress yet"));
                }
                return LineChart(
                  LineChartData(
                    titlesData: FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: controller.progressList
                            .asMap()
                            .entries
                            .map((e) => FlSpot(
                                e.key.toDouble(), e.value.weight.toDouble()))
                            .toList(),
                        isCurved: true,
                        dotData: FlDotData(show: true),
                      )
                    ],
                  ),
                );
              }),
            ),
            TextField(
              controller: weightController,
              decoration: const InputDecoration(
                labelText: "Enter today's weight (kg)",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                final weight = double.tryParse(weightController.text);
                if (weight != null) {
                  controller.addProgress(weight);
                  weightController.clear();
                } else {
                  Get.snackbar("Error", "Please enter a valid number");
                }
              },
              child: const Text("Save Progress"),
            ),
          ],
        ),
      ),
    );
  }
}
