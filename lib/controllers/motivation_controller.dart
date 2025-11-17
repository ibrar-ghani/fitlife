import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class MotivationController extends GetxController {
  RxBool isLoading = false.obs;
  RxList<String> quotes = <String>[].obs;

  // Free online MP4 video URLs
  RxList<String> videoLinks = <String>[
    "https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4",
    "https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_5mb.mp4",
    "https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_10mb.mp4",
  ].obs;

  // VideoPlayer + Chewie controllers
  RxMap<int, VideoPlayerController> videoControllers = <int, VideoPlayerController>{}.obs;
  RxMap<int, ChewieController> chewieControllers = <int, ChewieController>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchQuote();
    _initVideoControllers();
  }

  Future<void> fetchQuote() async {
    try {
      isLoading.value = true;
      final response = await http.get(Uri.parse("https://zenquotes.io/api/random"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final quote = "${data[0]["q"]} — ${data[0]["a"]}";
        quotes.add(quote);
      } else {
        quotes.add("Believe in yourself, you are stronger than you think.");
      }
    } catch (e) {
      quotes.add("Stay positive, work hard, and make it happen.");
    } finally {
      isLoading.value = false;
    }
  }

 void _initVideoControllers() async {
  for (int i = 0; i < videoLinks.length; i++) {
    final vc = VideoPlayerController.network(videoLinks[i]);

    try {
      await vc.initialize(); // wait until video is fully initialized
      vc.setLooping(true);
      vc.play();

      final chewieController = ChewieController(
        videoPlayerController: vc,
        autoPlay: true,
        looping: true,
      );

      videoControllers[i] = vc;
      chewieControllers[i] = chewieController;

      update(); // notify UI
    } catch (e) {
      print("Error initializing video $i: $e");
    }
  }
}


  @override
  void onClose() {
    videoControllers.forEach((_, vc) => vc.dispose());
    chewieControllers.forEach((_, ch) => ch.dispose());
    super.onClose();
  }
}
