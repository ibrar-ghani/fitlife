import 'package:get/get.dart';

class MotivationController extends GetxController {
  // Observable list of quotes
  RxList<String> quotes = <String>[
    "Push yourself, because no one else will do it for you.",
    "Every day is a new beginning, take a deep breath and start again.",
    "Small steps every day lead to big changes.",
  ].obs;

  // Add a new random motivational quote
  void addRandomQuote() {
    List<String> moreQuotes = [
      "Discipline is choosing what you want most over what you want now.",
      "If you’re tired, learn to rest, not quit.",
      "Small progress is still progress.",
      "Success is the sum of small efforts repeated daily.",
      "Your only limit is you.",
    ];

    final randomIndex = DateTime.now().microsecond % moreQuotes.length;
    quotes.add(moreQuotes[randomIndex]);
  }
}
