import 'dart:convert';
import 'package:fitlife/controllers/auth_controller.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

class MotivationController extends GetxController {
  final AuthController auth = Get.find();

  RxBool isLoading = false.obs;
  RxList<String> quotes = <String>[].obs;

  // Demo videos
  RxList<String> videoLinks = <String>[
    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4",
    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4",
  ].obs;

  RxMap<int, VideoPlayerController> videoControllers = <int, VideoPlayerController>{}.obs;
  RxMap<int, ChewieController> chewieControllers = <int, ChewieController>{}.obs;

  // Firebase likes
  RxMap<int, bool> likedVideos = <int, bool>{}.obs;
  RxMap<int, int> likeCounts = <int, int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    initializeReels();
    fetchQuote();
    loadLikes();
  }

  /// Initialize video players
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
        autoPlay: i == 0, // first video autoplay
        looping: true,
        showControls: false,
      );

      videoControllers[i] = vc;
      chewieControllers[i] = chewie;
    }
    update();
  }

  /// Fetch daily quote & store in Firestore
  Future<void> fetchQuote() async {
    if (auth.user == null) return;

    isLoading.value = true;

    try {
      final uid = auth.user!.uid;
      final doc = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('motivation')
          .doc('dailyQuote');

      final today = DateTime.now().toIso8601String().split('T')[0];
      final snapshot = await doc.get();

      // If new day → fetch new quote
      if (!snapshot.exists || snapshot['date'] != today) {
        String newQuote = "Stay strong 💪 Keep moving";

        final response = await http.get(Uri.parse("https://zenquotes.io/api/random"));
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          newQuote = "${data[0]['q']} — ${data[0]['a']}";
        }

        quotes.value = [newQuote];

        await doc.set({
          'quote': newQuote,
          'date': today,
        });
      } else {
        quotes.value = [snapshot['quote']];
      }
    } catch (e) {
      quotes.value = ["Stay strong 💪 Keep moving"];
    } finally {
      isLoading.value = false;
    }
  }

  /// Load Firestore likes
  Future<void> loadLikes() async {
    if (auth.user == null) return;

    final uid = auth.user!.uid;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('motivationLikes')
        .get();

    for (var doc in snapshot.docs) {
      final index = int.tryParse(doc.id);
      if (index != null) {
        likedVideos[index] = doc['liked'] ?? false;
        likeCounts[index] = likedVideos[index]! ? 1 : 0;
      }
    }
  }

  /// Handle double tap to like
  Future<void> handleLike(int index) async {
    if (auth.user == null) return;

    final uid = auth.user!.uid;

    likedVideos[index] = true;
    likeCounts[index] = (likeCounts[index] ?? 0) + 1;
    update();

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('motivationLikes')
        .doc(index.toString())
        .set({
      'liked': true,
      'timestamp': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
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
