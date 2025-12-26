import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/sleep_model.dart';
import 'auth_controller.dart';

class SleepController extends GetxController {
  final AuthController auth = Get.find();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RxList<SleepEntry> sleepHistory = <SleepEntry>[].obs;
  RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSleepData();
  }

  /// 🔥 Load all sleep entries for the current user
  Future<void> _loadSleepData() async {
    final user = auth.user;
    if (user == null) {
      isLoading.value = false;
      return;
    }

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('sleep')
          .orderBy('bedTime', descending: true)
          .get();

      final entries = snapshot.docs
          .map((doc) => SleepEntry.fromMap(doc.data(), doc.id))
          .toList();

      sleepHistory.assignAll(entries);
    } catch (e) {
      print("Error loading sleep data: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// 🔥 Add a new sleep entry
  Future<void> addSleep(DateTime bedTime, DateTime wakeTime, int quality) async {
    final user = auth.user;
    if (user == null) return;

    try {
      final docRef = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('sleep')
          .add({
        'bedTime': bedTime.toIso8601String(),
        'wakeTime': wakeTime.toIso8601String(),
        'quality': quality,
      });

      final entry = SleepEntry(
        id: docRef.id,
        bedTime: bedTime,
        wakeTime: wakeTime,
        quality: quality,
      );

      sleepHistory.insert(0, entry);
    } catch (e) {
      print("Error adding sleep entry: $e");
    }
  }

  /// 🔥 Delete a sleep entry by index
  Future<void> deleteSleep(int index) async {
    final user = auth.user;
    if (user == null || index >= sleepHistory.length) return;

    final entry = sleepHistory[index];

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('sleep')
          .doc(entry.id)
          .delete();

      sleepHistory.removeAt(index);
    } catch (e) {
      print("Error deleting sleep entry: $e");
    }
  }

  /// 🔥 Compute average sleep in hours
  double get average => sleepHistory.isEmpty
      ? 0.0
      : sleepHistory.map((e) => e.hours).reduce((a, b) => a + b) / sleepHistory.length;
}
