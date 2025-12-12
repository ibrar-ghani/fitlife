import 'package:fitlife/controllers/auth_controller.dart';
import 'package:fitlife/controllers/steps_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class StepsWidget extends StatelessWidget {
  final StepsController controller = Get.put(StepsController());
  final AuthController auth = Get.put(AuthController());
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Firestore path: users/{uid}/steps/today
  String get _stepsDocPath => 'users/${auth.user?.uid}/steps/today';

  StepsWidget({Key? key}) : super(key: key) {
    _loadSteps(); // load when widget is created
  }

  /// Load today's steps from Firestore
  Future<void> _loadSteps() async {
    try {
      if (auth.user == null) return;

      final doc = await _firestore.doc(_stepsDocPath).get();
      if (doc.exists) {
        final data = doc.data();
        final storedDate = data?['date'] ?? '';
        final todayString = DateTime.now().toIso8601String().split('T').first;

        if (storedDate == todayString) {
          controller.steps.value = (data?['steps'] ?? 0).toInt();
        } else {
          controller.steps.value = 0;
        }
      }
    } catch (e) {
      print("Firestore load steps error: $e");
    }
  }

  /// Add steps and update Firestore
  Future<void> _addSteps(int count) async {
    controller.addSteps(count);

    try {
      if (auth.user == null) return;

      final todayString = DateTime.now().toIso8601String().split('T').first;
      await _firestore.doc(_stepsDocPath).set({
        'steps': controller.steps.value,
        'date': todayString,
      }, SetOptions(merge: true));
    } catch (e) {
      print("Firestore add steps error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final progress = controller.progress();
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade400, Colors.blue.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.shade200,
              blurRadius: 10,
              spreadRadius: 1,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Steps Tracker",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 10,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                ),
                Text(
                  "${controller.steps.value}",
                  style: TextStyle(
                    fontSize: 26,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _addSteps(200),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.blue.shade800,
              ),
              child: Text("Add 200 Steps"),
            )
          ],
        ),
      );
    });
  }
}
