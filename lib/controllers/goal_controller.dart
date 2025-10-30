// lib/controllers/goal_controller.dart
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GoalController extends GetxController {
  static const String _kGoalKey = 'dailyGoal';
  RxDouble goal = 0.0.obs; // target (e.g., km)

  @override
  void onInit() {
    super.onInit();
    _loadGoal();
  }

  Future<void> _loadGoal() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getDouble(_kGoalKey) ?? 0.0;
    goal.value = value;
  }

  Future<void> setGoal(double newGoal) async {
    goal.value = newGoal;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kGoalKey, newGoal);
  }

  Future<void> clearGoal() async {
    goal.value = 0.0;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kGoalKey);
  }
}
