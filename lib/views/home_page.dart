import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/bottom_nav_controller.dart';
import 'dashboard/dashboard_page.dart';
import 'progress/progress_page.dart';
import 'motivation_page.dart';
import 'water_page.dart';
import 'sleep_page.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  // Find controller (already injected once)
  final BottomNavController navController =
      Get.find<BottomNavController>();

  final List<Widget> pages = [
    const DashboardPage(),
    const ProgressPage(),
    const MotivationPage(),
    WaterPage(),
    const SleepPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
          appBar: AppBar(
            title: const Text('FitLife'),
            centerTitle: true,
          ),
          body: IndexedStack(
            index: navController.currentIndex.value,
            children: pages,
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: navController.currentIndex.value,
            onTap: navController.changeTab,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.show_chart),
                label: 'Progress',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.lightbulb),
                label: 'Motivation',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.local_drink),
                label: 'Water',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.nightlight_round),
                label: 'Sleep',
              ),
            ],
          ),
        ));
  }
}
