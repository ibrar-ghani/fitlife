// lib/views/progress/widgets/goal_card.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/goal_controller.dart';

class GoalCard extends StatelessWidget {
  GoalCard({Key? key}) : super(key: key);
  final GoalController goal = Get.find();
  final TextEditingController input = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.purple.shade50,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Daily Running Goal (km)", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: input,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'e.g., 5'),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    final val = double.tryParse(input.text);
                    if (val != null && val > 0) {
                      goal.setGoal(val);
                      input.clear();
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                  child: const Text("Save"),
                )
              ],
            ),
            const SizedBox(height: 12),
            Obx(() => Text("Current Goal: ${goal.goal.value <= 0 ? 'Not Set' : '${goal.goal.value} km'}")),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(onPressed: () => goal.clearGoal(), child: const Text("Clear")),
            ),
          ],
        ),
      ),
    );
  }
}
