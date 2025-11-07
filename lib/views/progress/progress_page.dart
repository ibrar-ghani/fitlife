// lib/views/progress/progress_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/badge_controller.dart';
import '../../controllers/goal_controller.dart';
import '../../controllers/water_controller.dart';

import 'widgets/steps_widegt.dart';
import 'widgets/goal_card.dart';
import 'widgets/badges_row.dart';
import 'widgets/progress_chart.dart';
import 'widgets/progress_summary.dart';
import 'widgets/add_progress_input.dart';

class ProgressPage extends StatelessWidget {
  final badgeController = Get.put(BadgeController());
  final goalController = Get.put(GoalController());
  final waterController = Get.put(WaterController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.3,
        title: const Text(
          'Your Progress',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ------------ STEPS SECTION ------------
            _sectionTitle("Today's Activity"),
            _card(
              child: StepsWidget(),
            ),
            const SizedBox(height: 18),

            // ------------ GOALS ------------
            _sectionTitle("Your Goal"),
            _card(child: GoalCard()),
            const SizedBox(height: 18),

            // ------------ BADGES ------------
            _sectionTitle("Achievements"),
            _card(child: BadgesRow()),
            const SizedBox(height: 18),

            // ------------ PROGRESS CHART ------------
            _sectionTitle("Progress Overview"),
            _card(child: ProgressChart()),
            const SizedBox(height: 18),

            // ------------ SUMMARY ------------
            _card(child: ProgressSummary()),
            const SizedBox(height: 18),

            // ------------ INPUT ------------
            _sectionTitle("Add Progress"),
            _card(child: AddProgressInput()),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
