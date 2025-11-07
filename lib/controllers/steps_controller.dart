import 'package:get/get.dart';

class StepsController extends GetxController {
  RxInt steps = 0.obs;
  final int dailyGoal = 8000; // example goal

  void addSteps(int amount) {
    steps.value += amount;
  }

  double progress() {
    return (steps.value / dailyGoal).clamp(0.0, 1.0);
  }
}
