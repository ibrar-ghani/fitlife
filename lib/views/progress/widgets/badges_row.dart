import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/badge_controller.dart';

class BadgesRow extends StatelessWidget {
  BadgesRow({super.key});

  final BadgeController badgeController = Get.find<BadgeController>();

  Widget badgeCard(int days, String label, IconData icon) {
    return Obx(() {
      final unlocked = badgeController.hasBadge(days);

      return Card(
        color: unlocked ? Colors.amber.shade100 : Colors.grey.shade200,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: SizedBox(
          width: 100,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: unlocked ? Colors.orange : Colors.grey,
                  size: 28,
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  unlocked ? "Unlocked" : "Locked",
                  style: TextStyle(
                    color: unlocked ? Colors.green : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 130,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          badgeCard(3, "3 Days", Icons.looks_3),
          const SizedBox(width: 8),
          badgeCard(7, "7 Days", Icons.filter_7),
          const SizedBox(width: 8),
          badgeCard(14, "14 Days", Icons.celebration),
        ],
      ),
    );
  }
}
