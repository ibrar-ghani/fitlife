import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StepsController extends GetxController {
  RxInt steps = 0.obs;
  final int dailyGoal = 8000;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    _loadStepsFromFirebase();
  }

  // ---------------------------------------------------------
  // 🔥 Load steps from Firebase for the current user
  // ---------------------------------------------------------
  Future<void> _loadStepsFromFirebase() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data()?['steps'] != null) {
        steps.value = doc.data()!['steps'];
      }
    } catch (e) {
      print("Error loading steps: $e");
    }
  }

  // ---------------------------------------------------------
  // 🔥 Add steps and update Firebase
  // ---------------------------------------------------------
  Future<void> addSteps(int amount) async {
    steps.value += amount;

    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore.collection('users').doc(user.uid).set({
        'steps': steps.value,
      }, SetOptions(merge: true));
    } catch (e) {
      print("Error updating steps: $e");
    }
  }

  // ---------------------------------------------------------
  // 🔥 Calculate progress (0.0 - 1.0)
  // ---------------------------------------------------------
  double progress() {
    return (steps.value / dailyGoal).clamp(0.0, 1.0);
  }
}
