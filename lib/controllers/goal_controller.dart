import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GoalController extends GetxController {
  static const String _kGoalKey = 'dailyGoal';

  // Current goal value (e.g., distance in km)
  RxDouble goal = 0.0.obs;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    _loadGoal();
  }

  // ---------------------------------------------------------
  // 🔥 Load goal from Firebase, fallback to local storage
  // ---------------------------------------------------------
  Future<void> _loadGoal() async {
    final user = _auth.currentUser;
    bool loadedFromFirebase = false;

    if (user != null) {
      try {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists && doc.data()?['goal'] != null) {
          goal.value = (doc.data()?['goal'] ?? 0.0).toDouble();
          loadedFromFirebase = true;
        }
      } catch (e) {
        print("Firebase loadGoal error: $e");
      }
    }

    if (!loadedFromFirebase) {
      final prefs = await SharedPreferences.getInstance();
      goal.value = prefs.getDouble(_kGoalKey) ?? 0.0;
    }
  }

  // ---------------------------------------------------------
  // 🔥 Set a new goal
  // ---------------------------------------------------------
  Future<void> setGoal(double newGoal) async {
    goal.value = newGoal;

    final user = _auth.currentUser;

    // Save to Firebase
    if (user != null) {
      try {
        await _firestore.collection('users').doc(user.uid).set({
          'goal': goal.value,
        }, SetOptions(merge: true));
      } catch (e) {
        print("Firebase setGoal error: $e");
      }
    }

    // Save locally
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kGoalKey, newGoal);
  }

  // ---------------------------------------------------------
  // 🔥 Clear the current goal
  // ---------------------------------------------------------
  Future<void> clearGoal() async {
    goal.value = 0.0;

    final user = _auth.currentUser;

    // Remove from Firebase
    if (user != null) {
      try {
        await _firestore.collection('users').doc(user.uid).update({
          'goal': FieldValue.delete(),
        });
      } catch (e) {
        print("Firebase clearGoal error: $e");
      }
    }

    // Remove locally
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kGoalKey);
  }
}
