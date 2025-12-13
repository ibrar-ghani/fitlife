import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StepsController extends GetxController {
  RxInt steps = 0.obs;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String get _stepsDocPath => 'users/${_auth.currentUser?.uid}/steps/today';

  @override
  void onInit() {
    super.onInit();
    _bindStepsStream();
  }

  void _bindStepsStream() {
    final user = _auth.currentUser;
    if (user == null) return;

    _firestore.doc(_stepsDocPath).snapshots().listen((doc) {
      if (doc.exists) {
        final data = doc.data();
        final storedDate = data?['date'] ?? '';
        final todayString = DateTime.now().toIso8601String().split('T').first;

        if (storedDate == todayString) {
          steps.value = (data?['steps'] ?? 0).toInt();
        } else {
          steps.value = 0;
        }
      } else {
        steps.value = 0;
      }
    });
  }

  Future<void> addSteps(int count) async {
    steps.value += count;

    final todayString = DateTime.now().toIso8601String().split('T').first;
    try {
      await _firestore.doc(_stepsDocPath).set({
        'steps': steps.value,
        'date': todayString,
      }, SetOptions(merge: true));
    } catch (e) {
      print("Firestore add steps error: $e");
    }
  }

  double progress([int goal = 10000]) {
    // goal is steps target, default 10k
    return (steps.value / goal).clamp(0.0, 1.0);
  }
}
