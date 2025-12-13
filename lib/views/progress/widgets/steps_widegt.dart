import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/steps_controller.dart';

class StepsWidget extends StatelessWidget {
  final StepsController controller = Get.find();

  StepsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final progress = controller.progress();
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade400, Colors.blue.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.shade200,
              blurRadius: 10,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Steps Tracker",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 10,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor: const AlwaysStoppedAnimation(Colors.white),
                  ),
                ),
                Text(
                  "${controller.steps.value}",
                  style: const TextStyle(
                    fontSize: 26,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => controller.addSteps(200),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.blue.shade800,
              ),
              child: const Text("Add 200 Steps"),
            )
          ],
        ),
      );
    });
  }
}
