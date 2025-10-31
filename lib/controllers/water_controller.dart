// lib/controllers/water_controller.dart
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WaterController extends GetxController {
  static const String _kTodayKey = 'water_today_amount';
  static const String _kDateKey = 'water_last_date';
  RxDouble todayAmount = 0.0.obs; // in ml
  RxDouble dailyGoal = 2000.0.obs; // default 2000 ml

  @override
  void onInit() {
    super.onInit();
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final lastDate = prefs.getString(_kDateKey) ?? '';
    final todayString = DateTime.now().toIso8601String().split('T').first;

    if (lastDate != todayString) {
      // new day -> reset
      todayAmount.value = 0.0;
      await prefs.setString(_kDateKey, todayString);
      await prefs.setDouble(_kTodayKey, 0.0);
    } else {
      todayAmount.value = prefs.getDouble(_kTodayKey) ?? 0.0;
    }

    // load any persisted goal (optional)
    final savedGoal = prefs.getDouble('water_goal') ?? 2000.0;
    dailyGoal.value = savedGoal;
  }

  Future<void> addAmount(double ml) async {
    todayAmount.value += ml;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kTodayKey, todayAmount.value);
    // ensure date recorded
    final todayString = DateTime.now().toIso8601String().split('T').first;
    await prefs.setString(_kDateKey, todayString);
  }

  Future<void> setGoal(double ml) async {
    dailyGoal.value = ml;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('water_goal', ml);
  }

  Future<void> resetToday() async {
    todayAmount.value = 0.0;
    final prefs = await SharedPreferences.getInstance();
    final todayString = DateTime.now().toIso8601String().split('T').first;
    await prefs.setString(_kDateKey, todayString);
    await prefs.setDouble(_kTodayKey, 0.0);
  }

  double percent() {
    if (dailyGoal.value <= 0) return 0.0;
    return (todayAmount.value / dailyGoal.value).clamp(0.0, 1.0);
  }
}
