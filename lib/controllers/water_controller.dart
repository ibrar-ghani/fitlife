import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_controller.dart';

class WaterController extends GetxController {
  final AuthController auth = Get.find();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RxDouble todayAmount = 0.0.obs;
  RxDouble dailyGoal = 2000.0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  /// Load water data from Firestore
  Future<void> _loadData() async {
    if (auth.user == null) return;
    final uid = auth.user!.uid;

    try {
      final doc = await _firestore.collection('users').doc(uid).collection('water').doc('today').get();
      if (doc.exists) {
        final data = doc.data()!;
        todayAmount.value = (data['todayAmount'] ?? 0).toDouble();
        dailyGoal.value = (data['dailyGoal'] ?? 2000).toDouble();
      } else {
        // Initialize document
        await _firestore.collection('users').doc(uid).collection('water').doc('today').set({
          'todayAmount': todayAmount.value,
          'dailyGoal': dailyGoal.value,
        });
      }
    } catch (e) {
      print("Error loading water data: $e");
    }
  }

  /// Save water data to Firestore
  Future<void> _saveData() async {
    if (auth.user == null) return;
    final uid = auth.user!.uid;

    try {
      await _firestore.collection('users').doc(uid).collection('water').doc('today').set({
        'todayAmount': todayAmount.value,
        'dailyGoal': dailyGoal.value,
      });
    } catch (e) {
      print("Error saving water data: $e");
    }
  }

  /// Percentage of goal completed (0.0 - 1.0)
  double percent() {
    if (dailyGoal.value == 0) return 0.0;
    return (todayAmount.value / dailyGoal.value).clamp(0.0, 1.0);
  }

  /// Add water intake
  Future<void> addAmount(double amount) async {
    if (amount <= 0) return;
    todayAmount.value += amount;
    await _saveData();
  }

  /// Reset today’s intake
  Future<void> resetToday() async {
    todayAmount.value = 0;
    await _saveData();
  }

  /// Set daily goal
  Future<void> setGoal(double goal) async {
    if (goal <= 0) return;
    dailyGoal.value = goal;
    await _saveData();
  }
}
