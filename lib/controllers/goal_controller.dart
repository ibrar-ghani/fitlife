import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GoalController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RxDouble goal = 0.0.obs;
  RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _bindGoal();
  }

  void _bindGoal() {
    final user = _auth.currentUser;
    if (user == null) {
      isLoading.value = false;
      return;
    }

    _firestore.doc('users/${user.uid}/dailyGoal').snapshots().listen(
      (doc) {
        final val = doc.data()?['value'];
        goal.value = val != null ? (val as num).toDouble() : 0.0;
        isLoading.value = false;
      },
      onError: (e) {
        isLoading.value = false;
        print('Goal stream error: $e');
      },
    );
  }

  Future<void> setGoal(double val) async {
    final user = _auth.currentUser;
    if (user == null) return;

    goal.value = val;
    try {
      await _firestore.doc('users/${user.uid}/dailyGoal').set({'value': val});
    } catch (e) {
      print("Error saving goal: $e");
    }
  }

  Future<void> clearGoal() async {
    final user = _auth.currentUser;
    if (user == null) return;

    goal.value = 0.0;
    try {
      await _firestore.doc('users/${user.uid}/dailyGoal').delete();
    } catch (e) {
      print("Error clearing goal: $e");
    }
  }
}
