import 'package:fitlife/controllers/motivation_controller.dart';
import 'package:fitlife/controllers/progress_controoler.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'views/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize controller before app runs (for SharedPreferences data)
  Get.put(ProgressController());
  Get.put(MotivationController());

  runApp(FitLifeApp());
}

class FitLifeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FitLife',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
        useMaterial3: true,
      ),
      home: HomePage(),
    );
  }
}
