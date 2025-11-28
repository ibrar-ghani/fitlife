import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';

class MotivationController extends GetxController {
  RxBool isLoading = false.obs;
  RxList<String> quotes = <String>[].obs;

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
    initializeReels();
  }

  Future<void> fetchQuote() async {
    try {
      isLoading.value = true;
      final response = await http.get(Uri.parse("https://zenquotes.io/api/random"));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        for (int i = 0; i < videoLinks.length; i++) {
  quotes.add("${data[0]['q']} — ${data[0]['a']}");
}

      } else {
        quotes.add("Believe in yourself.");
      }
    } catch (_) {
      quotes.add("Stay positive, work hard, and make it happen.");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> initializeReels() async {
    for (int i = 0; i < videoLinks.length; i++) {
      final vc = VideoPlayerController.networkUrl(
  Uri.parse(videoLinks[i]),
  videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
);
      await vc.initialize();
      vc.setLooping(true);

      final chewie = ChewieController(
        videoPlayerController: vc,
        autoPlay: i == 0,
        looping: true,
        showControls: false,
      );

      videoControllers[i] = vc;
      chewieControllers[i] = chewie;
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
