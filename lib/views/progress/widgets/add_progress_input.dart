// lib/views/progress/widgets/add_progress_input.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import '../../../controllers/badge_controller.dart';

class AddProgressInput extends StatefulWidget {
  const AddProgressInput({Key? key}) : super(key: key);

  @override
  State<AddProgressInput> createState() => _AddProgressInputState();
}

class _AddProgressInputState extends State<AddProgressInput> {
  final TextEditingController input = TextEditingController();
  List<double> data = [];
  final BadgeController badge = Get.find();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('progressData') ?? [];
    setState(() => data = saved.map((e) => double.parse(e)).toList());
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('progressData', data.map((e) => e.toString()).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: TextField(
          controller: input,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(border: OutlineInputBorder(), labelText: "Today's Run (km)"),
        )),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: () async {
            final v = double.tryParse(input.text);
            if (v != null) {
              data.add(v);
              await _save();
              badge.registerDailyActivity(DateTime.now());
              input.clear();
              setState(() {});
            }
          },
          child: const Text("Add"),
        )
      ],
    );
  }
}
