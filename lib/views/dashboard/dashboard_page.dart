import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/sleep_controller.dart';
import '../../controllers/water_controller.dart';
import '../../controllers/steps_controller.dart';
import '../../controllers/motivation_controller.dart';

class DashboardPage extends StatelessWidget {
  final sleep = Get.put(SleepController());
  final water = Get.put(WaterController());
  final steps = Get.put(StepsController());
  final motivation = Get.put(MotivationController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text("FitLife Dashboard", style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [

            // Greeting
            Align(
              alignment: Alignment.centerLeft,
              child: Text("Hello Ibrar 👋",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: Text("Here’s your health summary for today.",
                style: TextStyle(color: Colors.black54),
              ),
            ),
            SizedBox(height: 20),

            // Stats Grid
            GridView(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 16, crossAxisSpacing: 16),
              children: [
                _statCard(Icons.nightlight_round, "Sleep", "${sleep.averageSleep().toStringAsFixed(1)} hrs", Colors.indigo),
                _statCard(Icons.local_drink, "Water", "${water.todayAmount} ml", Colors.blue),
                _statCard(Icons.directions_walk, "Steps", "${steps.steps}", Colors.green),
                _statCard(Icons.lightbulb, "Motivation", "Tap to View", Colors.orange),
              ],
            ),

            SizedBox(height: 20),

            // Quote Section
            Obx(() => Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                motivation.quotes.isEmpty
                    ? "Loading motivational quote..."
                    : motivation.quotes[DateTime.now().day % motivation.quotes.length],
                style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.orange.shade900),
                textAlign: TextAlign.center,
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _statCard(IconData icon, String title, String value, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: color),
          SizedBox(height: 12),
          Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 16, color: Colors.black87)),
        ],
      ),
    );
  }
}
