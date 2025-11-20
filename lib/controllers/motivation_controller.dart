import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class MotivationController extends GetxController {
  RxBool isLoading = false.obs;
  RxList<String> quotes = <String>[].obs;

  // Stable online MP4 links (working ones)
  RxList<String> videoLinks = <String>[
    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4",
    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4",
  ].obs;

  RxMap<int, VideoPlayerController> videoControllers = <int, VideoPlayerController>{}.obs;
  RxMap<int, ChewieController> chewieControllers = <int, ChewieController>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchQuote();
    initializeAllVideos();
  }

  Future<void> fetchQuote() async {
    try {
      isLoading.value = true;
      final response = await http.get(Uri.parse("https://zenquotes.io/api/random"));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        quotes.add("${data[0]["q"]} — ${data[0]["a"]}");
      } else {
        quotes.add("Believe in yourself.");
      }
    } catch (e) {
      quotes.add("Stay positive, work hard, and make it happen.");
    } finally {
      isLoading.value = false;
    }
  }

  /// Initialize ALL videos at once (no FutureBuilder needed)
  void initializeAllVideos() async {
    for (int i = 0; i < videoLinks.length; i++) {
      try {
        final vc = VideoPlayerController.networkUrl(Uri.parse(videoLinks[i]));

        await vc.initialize();
        vc.setLooping(true);
        vc.play();

        final chewie = ChewieController(
          videoPlayerController: vc,
          autoPlay: true,
          looping: true,
          showControls: false,
        );

        videoControllers[i] = vc;
        chewieControllers[i] = chewie;

      } catch (e) {
        print("Video error ($i): $e");
      }
    }

    update();
  }

  @override
  void onClose() {
    for (var vc in videoControllers.values) {
      vc.dispose();
    }
    for (var ch in chewieControllers.values) {
      ch.dispose();
    }
    super.onClose();
  }
}
