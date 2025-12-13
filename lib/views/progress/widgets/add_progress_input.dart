import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/progress_controoler.dart';
import '../../../controllers/badge_controller.dart';

class AddProgressInput extends StatelessWidget {
  AddProgressInput({super.key});

  final TextEditingController input = TextEditingController();
  final ProgressController progressController = Get.find<ProgressController>();
  final BadgeController badgeController = Get.find<BadgeController>();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: input,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: "Today's Run (km)",
            ),
          ),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: () async {
            final value = double.tryParse(input.text);

            if (value == null || value <= 0) {
              Get.snackbar(
                "Invalid input",
                "Please enter a valid distance",
                snackPosition: SnackPosition.BOTTOM,
              );
              return;
            }

            await progressController.addProgress(value);
            await badgeController.registerDailyActivity(DateTime.now());

            input.clear();

            Get.snackbar(
              "Progress Added 🎉",
              "You ran $value km today!",
              snackPosition: SnackPosition.BOTTOM,
            );
          },
          child: const Text("Add"),
        ),
      ],
    );
  }
}
