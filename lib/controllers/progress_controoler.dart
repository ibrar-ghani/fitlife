import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProgressController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RxList<double> progressList = <double>[].obs;
  RxBool isLoading = true.obs;

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

    _firestore
        .collection('users')
        .doc(user.uid)
        .collection('progress')
        .orderBy('createdAt')
        .snapshots()
        .listen((snapshot) {
      final data = snapshot.docs
          .map((doc) => (doc['value'] as num).toDouble())
          .toList();

      progressList.value = data;
      isLoading.value = false;
    });
  }

  Future<void> addProgress(double value) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('progress')
        .add({
      'value': value,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Optional: compute summary metrics
  int get entries => progressList.length;
  double get average =>
      progressList.isEmpty ? 0.0 : progressList.reduce((a, b) => a + b) / progressList.length;
  double get maxValue => progressList.isEmpty
      ? 0.0
      : progressList.reduce((a, b) => a > b ? a : b);
}
