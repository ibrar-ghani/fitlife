import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/sleep_controller.dart';

class SleepPage extends StatefulWidget {
  @override
  State<SleepPage> createState() => _SleepPageState();
}

class _SleepPageState extends State<SleepPage> {
  final SleepController controller = Get.put(SleepController());

  DateTime? bedTime;
  DateTime? wakeTime;
  int sleepQuality = 3; // default selected stars

  Future<void> pickBedTime() async {
    final now = DateTime.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        bedTime = DateTime(now.year, now.month, now.day, picked.hour, picked.minute);
      });
    }
  }

  Future<void> pickWakeTime() async {
    final now = DateTime.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        wakeTime = DateTime(now.year, now.month, now.day, picked.hour, picked.minute);
      });
    }
  }

  String _format(DateTime? dt) {
    if (dt == null) return "--:--";
    return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sleep Tracker")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ===== Sleep Input Card =====
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.indigo.shade600,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text("Track Your Sleep", style: TextStyle(color: Colors.white, fontSize: 18)),
                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          const Text("Bed Time", style: TextStyle(color: Colors.white)),
                          Text(_format(bedTime), style: const TextStyle(color: Colors.white, fontSize: 18)),
                          TextButton(
                            onPressed: pickBedTime,
                            child: const Text("Select", style: TextStyle(color: Colors.white70)),
                          )
                        ],
                      ),
                      Column(
                        children: [
                          const Text("Wake Time", style: TextStyle(color: Colors.white)),
                          Text(_format(wakeTime), style: const TextStyle(color: Colors.white, fontSize: 18)),
                          TextButton(
                            onPressed: pickWakeTime,
                            child: const Text("Select", style: TextStyle(color: Colors.white70)),
                          )
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // ⭐ Quality Rating
                  Text("Sleep Quality", style: TextStyle(color: Colors.white)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (i) {
                      return IconButton(
                        icon: Icon(
                          Icons.star,
                          color: i < sleepQuality ? Colors.yellow : Colors.white24,
                        ),
                        onPressed: () => setState(() => sleepQuality = i + 1),
                      );
                    }),
                  ),

                  const SizedBox(height: 10),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                    onPressed: () {
                      if (bedTime == null || wakeTime == null) {
                        Get.snackbar("Missing Data", "Select sleep and wake time.",
                            snackPosition: SnackPosition.BOTTOM);
                        return;
                      }
                      controller.addSleep(bedTime!, wakeTime!, sleepQuality);
                      setState(() {
                        bedTime = null;
                        wakeTime = null;
                        sleepQuality = 3;
                      });
                    },
                    child: const Text("Save Sleep Record", style: TextStyle(color: Colors.black)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ===== Sleep History =====
            Align(
              alignment: Alignment.centerLeft,
              child: Text("Sleep History", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 10),

            Obx(() {
              if (controller.sleepHistory.isEmpty) {
                return const Text("No sleep records yet.");
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: controller.sleepHistory.length,
                itemBuilder: (_, i) {
                  final entry = controller.sleepHistory[i];
                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      title: Text("${entry.hours.toStringAsFixed(1)} hours"),
                      subtitle: Row(
                        children: List.generate(5, (j) => Icon(
                          Icons.star,
                          color: j < entry.quality ? Colors.amber : Colors.grey,
                          size: 18,
                        )),
                      ),
                      trailing: Text(
                        "${entry.bedTime.hour}:${entry.bedTime.minute.toString().padLeft(2, '0')} → "
                        "${entry.wakeTime.hour}:${entry.wakeTime.minute.toString().padLeft(2, '0')}",
                      ),
                    ),
                  );
                },
              );
            })
          ],
        ),
      ),
    );
  }
}