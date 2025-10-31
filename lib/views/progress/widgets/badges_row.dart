// lib/views/progress/widgets/badges_row.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/badge_controller.dart';

class BadgesRow extends StatelessWidget {
  BadgesRow({Key? key}) : super(key: key);
  final BadgeController badge = Get.find();

  Widget badgeCard(int days, String label, IconData icon) {
    final unlocked = badge.hasBadge(days);
    return Card(
      color: unlocked ? Colors.amber.shade100 : Colors.grey.shade200,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Icon(icon, color: unlocked ? Colors.orange : Colors.grey, size: 28),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(unlocked ? "Unlocked" : "Locked", style: TextStyle(color: unlocked ? Colors.green : Colors.grey)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 130,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          Obx(() => badgeCard(3, "3 Days", Icons.looks_3)),
          const SizedBox(width: 8),
          Obx(() => badgeCard(7, "7 Days", Icons.filter_7)),
          const SizedBox(width: 8),
          Obx(() => badgeCard(14, "14 Days", Icons.celebration)),
        ],
      ),
    );
  }
}
