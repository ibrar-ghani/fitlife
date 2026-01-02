// lib/views/progress/progress_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/goal_controller.dart';

import 'widgets/steps_widegt.dart';
import 'widgets/goal_card.dart';
import 'widgets/progress_chart.dart';
import 'widgets/progress_summary.dart';

class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    final GoalController goalController = Get.find();


    return Scaffold(
      backgroundColor: const Color(0xffF6F7FB),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// 🔥 HERO SUMMARY (Main Focus)
              _card(
                padding: 18,
                child: ProgressSummary(),
              ),

              const SizedBox(height: 20),

              /// 📊 DAILY METRICS (Side-by-side)
              Row(
                children: [
                  Expanded(child: _MetricCard(child: StepsWidget())),
                  const SizedBox(width: 12),
                  Expanded(child: _MetricCard(child: GoalCard())),
                ],
              ),

              const SizedBox(height: 24),

              /// 📈 PROGRESS CHART (Only if meaningful)
              Obx(() {
                if (goalController.goal.value <= 0) {
                  return _emptyState();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle("Progress Overview"),
                    const SizedBox(height: 10),
                    _card(child: ProgressChart()),
                  ],
                );
              }),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // UI HELPERS
  // ─────────────────────────────────────────────

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
    );
  }

  Widget _card({required Widget child, double padding = 16}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _emptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      alignment: Alignment.center,
      child: Column(
        children: const [
          Icon(Icons.trending_up, size: 48, color: Colors.grey),
          SizedBox(height: 12),
          Text(
            "Start tracking to see your progress",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

/// 🔹 Smaller reusable metric card
class _MetricCard extends StatelessWidget {
  final Widget child;
  const _MetricCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }
}
