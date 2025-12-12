import 'package:fitlife/controllers/auth_controller.dart';
import 'package:fitlife/controllers/motivation_controller.dart';
import 'package:fitlife/controllers/progress_controoler.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'views/home_page.dart';
import 'views/auth/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase ONLY ONCE
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Inject controllers after Firebase is ready
  Get.put(AuthController());
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
      home: Obx(() {
        final auth = Get.find<AuthController>();
        return auth.user == null ? LoginPage() : HomePage();
      }),
    );
  }
}