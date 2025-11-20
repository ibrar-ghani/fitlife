import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chewie/chewie.dart';
import '../controllers/motivation_controller.dart';

class MotivationPage extends StatelessWidget {
  final MotivationController controller = Get.put(MotivationController());

  MotivationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.chewieControllers.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return PageView.builder(
          scrollDirection: Axis.vertical,
          itemCount: controller.videoLinks.length,
          itemBuilder: (context, index) {
            final chewie = controller.chewieControllers[index];

            if (chewie == null) {
              return const Center(child: CircularProgressIndicator());
            }

            return Stack(
              fit: StackFit.expand,
              children: [
                Chewie(controller: chewie),

                // Quote text overlay
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
                      style: const TextStyle(
                          color: Colors.white, fontSize: 18, height: 1.4),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      }),
    );
  }
}
