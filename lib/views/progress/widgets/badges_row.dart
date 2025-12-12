import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/badge_controller.dart';
import '../../../controllers/auth_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BadgesRow extends StatelessWidget {
  BadgesRow({Key? key}) : super(key: key);
  final BadgeController badge = Get.find();
  final AuthController auth = Get.find();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String get _userPath => 'users/${auth.user?.uid}/badges';

  Widget badgeCard(int days, String label, IconData icon) {
    final unlocked = badge.hasBadge(days);
    return Card(
      color: unlocked ? Colors.amber.shade100 : Colors.grey.shade200,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Icon(icon, color: unlocked ? Colors.orange : Colors.grey, size: 28),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(
              unlocked ? "Unlocked" : "Locked",
              style: TextStyle(color: unlocked ? Colors.green : Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  /// Load earned badges from Firebase
  Future<void> _loadBadges() async {
    if (auth.user == null) return;
    try {
      final doc = await _firestore.doc(_userPath).get();
      if (doc.exists) {
        final data = doc.data();
        final streakValue = data?['streak'] ?? 0;
        final badges = List<int>.from(data?['earnedBadges'] ?? []);
        badge.streak.value = streakValue;
        badge.earnedBadges.assignAll(badges);
        badge.lastActiveDate.value = data?['lastActiveDate'] ?? '';
      }
    } catch (e) {
      print("Error loading badges: $e");
    }
  }

  /// Save earned badges and streak to Firebase
  Future<void> _saveBadges() async {
    if (auth.user == null) return;
    try {
      await _firestore.doc(_userPath).set({
        'streak': badge.streak.value,
        'earnedBadges': badge.earnedBadges,
        'lastActiveDate': badge.lastActiveDate.value,
      });
    } catch (e) {
      print("Error saving badges: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    _loadBadges(); // load once on build

    // Observe changes and save automatically
    ever(badge.earnedBadges, (_) => _saveBadges());
    ever(badge.streak, (_) => _saveBadges());
    ever(badge.lastActiveDate, (_) => _saveBadges());

    return SizedBox(
      height: 130,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          Obx(() => badgeCard(3, "3 Days", Icons.looks_3)),
          const SizedBox(width: 8),
          Obx(() => badgeCard(7, "7 Days", Icons.filter_7)),
          const SizedBox(width: 8),
          Obx(() => badgeCard(14, "14 Days", Icons.celebration)),
        ],
      ),
    );
  }
}
