// lib/views/progress/widgets/water_tracker_card.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/water_controller.dart';

class WaterTrackerCard extends StatelessWidget {
  WaterTrackerCard({Key? key}) : super(key: key);
  final WaterController water = Get.find();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                Obx(() => Text(
                      "Water: ${water.todayAmount.value.toStringAsFixed(0)} / ${water.dailyGoal.value.toStringAsFixed(0)} ml",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    )),
                const Spacer(),
                Obx(() => CircularProgressIndicator(
                      value: water.percent(),
                      color: Colors.blue,
                      strokeWidth: 6,
                    )),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton(onPressed: () => water.addAmount(250), child: const Text("+250 ml")),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: () => water.addAmount(500), child: const Text("+500 ml")),
                const Spacer(),
                TextButton(onPressed: () => water.resetToday(), child: const Text("Reset")),
              ],
            )
          ],
        ),
      ),
    );
  }
}
