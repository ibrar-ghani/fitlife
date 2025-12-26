import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/sleep_controller.dart';
import '../../widgets/sleep_bar_chart.dart';

class SleepPage extends StatefulWidget {
  const SleepPage({super.key});

  @override
  State<SleepPage> createState() => _SleepPageState();
}

class _SleepPageState extends State<SleepPage> {
  final SleepController controller = Get.put(SleepController());

  DateTime? bedTime;
  DateTime? wakeTime;
  int sleepQuality = 3;

  Future<void> pickTime(bool isBed) async {
    final now = DateTime.now();
    final picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null) {
      setState(() {
        final dt = DateTime(now.year, now.month, now.day, picked.hour, picked.minute);
        if (isBed) {
          bedTime = dt;
        } else {
          wakeTime = dt;
        }
      });
    }
  }

  String _formatTime(DateTime? t) =>
      t == null ? "--:--" : "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sleep Tracker")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Average Sleep
            
            Obx(() => Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Colors.indigo, Colors.blue]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
       "Average Sleep: ${controller.average.toStringAsFixed(1)} hrs/night",
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    )),

            const SizedBox(height: 18),

            // Sleep Input
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.indigo.shade600, borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  const Text("Track Your Sleep", style: TextStyle(color: Colors.white, fontSize: 18)),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _timeBox("Bed Time", _formatTime(bedTime), () => pickTime(true)),
                      _timeBox("Wake Time", _formatTime(wakeTime), () => pickTime(false)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text("Sleep Quality", style: const TextStyle(color: Colors.white)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      5,
                      (i) => IconButton(
                        icon: Icon(Icons.star, color: i < sleepQuality ? Colors.yellow : Colors.white24),
                        onPressed: () => setState(() => sleepQuality = i + 1),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                    onPressed: () {
                      if (bedTime == null || wakeTime == null) {
                        Get.snackbar("Missing Data", "Please select times", snackPosition: SnackPosition.BOTTOM);
                        return;
                      }
                      controller.addSleep(bedTime!, wakeTime!, sleepQuality);
                      setState(() {
                        bedTime = null;
                        wakeTime = null;
                        sleepQuality = 3;
                      });
                    },
                    child: const Text("Save", style: TextStyle(color: Colors.black)),
                  )
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Sleep Bar Chart
            Obx(() => controller.sleepHistory.isEmpty
                ? const SizedBox()
                : SleepBarChart(data: controller.sleepHistory.toList())),

            const SizedBox(height: 20),

            Align(
              alignment: Alignment.centerLeft,
              child: const Text("Sleep History", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),

            Obx(() => controller.sleepHistory.isEmpty
                ? const Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Text("No sleep records yet."),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.sleepHistory.length,
                    itemBuilder: (_, i) {
                      final e = controller.sleepHistory[i];
                      return Dismissible(
                        key: ValueKey(e.id),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) => controller.deleteSleep(i),
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        child: Card(
                          child: ListTile(
                            title: Text("${e.hours.toStringAsFixed(1)} hours"),
                            subtitle: Text("${e.bedTime.day}/${e.bedTime.month}/${e.bedTime.year}"),
                            trailing: Text("${_formatTime(e.bedTime)} → ${_formatTime(e.wakeTime)}"),
                          ),
                        ),
                      );
                    },
                  ))
          ],
        ),
      ),
    );
  }

  Widget _timeBox(String label, String time, VoidCallback onTap) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white)),
        Text(time, style: const TextStyle(color: Colors.white, fontSize: 18)),
        TextButton(onPressed: onTap, child: const Text("Select", style: TextStyle(color: Colors.white70))),
      ],
    );
  }
}
