import 'package:get/get.dart';

class BottomNavController extends GetxController {
  // Current selected tab index
  final RxInt currentIndex = 0.obs;

  // Change the active tab
  void changeTab(int index) {
    if (index != currentIndex.value) {
      currentIndex.value = index;
    }
  }

  // Helper to get the current active tab index
  int get activeTab => currentIndex.value;
}
