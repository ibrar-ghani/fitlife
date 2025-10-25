import 'package:flutter/material.dart';

class MotivationPage extends StatelessWidget {
  final List<String> quotes = [
    "Push yourself, because no one else is going to do it for you.",
    "It always seems impossible until it’s done.",
    "Don’t limit your challenges — challenge your limits.",
    "You don’t have to be extreme, just consistent.",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: quotes.length,
        itemBuilder: (context, index) {
          return Card(
            color: Colors.purple.shade50,
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: ListTile(
              leading: const Icon(Icons.favorite, color: Colors.purple),
              title: Text(
                quotes[index],
                style: const TextStyle(fontSize: 16),
              ),
            ),
          );
        },
      ),
    );
  }
}
