import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/sleep_model.dart';
import 'auth_controller.dart';

class SleepController extends GetxController {
  final AuthController auth = Get.find();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RxList<SleepEntry> sleepHistory = <SleepEntry>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadSleepData();
  }

  Future<void> _loadSleepData() async {
    if (auth.user == null) return;
    final uid = auth.user!.uid;

    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('sleep')
        .orderBy('bedTime', descending: true)
        .get();

    sleepHistory.assignAll(snapshot.docs
        .map((doc) => SleepEntry.fromMap(doc.data(), doc.id))
        .toList());
  }

  Future<void> addSleep(DateTime bedTime, DateTime wakeTime, int quality) async {
    if (auth.user == null) return;
    final uid = auth.user!.uid;

    final docRef = await _firestore
        .collection('users')
        .doc(uid)
        .collection('sleep')
        .add({
      'bedTime': bedTime.toIso8601String(),
      'wakeTime': wakeTime.toIso8601String(),
      'quality': quality,
    });

    final entry = SleepEntry(id: docRef.id, bedTime: bedTime, wakeTime: wakeTime, quality: quality);
    sleepHistory.insert(0, entry);
  }

  Future<void> deleteSleep(int index) async {
    if (auth.user == null || index >= sleepHistory.length) return;
    final uid = auth.user!.uid;

    final entry = sleepHistory[index];
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('sleep')
        .doc(entry.id)
        .delete();

    sleepHistory.removeAt(index);
  }

  double averageSleep() {
    if (sleepHistory.isEmpty) return 0.0;
    return sleepHistory.map((e) => e.hours).reduce((a, b) => a + b) / sleepHistory.length;
  }
}
