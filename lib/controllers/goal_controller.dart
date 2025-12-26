import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GoalController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RxDouble goal = 0.0.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _bindGoal();
  }

  void _bindGoal() {
    final user = _auth.currentUser;
    if (user == null) return;

    /// ✅ Bind stream instead of manual listen
    goal.bindStream(
      _firestore
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .map((doc) {
        final data = doc.data();
        if (data == null) return 0.0;
        return (data['dailyGoal'] ?? 0).toDouble();
      }),
    );
  }

  // ---------------------------------------------------------
  // 🎯 SET GOAL
  // ---------------------------------------------------------
  Future<void> setGoal(double value) async {
    final user = _auth.currentUser;
    if (user == null) return;

    goal.value = value;

    try {
      await _firestore.collection('users').doc(user.uid).set(
        {'dailyGoal': value},
        SetOptions(merge: true),
      );
    } catch (e) {
      Get.log("Goal save error: $e");
    }
  }

  // ---------------------------------------------------------
  // 🧹 CLEAR GOAL
  // ---------------------------------------------------------
  Future<void> clearGoal() async {
    final user = _auth.currentUser;
    if (user == null) return;

    goal.value = 0.0;

    try {
      await _firestore.collection('users').doc(user.uid).update({
        'dailyGoal': FieldValue.delete(),
      });
    } catch (e) {
      Get.log("Goal clear error: $e");
    }
  }
}
