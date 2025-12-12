import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../controllers/water_controller.dart';
import '../../../controllers/auth_controller.dart';

class WaterTrackerCard extends StatelessWidget {
  WaterTrackerCard({Key? key}) : super(key: key);

  final WaterController water = Get.find();
  final AuthController auth = Get.find(); // Firebase user

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Firestore path for user's water data
  String get _waterDocPath => 'users/${auth.user?.uid}/water/today';

  /// Update Firestore with today's water
  Future<void> _updateFirebase(double amount) async {
    try {
      if (auth.user == null) return;

      final todayString = DateTime.now().toIso8601String().split('T').first;

      await _firestore.doc(_waterDocPath).set({
        'amount': water.todayAmount.value,
        'goal': water.dailyGoal.value,
        'date': todayString,
      }, SetOptions(merge: true));
    } catch (e) {
      print('Firestore update error: $e');
    }
  }

  /// Add water amount
  Future<void> _addWater(double amount) async {
    water.todayAmount.value += amount;
    await _updateFirebase(water.todayAmount.value);
  }

  /// Reset water today
  Future<void> _resetWater() async {
    water.todayAmount.value = 0.0;
    await _updateFirebase(0.0);
  }

  /// Load today's water from Firestore
  Future<void> _loadWater() async {
    try {
      if (auth.user == null) return;

      final doc = await _firestore.doc(_waterDocPath).get();
      if (doc.exists) {
        final data = doc.data();
        final storedDate = data?['date'] ?? '';
        final todayString = DateTime.now().toIso8601String().split('T').first;

        // Only use today's data
        if (storedDate == todayString) {
          water.todayAmount.value = (data?['amount'] ?? 0).toDouble();
          water.dailyGoal.value = (data?['goal'] ?? 2000).toDouble();
        } else {
          water.todayAmount.value = 0.0;
        }
      }
    } catch (e) {
      print('Firestore load error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Load data when widget is first built
    _loadWater();

    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                Obx(() => Text(
                      "Water: ${water.todayAmount.value.toStringAsFixed(0)} / ${water.dailyGoal.value.toStringAsFixed(0)} ml",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    )),
                const Spacer(),
                Obx(() => CircularProgressIndicator(
                      value: water.percent(),
                      color: Colors.blue,
                      strokeWidth: 6,
                    )),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton(
                    onPressed: () => _addWater(250), child: const Text("+250 ml")),
                const SizedBox(width: 8),
                ElevatedButton(
                    onPressed: () => _addWater(500), child: const Text("+500 ml")),
                const Spacer(),
                TextButton(onPressed: _resetWater, child: const Text("Reset")),
              ],
            )
          ],
        ),
      ),
    );
  }
}
