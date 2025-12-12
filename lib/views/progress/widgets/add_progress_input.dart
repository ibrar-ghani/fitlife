import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/badge_controller.dart';
import '../../../controllers/auth_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddProgressInput extends StatefulWidget {
  const AddProgressInput({Key? key}) : super(key: key);

  @override
  State<AddProgressInput> createState() => _AddProgressInputState();
}

class _AddProgressInputState extends State<AddProgressInput> {
  final TextEditingController input = TextEditingController();
  final BadgeController badge = Get.find();
  final AuthController auth = Get.find();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<double> data = [];

  String get _userPath => 'users/${auth.user?.uid}/progress';

  @override
  void initState() {
    super.initState();
    _load();
  }

  /// Load progress from Firebase
  Future<void> _load() async {
    if (auth.user == null) return;
    try {
      final doc = await _firestore.doc(_userPath).get();
      if (doc.exists) {
        final saved = List<dynamic>.from(doc.data()?['entries'] ?? []);
        setState(() {
          data = saved.map((e) => (e as num).toDouble()).toList();
        });
      }
    } catch (e) {
      print("Error loading progress: $e");
    }
  }

  /// Save progress to Firebase
  Future<void> _save() async {
    if (auth.user == null) return;
    try {
      await _firestore.doc(_userPath).set({
        'entries': data,
        'lastUpdated': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print("Error saving progress: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: input,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: "Today's Run (km)",
            ),
          ),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: () async {
            final v = double.tryParse(input.text);
            if (v != null) {
              data.add(v);
              await _save(); // Save to Firebase
              badge.registerDailyActivity(DateTime.now()); // Update streak & badges
              input.clear();
              setState(() {});
              Get.snackbar(
                "Progress Added",
                "You ran $v km today!",
                snackPosition: SnackPosition.BOTTOM,
              );
            }
          },
          child: const Text("Add"),
        ),
      ],
    );
  }
}
