import 'package:fitlife/views/dashboard/dashboard_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/bottom_nav_controller.dart';
import 'progress/progress_page.dart';
import 'motivation_page.dart';
import 'water_page.dart';
import 'sleep_page.dart'; // ✅ NEW IMPORT

class HomePage extends StatelessWidget {
  final BottomNavController navController = Get.put(BottomNavController());

  final pages = [
    DashboardPage(),
    ProgressPage(),
    MotivationPage(),
    WaterPage(),
    SleepPage(), // ✅ ADDED
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
          appBar: AppBar(title: const Text('FitLife')),
          body: pages[navController.currentIndex.value],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: navController.currentIndex.value,
            onTap: navController.changeTab,
            type: BottomNavigationBarType.fixed, // ✅ IMPORTANT for 4 tabs
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
                icon: Icon(Icons.nightlight_round), // 🌙 SLEEP ICON
                label: 'Sleep',
              ),
            ],
          ),
        ));
  }
}