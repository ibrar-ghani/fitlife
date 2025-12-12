import 'package:get/get.dart';
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

  Future<void> _loadData() async {
    if (auth.user == null) return;
    final uid = auth.user!.uid;

    final doc = await _firestore.collection('users').doc(uid).collection('water').doc('today').get();

    if (doc.exists) {
      final data = doc.data()!;
      todayAmount.value = (data['todayAmount'] ?? 0).toDouble();
      dailyGoal.value = (data['dailyGoal'] ?? 2000).toDouble();
    } else {
      // create initial doc
      await _firestore.collection('users').doc(uid).collection('water').doc('today').set({
        'todayAmount': todayAmount.value,
        'dailyGoal': dailyGoal.value,
      });
    }
  }

  Future<void> _saveData() async {
    if (auth.user == null) return;
    final uid = auth.user!.uid;
    await _firestore.collection('users').doc(uid).collection('water').doc('today').set({
      'todayAmount': todayAmount.value,
      'dailyGoal': dailyGoal.value,
    });
  }

  double percent() {
    if (dailyGoal.value == 0) return 0.0;
    return (todayAmount.value / dailyGoal.value).clamp(0.0, 1.0);
  }

  Future<void> addAmount(double amount) async {
    todayAmount.value += amount;
    await _saveData();
  }

  Future<void> resetToday() async {
    todayAmount.value = 0;
    await _saveData();
  }

  Future<void> setGoal(double goal) async {
    dailyGoal.value = goal;
    await _saveData();
  }
}
