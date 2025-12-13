import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BadgeController extends GetxController {
  final List<int> badgeThresholds = [3, 7, 14];

  final RxList<int> earnedBadges = <int>[].obs;
  final RxInt streak = 0.obs;
  final RxString lastActiveDate = ''.obs;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String get _docPath => 'users/${_auth.currentUser?.uid}/badges/data';

  @override
  void onInit() {
    super.onInit();
    _loadFromFirebase();
  }

  // ---------------------------------------------------------
  // 🔥 LOAD (Firebase = source of truth)
  // ---------------------------------------------------------
  Future<void> _loadFromFirebase() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final doc = await _firestore.doc(_docPath).get();
      if (!doc.exists) return;

      final data = doc.data()!;
      streak.value = data['streak'] ?? 0;
      lastActiveDate.value = data['lastActiveDate'] ?? '';
      earnedBadges.assignAll(List<int>.from(data['earnedBadges'] ?? []));
    } catch (e) {
      print('Badge load error: $e');
    }
  }

  // ---------------------------------------------------------
  // 🔥 SAVE (called explicitly only)
  // ---------------------------------------------------------
  Future<void> _saveToFirebase() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore.doc(_docPath).set({
        'streak': streak.value,
        'lastActiveDate': lastActiveDate.value,
        'earnedBadges': earnedBadges.toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Badge save error: $e');
    }
  }

  // ---------------------------------------------------------
  // 🔥 DAILY ACTIVITY
  // ---------------------------------------------------------
  Future<void> registerDailyActivity(DateTime today) async {
    final todayDate = _dateOnly(today);

    if (lastActiveDate.value.isNotEmpty) {
      final last = DateTime.parse(lastActiveDate.value);
      final diff = todayDate.difference(_dateOnly(last)).inDays;

      if (diff == 0) return; // already counted today
      streak.value = diff == 1 ? streak.value + 1 : 1;
    } else {
      streak.value = 1;
    }

    lastActiveDate.value = todayDate.toIso8601String();
    _checkForBadges();
    await _saveToFirebase();
  }

  void _checkForBadges() {
    for (final t in badgeThresholds) {
      if (streak.value >= t && !earnedBadges.contains(t)) {
        earnedBadges.add(t);

        Get.snackbar(
          '🏅 Badge Unlocked',
          '$t-day streak achieved!',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  bool hasBadge(int days) => earnedBadges.contains(days);

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  // ---------------------------------------------------------
  // 🔥 RESET (optional)
  // ---------------------------------------------------------
  Future<void> resetAll() async {
    earnedBadges.clear();
    streak.value = 0;
    lastActiveDate.value = '';
    await _saveToFirebase();
  }
}
