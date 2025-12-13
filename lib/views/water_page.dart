import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/water_controller.dart';

class WaterPage extends StatelessWidget {
  final WaterController controller = Get.put(WaterController());

  WaterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Water Tracker"),
        centerTitle: true,
      ),
      body: Obx(() {
        final progress = controller.percent();
        final drank = controller.todayAmount.value;
        final goal = controller.dailyGoal.value;

        return Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Circular Progress Indicator
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: 200,
                      width: 200,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 14,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: const AlwaysStoppedAnimation(Colors.blueAccent),
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          "${drank.toInt()} ml",
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Goal: ${goal.toInt()} ml",
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 35),

                // Quick Add Buttons
                Wrap(
                  spacing: 14,
                  runSpacing: 14,
                  alignment: WrapAlignment.center,
                  children: [200, 300, 500]
                      .map((v) => _addWaterButton("${v} ml", v.toDouble()))
                      .toList(),
                ),

                const SizedBox(height: 30),

                // Set Goal
                ElevatedButton(
                  onPressed: () => _showGoalDialog(context),
                  child: const Text("Set Daily Water Goal"),
                ),

                const SizedBox(height: 10),

                // Reset Today
                TextButton(
                  onPressed: controller.resetToday,
                  child: const Text(
                    "Reset Today",
                    style: TextStyle(color: Colors.redAccent),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _addWaterButton(String label, double value) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: () => controller.addAmount(value),
      child: Text(label, style: const TextStyle(color: Colors.white)),
    );
  }

  void _showGoalDialog(BuildContext context) {
    final TextEditingController goalCtrl =
        TextEditingController(text: controller.dailyGoal.value.toInt().toString());

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Set Daily Water Goal"),
        content: TextField(
          controller: goalCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: "Goal in ml"),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              final g = double.tryParse(goalCtrl.text) ?? 2000;
              if (g > 0) controller.setGoal(g);
              Get.back();
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}
