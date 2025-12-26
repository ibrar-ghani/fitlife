import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StepsController extends GetxController {
  final RxInt steps = 0.obs;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String get _stepsDocPath => 'users/${_auth.currentUser?.uid}/steps/today';

  @override
  void onInit() {
    super.onInit();
    _bindStepsStream();
  }

  /// 🔥 Listen to today's steps in real-time
  void _bindStepsStream() {
    final user = _auth.currentUser;
    if (user == null) return;

    _firestore.doc(_stepsDocPath).snapshots().listen(
      (doc) {
        final todayString = DateTime.now().toIso8601String().split('T').first;

        if (doc.exists) {
          final data = doc.data();
          final storedDate = data?['date'] ?? '';
          steps.value = storedDate == todayString ? (data?['steps'] ?? 0).toInt() : 0;
        } else {
          steps.value = 0;
        }
      },
      onError: (e) => print("Error listening to steps: $e"),
    );
  }

  /// 🔥 Add steps and update Firestore
  Future<void> addSteps(int count) async {
    final user = _auth.currentUser;
    if (user == null) return;

    steps.value += count;

    final todayString = DateTime.now().toIso8601String().split('T').first;

    try {
      await _firestore.doc(_stepsDocPath).set(
        {
          'steps': steps.value,
          'date': todayString,
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      print("Firestore addSteps error: $e");
    }
  }

  /// 🔥 Returns progress toward a daily goal (default 10,000 steps)
  double progress({int goal = 10000}) {
    return (steps.value / goal).clamp(0.0, 1.0);
  }
}
