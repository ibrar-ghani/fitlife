import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/progress_controoler.dart';
import '../../../controllers/goal_controller.dart';

class ProgressSummary extends StatelessWidget {
  ProgressSummary({Key? key}) : super(key: key);

  final ProgressController progressController = Get.find();
  final GoalController goalController = Get.find();

  double completionPercent() {
    final g = goalController.goal.value;
    if (g <= 0 || progressController.progressList.isEmpty) return 0.0;
    final last = progressController.progressList.last;
    return (last / g).clamp(0.0, 1.0);
  }

  String completionLabel() {
    final g = goalController.goal.value;
    if (g <= 0) return 'Set a daily goal';
    if (progressController.progressList.isEmpty) return 'No entry yet';
    return '${(completionPercent() * 100).toStringAsFixed(0)}% of ${g.toStringAsFixed(1)} km';
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final data = progressController.progressList;
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text('Progress Summary',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  IconButton(
                    onPressed: () {}, // refresh not needed, reactive
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Refresh summary',
                  )
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _smallStat('Entries', progressController.entries.toString()),
                  _smallStat('Average', '${progressController.average.toStringAsFixed(2)} km'),
                  _smallStat('Max', '${progressController.maxValue.toStringAsFixed(2)} km'),
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
            ],
          ),
        ),
      );
    });
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
