import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/sleep_model.dart';

class SleepController extends GetxController {
  RxList<SleepEntry> sleepHistory = <SleepEntry>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadHistory();
  }

  Future<void> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList('sleep_history') ?? [];
    sleepHistory.value =
        data.map((e) => SleepEntry.fromJson(jsonDecode(e))).toList();
  }

  Future<void> addSleep(DateTime bed, DateTime wake, int quality) async {
    final duration = wake.difference(bed).inMinutes / 60;
    sleepHistory.add(SleepEntry(
      bedTime: bed,
      wakeTime: wake,
      hours: duration,
      quality: quality,
    ));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'sleep_history',
      sleepHistory.map((e) => jsonEncode(e.toJson())).toList(),
    );
  }

  double averageSleep() {
    if (sleepHistory.isEmpty) return 0.0;
    return sleepHistory.map((e) => e.hours).reduce((a, b) => a + b) /
        sleepHistory.length;
  }
}