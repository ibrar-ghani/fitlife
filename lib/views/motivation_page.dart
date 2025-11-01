import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/motivation_controller.dart';

class MotivationPage extends StatelessWidget {
  final MotivationController controller = Get.put(MotivationController());

  MotivationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Motivation"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),

          // Title
          const Text(
            "Daily Motivation",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          // Quote List (Scrollable)
          Expanded(
            child: Obx(() {
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: controller.quotes.length,
                itemBuilder: (context, index) {
                  final quote = controller.quotes[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 8,
                          spreadRadius: 1,
                          color: Colors.black.withOpacity(0.08),
                        ),
                      ],
                    ),
                    child: Text(
                      quote,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                  );
                },
              );
            }),
          ),

          // New Quote Button
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: ElevatedButton(
              onPressed: controller.addRandomQuote,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'New Quote',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
