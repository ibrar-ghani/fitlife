import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:share_plus/share_plus.dart';
import '../controllers/motivation_controller.dart';

class MotivationPage extends StatefulWidget {
  const MotivationPage({super.key});

  @override
  State<MotivationPage> createState() => _MotivationPageState();
}

class _MotivationPageState extends State<MotivationPage>
    with SingleTickerProviderStateMixin {

  final MotivationController controller = Get.put(MotivationController());
  final PageController _pageController = PageController();

  Map<int, bool> liked = {};
  Map<int, int> likeCounts = {};
  Map<int, bool> showHeart = {};

  late AnimationController _heartController;
  late Animation<double> _heartAnimation;

  @override
  void initState() {
    super.initState();

    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _heartAnimation = Tween(begin: 0.6, end: 1.3).animate(
      CurvedAnimation(parent: _heartController, curve: Curves.easeOut),
    );

    for (int i = 0; i < controller.videoLinks.length; i++) {
      liked[i] = false;
      likeCounts[i] = 0;
      showHeart[i] = false;
    }
  }

  void _handleDoubleTap(int index) {
    setState(() {
      liked[index] = true;
      likeCounts[index] = (likeCounts[index] ?? 0) + 1;
      showHeart[index] = true;
    });

    _heartController.forward().then((_) {
      _heartController.reverse();
      Future.delayed(const Duration(milliseconds: 300), () {
        setState(() => showHeart[index] = false);
      });
    });
  }

  void _shareVideo(String url) {
    Share.share("🔥 FitLife Motivation Reel\n$url");
  }

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
          children: [
            const Text("Comments",
                style: TextStyle(color: Colors.white, fontSize: 18)),
            const Divider(color: Colors.white24),
            const Expanded(
              child: Center(
                child: Text("No comments yet 😕",
                    style: TextStyle(color: Colors.white70)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onPageChanged(int index) {
    controller.videoControllers.forEach((key, vc) => vc.pause());
    controller.videoControllers[index]?.play();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Obx(() {
        if (controller.chewieControllers.isEmpty) {
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

            if (videoController == null ||
                !videoController.value.isInitialized) {
              return const Center(child: CircularProgressIndicator());
            }

            return Stack(
              fit: StackFit.expand,
              children: [

                /// ✅ FULLSCREEN REELS VIDEO
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

                /// ✅ QUOTE OVERLAY
                Positioned(
                  left: 16,
                  right: 80,
                  bottom: 140,
                  child: Text(
                    controller.quotes.isNotEmpty
                        ? controller.quotes.first
                        : "Stay strong 💪 Keep moving",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                /// ❤️ HEART ANIMATION (PER VIDEO)
                if (showHeart[index] == true)
                  Center(
                    child: ScaleTransition(
                      scale: _heartAnimation,
                      child: const Icon(
                        Icons.favorite,
                        color: Colors.redAccent,
                        size: 120,
                      ),
                    ),
                  ),

                /// ✅ SIDEBAR
                Positioned(
                  right: 12,
                  bottom: 140,
                  child: Column(
                    children: [
                      IconButton(
                        icon: Icon(
                          liked[index] == true
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: liked[index] == true
                              ? Colors.red
                              : Colors.white,
                          size: 32,
                        ),
                        onPressed: () => _handleDoubleTap(index),
                      ),
                      Text(
                        '${likeCounts[index]}',
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 20),

                      IconButton(
                        icon: const Icon(Icons.comment, color: Colors.white),
                        onPressed: _showComments,
                      ),
                      const Text("Comment",
                          style: TextStyle(color: Colors.white)),
                      const SizedBox(height: 20),

                      IconButton(
                        icon: const Icon(Icons.share, color: Colors.white),
                        onPressed: () =>
                            _shareVideo(controller.videoLinks[index]),
                      ),
                      const Text("Share",
                          style: TextStyle(color: Colors.white)),
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
    _heartController.dispose();
    super.dispose();
  }
}