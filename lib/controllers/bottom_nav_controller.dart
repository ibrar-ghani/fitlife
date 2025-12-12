import 'package:get/get.dart';

class BottomNavController extends GetxController {
  RxInt currentIndex = 0.obs;

  // Change tab index
  void changeTab(int index) {
    currentIndex.value = index;
  }

  // Optional: helper to get current index
  int get activeTab => currentIndex.value;
}
