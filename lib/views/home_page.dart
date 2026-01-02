import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/bottom_nav_controller.dart';
import 'dashboard/dashboard_page.dart';
import 'progress/progress_page.dart';
import 'motivation_page.dart';
import 'sleep_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final BottomNavController navController;

  // ✅ Cache heavy pages once
  final DashboardPage _dashboardPage = const DashboardPage();
  final ProgressPage _progressPage = const ProgressPage();
  final MotivationPage _motivationPage = const MotivationPage();
  final SleepPage _sleepPage = const SleepPage();

  @override
  void initState() {
    super.initState();

    // ✅ Safe GetX injection (no duplicates)
    navController = Get.put(BottomNavController(), permanent: true);
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return _dashboardPage;
      case 1:
        return _progressPage;
      case 2:
        return _motivationPage; // cached (video safe)
      case 3:
        return _sleepPage;
      default:
        return _dashboardPage;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'FitLife',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          centerTitle: true,
        ),

        // ✅ Only this rebuilds on tab change
        body: _buildPage(navController.currentIndex.value),

        bottomNavigationBar: BottomNavigationBar(
          currentIndex: navController.currentIndex.value,
          onTap: navController.changeTab,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Colors.grey,

          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.show_chart),
              label: 'Progress',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.lightbulb_outline),
              label: 'Motivation',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.nightlight_round),
              label: 'Sleep',
            ),
          ],
        ),
      );
    });
  }
}
