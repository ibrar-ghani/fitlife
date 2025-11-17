import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class MotivationReelsPage extends StatelessWidget {
  MotivationReelsPage({super.key});

  // Sample quotes
  final RxList<String> quotes = <String>[
    "Push yourself, because no one else will do it for you.",
    "Every day is a new beginning, take a deep breath and start again.",
    "Small steps every day lead to big changes.",
    "Discipline is choosing what you want most over what you want now.",
  ].obs;

  // Video URLs (YouTube + free online MP4)
  final RxList<String> videoLinks = <String>[
    "https://www.youtube.com/watch?v=mgmVOuLgFB0",
    "https://www.youtube.com/watch?v=wnHW6o8WMas",
    "https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4",
    "https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_5mb.mp4",
  ].obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Motivation Reels"),
        centerTitle: true,
      ),
      body: Obx(() {
        return PageView.builder(
          scrollDirection: Axis.vertical,
          itemCount: videoLinks.length,
          itemBuilder: (context, index) {
            final url = videoLinks[index];
            final quote = quotes[index % quotes.length];

            // Check if YouTube URL
            if (url.contains("youtube.com") || url.contains("youtu.be")) {
              final videoId = YoutubePlayer.convertUrlToId(url)!;
              return Stack(
                fit: StackFit.expand,
                children: [
                  YoutubePlayer(
                    controller: YoutubePlayerController(
                      initialVideoId: videoId,
                      flags: const YoutubePlayerFlags(
                        autoPlay: true,
                        mute: false,
                        loop: true,
                      ),
                    ),
                  ),
                  _quoteOverlay(quote),
                ],
              );
            } else {
              // MP4 Video using Chewie
              final videoController = VideoPlayerController.network(url);
              final chewieController = ChewieController(
                videoPlayerController: videoController,
                autoPlay: true,
                looping: true,
                showControls: false,
              );
              return Stack(
                fit: StackFit.expand,
                children: [
                  Chewie(controller: chewieController),
                  _quoteOverlay(quote),
                ],
              );
            }
          },
        );
      }),
    );
  }

  Widget _quoteOverlay(String quote) {
    return Positioned(
      bottom: 50,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black38,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          quote,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
