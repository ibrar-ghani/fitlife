import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProgressController extends GetxController {
  RxList<double> progressList = <double>[].obs;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    _loadProgress();
  }

  // ---------------------------------------------------------
  // 🔥 Load progress from Firebase or fallback to SharedPreferences
  // ---------------------------------------------------------
  Future<void> _loadProgress() async {
    final user = _auth.currentUser;
    bool loadedFromFirebase = false;

    if (user != null) {
      try {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists && doc.data()?['progress'] != null) {
          List<dynamic> data = doc.data()?['progress'];
          progressList.value = data.map((e) => (e as num).toDouble()).toList();
          loadedFromFirebase = true;
        }
      } catch (e) {
        print("Firebase loadProgress error: $e");
      }
    }

    if (!loadedFromFirebase) {
      // fallback to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getStringList('progress') ?? [];
      progressList.value = saved.map((e) => double.parse(e)).toList();
    }
  }

  // ---------------------------------------------------------
  // 🔥 Add new progress entry
  // ---------------------------------------------------------
  Future<void> addProgress(double value) async {
    progressList.add(value);

    final user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore.collection('users').doc(user.uid).set({
          'progress': progressList.toList(),
        }, SetOptions(merge: true));
      } catch (e) {
        print("Firebase addProgress error: $e");
      }
    }

    // Save locally
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'progress',
      progressList.map((e) => e.toString()).toList(),
    );
  }
}
