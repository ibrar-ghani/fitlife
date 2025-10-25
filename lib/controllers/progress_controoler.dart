import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProgressController extends GetxController {
  RxList<double> progressList = <double>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadProgress();
  }

  Future<void> loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('progress') ?? [];
    progressList.value = saved.map((e) => double.parse(e)).toList();
  }

  Future<void> addProgress(double weight) async {
    progressList.add(weight);
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('progress', progressList.map((e) => e.toString()).toList());
  }
}
