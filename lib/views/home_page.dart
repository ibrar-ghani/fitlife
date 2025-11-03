import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/bottom_nav_controller.dart';
import 'progress/progress_page.dart';
import 'motivation_page.dart';
import 'water_page.dart'; // ✅ import here

class HomePage extends StatelessWidget {
  final BottomNavController navController = Get.put(BottomNavController());

  final pages = [
    ProgressPage(),
    MotivationPage(),
    WaterPage(), // ✅ Added Page
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
          appBar: AppBar(title: const Text('FitLife')),
          body: pages[navController.currentIndex.value],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: navController.currentIndex.value,
            onTap: navController.changeTab,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.show_chart),
                label: 'Progress',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.lightbulb),
                label: 'Motivation',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.local_drink), // ✅ WATER ICON
                label: 'Water',
              ),
            ],
          ),
        ));
  }
}
