import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BadgeController extends GetxController {
  // Badge thresholds
  final List<int> badgeThresholds = [3, 7, 14];

  RxList<int> earnedBadges = <int>[].obs;
  RxInt streak = 0.obs;
  RxString lastActiveDate = ''.obs;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _kEarnedKey = 'earnedBadges';
  static const String _kStreakKey = 'currentStreak';
  static const String _kLastDateKey = 'lastActiveDate';

  @override
  void onInit() {
    super.onInit();
    _loadFromLocal();
    _loadFromFirebase();
  }

  // ---------------------------------------------------------
  // 🔥 Local storage fallback
  // ---------------------------------------------------------
  Future<void> _loadFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final earned = prefs.getStringList(_kEarnedKey) ?? [];
    earnedBadges.assignAll(earned.map((e) => int.tryParse(e) ?? 0).where((v) => v > 0).toList());
    streak.value = prefs.getInt(_kStreakKey) ?? 0;
    lastActiveDate.value = prefs.getString(_kLastDateKey) ?? '';
  }

  Future<void> _saveToLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_kEarnedKey, earnedBadges.map((e) => e.toString()).toList());
    await prefs.setInt(_kStreakKey, streak.value);
    await prefs.setString(_kLastDateKey, lastActiveDate.value);
  }

  // ---------------------------------------------------------
  // 🔥 Firebase persistence
  // ---------------------------------------------------------
  Future<void> _loadFromFirebase() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        streak.value = doc.data()?['streak'] ?? streak.value;
        lastActiveDate.value = doc.data()?['lastActiveDate'] ?? lastActiveDate.value;
        final badges = List.from(doc.data()?['earnedBadges'] ?? []);
        earnedBadges.assignAll(badges.cast<int>());
      }
    } catch (e) {
      print("BadgeController Firebase load error: $e");
    }
  }

  Future<void> _saveToFirebase() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore.collection('users').doc(user.uid).set({
        'streak': streak.value,
        'lastActiveDate': lastActiveDate.value,
        'earnedBadges': earnedBadges,
      }, SetOptions(merge: true));
    } catch (e) {
      print("BadgeController Firebase save error: $e");
    }
  }

  // ---------------------------------------------------------
  // 🔥 Register daily activity
  // ---------------------------------------------------------
  Future<void> registerDailyActivity(DateTime today) async {
    final todayStr = _dateOnlyIso(today);

    if (lastActiveDate.value.isEmpty) {
      streak.value = 1;
    } else {
      final last = DateTime.parse(lastActiveDate.value);
      final difference = _dateOnly(today).difference(_dateOnly(last)).inDays;
      if (difference == 0) return; // already logged today
      else if (difference == 1) streak.value += 1;
      else streak.value = 1; // reset streak
    }

    lastActiveDate.value = todayStr;
    _checkForBadges();
    await _saveToLocal();
    await _saveToFirebase();
  }

  void _checkForBadges() {
    for (final threshold in badgeThresholds) {
      if (streak.value >= threshold && !earnedBadges.contains(threshold)) {
        earnedBadges.add(threshold);
        Get.snackbar(
          'Badge earned!',
          'You earned $threshold-day streak badge 🏅',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  bool hasBadge(int days) => earnedBadges.contains(days);

  String _dateOnlyIso(DateTime d) => DateTime(d.year, d.month, d.day).toIso8601String();
  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  Future<void> resetAll() async {
    earnedBadges.clear();
    streak.value = 0;
    lastActiveDate.value = '';
    await _saveToLocal();
    await _saveToFirebase();
  }
}
