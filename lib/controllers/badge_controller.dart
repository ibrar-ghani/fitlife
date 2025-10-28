// lib/controllers/badge_controller.dart
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BadgeController extends GetxController {
  // badge ids
  final List<int> badgeThresholds = [3, 7, 14];

  // earned badges (contains thresholds that user earned)
  RxList<int> earnedBadges = <int>[].obs;

  // current consecutive streak
  RxInt streak = 0.obs;

  // last active date in ISO (yyyy-MM-dd)
  RxString lastActiveDate = ''.obs;

  static const String _kEarnedKey = 'earnedBadges';
  static const String _kStreakKey = 'currentStreak';
  static const String _kLastDateKey = 'lastActiveDate';

  @override
  void onInit() {
    super.onInit();
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final earned = prefs.getStringList(_kEarnedKey) ?? [];
    earnedBadges.assignAll(earned.map((e) => int.tryParse(e) ?? 0).where((v) => v > 0).toList());
    streak.value = prefs.getInt(_kStreakKey) ?? 0;
    lastActiveDate.value = prefs.getString(_kLastDateKey) ?? '';
  }

  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_kEarnedKey, earnedBadges.map((e) => e.toString()).toList());
    await prefs.setInt(_kStreakKey, streak.value);
    await prefs.setString(_kLastDateKey, lastActiveDate.value);
  }

  /// Call this when the user performs a daily action (e.g., adds progress)
  Future<void> registerDailyActivity(DateTime today) async {
    final todayStr = _dateOnlyIso(today);

    if (lastActiveDate.value.isEmpty) {
      // first time
      streak.value = 1;
    } else {
      final last = DateTime.parse(lastActiveDate.value);
      final difference = _dateOnly(today).difference(_dateOnly(last)).inDays;
      if (difference == 0) {
        // already did something today — don't increment
        // keep current streak
        // nothing to do
        return;
      } else if (difference == 1) {
        // continued streak
        streak.value = streak.value + 1;
      } else {
        // break in streak
        streak.value = 1;
      }
    }

    lastActiveDate.value = todayStr;
    _checkForBadges();
    await _saveToStorage();
  }

  void _checkForBadges() {
    for (final threshold in badgeThresholds) {
      if (streak.value >= threshold && !earnedBadges.contains(threshold)) {
        earnedBadges.add(threshold);
        // Optionally, show a popup/notification here
        Get.snackbar('Badge earned!', 'You earned ${threshold}-day streak badge 🏅',
            snackPosition: SnackPosition.BOTTOM);
      }
    }
  }

  bool hasBadge(int days) {
    return earnedBadges.contains(days);
  }

  String _dateOnlyIso(DateTime d) {
    final only = DateTime(d.year, d.month, d.day);
    return only.toIso8601String();
  }

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  /// For debugging / reset during development
  Future<void> resetAll() async {
    earnedBadges.clear();
    streak.value = 0;
    lastActiveDate.value = '';
    await _saveToStorage();
  }
}
