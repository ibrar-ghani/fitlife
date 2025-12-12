import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/goal_controller.dart';
import '../../../controllers/auth_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GoalCard extends StatelessWidget {
  GoalCard({Key? key}) : super(key: key);
  final GoalController goal = Get.find();
  final AuthController auth = Get.find();
  final TextEditingController input = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String get _goalPath => 'users/${auth.user?.uid}/dailyGoal';

  @override
  Widget build(BuildContext context) {
    // Load goal from Firestore on first build
    _loadGoal();

    return Card(
      color: Colors.purple.shade50,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Daily Running Goal (km)",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: input,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(), hintText: 'e.g., 5'),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    final val = double.tryParse(input.text);
                    if (val != null && val > 0) {
                      goal.setGoal(val);
                      _saveGoalToFirebase(val);
                      input.clear();
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                  child:
                      const Text("Save", style: TextStyle(color: Colors.white)),
                )
              ],
            ),
            const SizedBox(height: 12),
            Obx(() => Text(
                "Current Goal: ${goal.goal.value <= 0 ? 'Not Set' : '${goal.goal.value} km'}")),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                  onPressed: () {
                    goal.clearGoal();
                    _clearGoalInFirebase();
                  },
                  child: const Text("Clear")),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadGoal() async {
    if (auth.user == null) return;

    try {
      final doc = await _firestore.doc(_goalPath).get();
      if (doc.exists) {
        final val = doc.data()?['value'];
        if (val != null) goal.setGoal(val.toDouble());
      }
    } catch (e) {
      print("Error loading goal: $e");
    }
  }

  Future<void> _saveGoalToFirebase(double val) async {
    if (auth.user == null) return;
    try {
      await _firestore.doc(_goalPath).set({'value': val});
    } catch (e) {
      print("Error saving goal: $e");
    }
  }

  Future<void> _clearGoalInFirebase() async {
    if (auth.user == null) return;
    try {
      await _firestore.doc(_goalPath).delete();
    } catch (e) {
      print("Error clearing goal: $e");
    }
  }
}
