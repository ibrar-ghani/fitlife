import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import '../controllers/motivation_controller.dart';

class MotivationPage extends StatelessWidget {
  final MotivationController controller = Get.put(MotivationController());

  MotivationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value && controller.quotes.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return PageView.builder(
          scrollDirection: Axis.vertical,
          itemCount: controller.videoLinks.length,
          itemBuilder: (context, index) {
            return FutureBuilder<ChewieController>(
              future: _initVideoController(index),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

              final chewie = snapshot.data!;

return Stack(
  fit: StackFit.expand,
  children: [
    FittedBox(
      fit: BoxFit.cover, // Makes video full screen like TikTok
      child: SizedBox(
        width: chewie.videoPlayerController.value.size.width,
        height: chewie.videoPlayerController.value.size.height,
        child: Chewie(controller: chewie),
      ),
    ),

    // QUOTE OVERLAY
    Positioned(
      bottom: 60,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black38,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          controller.quotes.isNotEmpty
              ? controller.quotes[index % controller.quotes.length]
              : "Stay motivated!",
          style: const TextStyle(color: Colors.white, fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    ),
  ],
);

              },
            );
          },
        );
      }),
    );
  }

  Future<ChewieController> _initVideoController(int index) async {
    if (controller.chewieControllers.containsKey(index)) {
      return controller.chewieControllers[index]!;
    }

    final videoController = VideoPlayerController.network(controller.videoLinks[index]);
    await videoController.initialize();
    videoController.setLooping(true);
    videoController.play();

    final chewieController = ChewieController(
      videoPlayerController: videoController,
      autoPlay: true,
      looping: true,
    );

    controller.videoControllers[index] = videoController;
    controller.chewieControllers[index] = chewieController;

    return chewieController;
  }
}