import 'package:get/get.dart';
import 'package:firebase_storage/firebase_storage.dart';

class MotivationVideoController extends GetxController {
  RxList<String> youtubeVideos = <String>[
    "https://www.youtube.com/watch?v=mgmVOuLgFB0",
    "https://www.youtube.com/watch?v=wnHW6o8WMas",
  ].obs;

  RxList<String> firebaseVideos = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchFirebaseVideos();
  }

  Future<void> fetchFirebaseVideos() async {
    try {
      final storageRef =
          FirebaseStorage.instance.ref().child("motivation_videos");

      final ListResult result = await storageRef.listAll();

      final urls = await Future.wait(
        result.items.map((item) => item.getDownloadURL()),
      );

      firebaseVideos.value = urls;
    } catch (e) {
      print("❌ Firebase Video Fetch Error: $e");
    }
  }
}
