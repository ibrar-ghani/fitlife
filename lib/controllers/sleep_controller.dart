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
    // ✅ Handle sleep across midnight (e.g. 23:00 to 07:00)
    if (wake.isBefore(bed)) {
      wake = wake.add(const Duration(days: 1));
    }

    final hours = wake.difference(bed).inMinutes / 60;

    sleepHistory.add(
      SleepEntry(
        bedTime: bed,
        wakeTime: wake,
        hours: hours,
        quality: quality,
      ),
    );

    await _save();
  }

  Future<void> deleteSleep(int index) async {
    sleepHistory.removeAt(index);
    await _save();
  }

  double averageSleep() {
    if (sleepHistory.isEmpty) return 0.0;
    return sleepHistory.fold(0.0, (sum, e) => sum + e.hours) / sleepHistory.length;
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'sleep_history',
      sleepHistory.map((e) => jsonEncode(e.toJson())).toList(),
    );
  }
}
