// lib/views/progress/progress_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/badge_controller.dart';
import '../../controllers/goal_controller.dart';
import '../../controllers/water_controller.dart';
import 'widgets/water_tracker_card.dart';
import 'widgets/goal_card.dart';
import 'widgets/badges_row.dart';
import 'widgets/progress_chart.dart';
import 'widgets/progress_summary.dart';
import 'widgets/add_progress_input.dart';

class ProgressPage extends StatelessWidget {
  final BadgeController badgeController = Get.put(BadgeController());
  final GoalController goalController = Get.put(GoalController());
  final WaterController waterController = Get.put(WaterController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Progress & Goal')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            WaterTrackerCard(),
            SizedBox(height: 16),
            GoalCard(),
            SizedBox(height: 16),
            BadgesRow(),
            SizedBox(height: 16),
            ProgressChart(),
            SizedBox(height: 16),
            ProgressSummary(),
            SizedBox(height: 16),
            AddProgressInput(),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
