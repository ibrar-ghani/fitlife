import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade100,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Hello Ibrar 👋",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              "Here’s your health summary for today.",
              style: TextStyle(color: Colors.black54),
            ),

            const SizedBox(height: 20),

            // Firebase status (placeholder – will wire later)
            Row(
              children: const [
                Icon(Icons.cloud_done, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  "Firebase Connected",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.green),
                ),
              ],
            ),

            const SizedBox(height: 20),

            GridView(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
              ),
              children: [
                _statCard(Icons.nightlight_round, "Sleep", "-- hrs", Colors.indigo),
                _statCard(Icons.local_drink, "Water", "-- ml", Colors.blue),
                _statCard(Icons.directions_walk, "Steps", "--", Colors.green),
                _statCard(Icons.lightbulb, "Motivation", "Tap to View", Colors.orange),
              ],
            ),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                "Your daily motivational quote will appear here!",
                style: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Colors.orange.shade900,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _statCard(
      IconData icon, String title, String value, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(fontSize: 16, color: Colors.black87)),
        ],
      ),
    );
  }
}
