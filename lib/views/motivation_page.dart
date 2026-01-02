import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chewie/chewie.dart';
import 'package:share_plus/share_plus.dart';
import '../../controllers/motivation_controller.dart';

class MotivationPage extends StatefulWidget {
  const MotivationPage({super.key});

  @override
  State<MotivationPage> createState() => _MotivationPageState();
}

class _MotivationPageState extends State<MotivationPage> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final MotivationController controller = Get.put(MotivationController());
  final PageController _pageController = PageController();

  late AnimationController _heartController;
  late Animation<double> _heartAnimation;
  Map<int, bool> showHeart = {};

  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _heartAnimation = Tween(begin: 0.6, end: 1.3).animate(
      CurvedAnimation(parent: _heartController, curve: Curves.easeOut),
    );

    for (int i = 0; i < controller.videoLinks.length; i++) {
      showHeart[i] = false;
    }

    // Initialize first video but DO NOT autoplay yet
    controller.initializeVideo(0);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Pause all videos when app goes into background
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      controller.pauseAllVideos();
    } else if (state == AppLifecycleState.resumed) {
      // Play current video if the user is on Motivation page
      controller.videoControllers[currentPage]?.play();
    }
  }

  void _handleDoubleTap(int index) {
    setState(() => showHeart[index] = true);
    controller.handleLike(index);

    _heartController.forward().then((_) {
      _heartController.reverse();
      Future.delayed(const Duration(milliseconds: 300), () {
        setState(() => showHeart[index] = false);
      });
    });
  }

  void _shareVideo(String url) => Share.share("🔥 FitLife Motivation Reel\n$url");

  void _showComments() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black87,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (_) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: const [
            Text("Comments", style: TextStyle(color: Colors.white, fontSize: 18)),
            Divider(color: Colors.white24),
            Expanded(child: Center(child: Text("No comments yet 😕", style: TextStyle(color: Colors.white70)))),
          ],
        ),
      ),
    );
  }

  void _onPageChanged(int index) async {
    currentPage = index;

    // Pause all other videos
    controller.pauseAllVideos();

    // Lazy initialize current video & autoplay
    await controller.initializeVideo(index, autoPlay: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Obx(() {
        if (controller.chewieControllers.keys.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return PageView.builder(
          controller: _pageController,
          scrollDirection: Axis.vertical,
          itemCount: controller.videoLinks.length,
          onPageChanged: _onPageChanged,
          itemBuilder: (context, index) {
            final chewieController = controller.chewieControllers[index];
            final videoController = chewieController?.videoPlayerController;

            if (videoController == null || !videoController.value.isInitialized) {
              return const Center(child: CircularProgressIndicator());
            }

            return Stack(
              fit: StackFit.expand,
              children: [
                GestureDetector(
                  onDoubleTap: () => _handleDoubleTap(index),
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: videoController.value.size.width,
                      height: videoController.value.size.height,
                      child: Chewie(controller: chewieController!),
                    ),
                  ),
                ),

                // Quote overlay
                Positioned(
                  left: 16,
                  right: 80,
                  bottom: 140,
                  child: Obx(() => Text(
                        controller.quotes.isNotEmpty ? controller.quotes.first : "Stay strong 💪 Keep moving",
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                      )),
                ),

                // Heart animation
                if (showHeart[index] == true)
                  Center(
                    child: ScaleTransition(
                      scale: _heartAnimation,
                      child: const Icon(Icons.favorite, color: Colors.redAccent, size: 120),
                    ),
                  ),

                // Sidebar actions
                Positioned(
                  right: 12,
                  bottom: 140,
                  child: Column(
                    children: [
                      Obx(() => IconButton(
                            icon: Icon(
                              controller.likedVideos[index] == true ? Icons.favorite : Icons.favorite_border,
                              color: controller.likedVideos[index] == true ? Colors.red : Colors.white,
                              size: 32,
                            ),
                            onPressed: () => _handleDoubleTap(index),
                          )),
                      Obx(() => Text('${controller.likeCounts[index] ?? 0}', style: const TextStyle(color: Colors.white))),
                      const SizedBox(height: 20),
                      IconButton(icon: const Icon(Icons.comment, color: Colors.white), onPressed: _showComments),
                      const Text("Comment", style: TextStyle(color: Colors.white)),
                      const SizedBox(height: 20),
                      IconButton(icon: const Icon(Icons.share, color: Colors.white), onPressed: () => _shareVideo(controller.videoLinks[index])),
                      const Text("Share", style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      }),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _heartController.dispose();
    controller.pauseAllVideos(); // Ensure no video plays in background
    super.dispose();
  }
}
