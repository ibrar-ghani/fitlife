import 'package:get/get.dart';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QuotesController extends GetxController {
  final List<String> defaultQuotes = [
    "Push yourself, because no one else is going to do it for you.",
    "Success starts with self-discipline.",
    "Don’t limit your challenges. Challenge your limits.",
    "The harder you work for something, the greater you’ll feel when you achieve it.",
    "Wake up with determination. Go to bed with satisfaction.",
    "Your body can stand almost anything. It’s your mind you have to convince.",
    "Don’t watch the clock; do what it does. Keep going.",
    "The pain you feel today will be the strength you feel tomorrow.",
    "Motivation is what gets you started. Habit is what keeps you going.",
    "It never gets easier, you just get stronger."
  ];

  RxString dailyQuote = "".obs;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    _loadOrSetQuote();
  }

  /// 🔥 Load quote from Firebase if exists; otherwise, pick a random one and save
  Future<void> _loadOrSetQuote() async {
    final user = _auth.currentUser;
    if (user == null) {
      _setRandomQuote();
      return;
    }

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data()?['dailyQuote'] != null) {
        dailyQuote.value = doc.data()?['dailyQuote'];
      } else {
        _setRandomQuote();
        await _saveQuoteToFirebase(dailyQuote.value);
      }
    } catch (e) {
      print("QuotesController Firebase load error: $e");
      _setRandomQuote();
    }
  }

  /// 🔥 Pick a random quote locally
  void _setRandomQuote() {
    final random = Random();
    dailyQuote.value = defaultQuotes[random.nextInt(defaultQuotes.length)];
  }

  /// 🔥 Save quote to Firebase safely
  Future<void> _saveQuoteToFirebase(String quote) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore.collection('users').doc(user.uid).set(
        {'dailyQuote': quote},
        SetOptions(merge: true),
      );
    } catch (e) {
      print("QuotesController Firebase save error: $e");
    }
  }

  /// 🔥 Refresh to a new random quote and save it
  Future<void> refreshQuote() async {
    _setRandomQuote();
    await _saveQuoteToFirebase(dailyQuote.value);
  }
}
