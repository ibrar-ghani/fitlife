import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/progress_model.dart';

class ProgressController extends GetxController {
  var progressList = <ProgressModel>[].obs;
  var quote = ''.obs;

  @override
  void onInit() {
    loadProgress();
    loadDailyQuote();
    super.onInit();
  }

  Future<void> addProgress(double weight) async {
    final model = ProgressModel(weight: weight, date: DateTime.now());
    progressList.add(model);
    await saveProgress();
  }

  Future<void> saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(progressList.map((e) => e.toJson()).toList());
    await prefs.setString('progressData', encoded);
  }

  Future<void> loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('progressData');
    if (data != null) {
      final decoded = jsonDecode(data) as List;
      progressList.value =
          decoded.map((e) => ProgressModel.fromJson(e)).toList();
    }
  }

  void loadDailyQuote() {
    final quotes = [
      "Push yourself, because no one else will do it for you.",
      "Every step counts, no matter how small.",
      "Discipline beats motivation every single day.",
      "Consistency is what transforms average into excellence."
    ];
    quote.value = quotes[DateTime.now().day % quotes.length];
  }
}
