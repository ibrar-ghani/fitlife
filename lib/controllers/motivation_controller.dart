import 'dart:convert';
import 'package:fitlife/controllers/auth_controller.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

class MotivationController extends GetxController {
  final AuthController auth = Get.find();

  // Quotes
  RxList<String> quotes = <String>[].obs;

  // Video URLs
  final List<String> videoLinks = [
    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4",
    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4",
  ];

  // Lazy-loaded video controllers
  RxMap<int, VideoPlayerController> videoControllers = <int, VideoPlayerController>{}.obs;
  RxMap<int, ChewieController> chewieControllers = <int, ChewieController>{}.obs;

  // Likes
  RxMap<int, bool> likedVideos = <int, bool>{}.obs;
  RxMap<int, int> likeCounts = <int, int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _fetchQuote();
    // ❌ REMOVE auto-initialize here
    // initializeVideo(0); 
  }

  /// Initialize video lazily
  Future<void> initializeVideo(int index, {bool autoPlay = false}) async {
    if (videoControllers.containsKey(index)) return;

    try {
      final vc = VideoPlayerController.networkUrl(
        Uri.parse(videoLinks[index]),
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );
      await vc.initialize();
      vc.setLooping(true);

      final chewie = ChewieController(
        videoPlayerController: vc,
        autoPlay: autoPlay, // only auto-play if requested
        looping: true,
        showControls: false,
      );

      videoControllers[index] = vc;
      chewieControllers[index] = chewie;
    } catch (e) {
      print("Video $index initialization failed: $e");
    }
  }

  /// Play a video
  void playVideo(int index) {
    final vc = videoControllers[index];
    if (vc != null && !vc.value.isPlaying) vc.play();
  }

  /// Pause a video
  void pauseVideo(int index) {
    final vc = videoControllers[index];
    if (vc != null && vc.value.isPlaying) vc.pause();
  }

  /// Pause all videos
  void pauseAllVideos() {
    videoControllers.values.forEach((vc) => vc.pause());
  }

  /// Like a video
  Future<void> handleLike(int index) async {
    if (auth.user == null) return;

    likedVideos[index] = true;
    likeCounts[index] = (likeCounts[index] ?? 0) + 1;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(auth.user!.uid)
          .collection('motivationLikes')
          .doc(index.toString())
          .set({'liked': true, 'timestamp': FieldValue.serverTimestamp()});
    } catch (e) {
      print("Error saving like: $e");
    }
  }

  /// Fetch daily quote
  Future<void> _fetchQuote() async {
    if (auth.user == null) return;

    try {
      final uid = auth.user!.uid;
      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('motivation')
          .doc('dailyQuote');

      final today = DateTime.now().toIso8601String().split('T')[0];
      final snapshot = await docRef.get();

      String newQuote = "Stay strong 💪 Keep moving";

      if (!snapshot.exists || snapshot['date'] != today) {
        try {
          final response = await http.get(Uri.parse("https://zenquotes.io/api/random"));
          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            newQuote = "${data[0]['q']} — ${data[0]['a']}";
          }
        } catch (_) {}

        quotes.value = [newQuote];
        await docRef.set({'quote': newQuote, 'date': today});
      } else {
        quotes.value = [snapshot['quote']];
      }
    } catch (e) {
      quotes.value = ["Stay strong 💪 Keep moving"];
      print("Quote fetch error: $e");
    }
  }

  @override
  void onClose() {
    videoControllers.values.forEach((vc) => vc.dispose());
    chewieControllers.values.forEach((ch) => ch.dispose());
    super.onClose();
  }
}
