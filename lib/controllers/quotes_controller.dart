import 'package:get/get.dart';
import 'dart:math';

class QuotesController extends GetxController {
  final quotes = [
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

  @override
  void onInit() {
    super.onInit();
    _setRandomQuote();
  }

  void _setRandomQuote() {
    final random = Random();
    dailyQuote.value = quotes[random.nextInt(quotes.length)];
  }

  void refreshQuote() {
    _setRandomQuote();
  }
}
