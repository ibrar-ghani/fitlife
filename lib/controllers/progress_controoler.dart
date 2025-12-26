import 'dart:async';

import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProgressController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RxList<double> progressList = <double>[].obs;
  RxBool isLoading = true.obs;

  StreamSubscription<QuerySnapshot>? _progressSub;

  @override
  void onInit() {
    super.onInit();
    _bindProgressStream();
  }

  void _bindProgressStream() {
    final user = _auth.currentUser;
    if (user == null) {
      isLoading.value = false;
      return;
    }

    _progressSub?.cancel(); // cancel any previous subscription
    _progressSub = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('progress')
        .orderBy('createdAt')
        .snapshots()
        .listen((snapshot) {
      progressList.value = snapshot.docs
          .map((doc) => (doc['value'] as num).toDouble())
          .toList();
      isLoading.value = false;
    }, onError: (e) {
      print("Progress stream error: $e");
      isLoading.value = false;
    });
  }

  Future<void> addProgress(double value) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('progress')
          .add({
        'value': value,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error adding progress: $e");
    }
  }

  // Computed metrics
  int get entries => progressList.length;
  double get average =>
      progressList.isEmpty ? 0.0 : progressList.reduce((a, b) => a + b) / progressList.length;
  double get maxValue =>
      progressList.isEmpty ? 0.0 : progressList.reduce((a, b) => a > b ? a : b);

  @override
  void onClose() {
    _progressSub?.cancel();
    super.onClose();
  }
}
