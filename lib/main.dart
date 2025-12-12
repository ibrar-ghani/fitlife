import 'package:fitlife/controllers/auth_controller.dart';
import 'package:fitlife/controllers/motivation_controller.dart';
import 'package:fitlife/controllers/progress_controoler.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'views/home_page.dart';
import 'views/auth/login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Ensure Firebase is only initialized once
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print("✅ Firebase initialized successfully.");
    } else {
      print("ℹ Firebase already initialized.");
    }
  } catch (e) {
    print("❌ Firebase initialization error: $e");
  }

  // Inject controllers AFTER Firebase initialization
  Get.put(AuthController(), permanent: true);
  Get.put(ProgressController(), permanent: true);
  Get.put(MotivationController(), permanent: true);

  runApp(const FitLifeApp());
}

class FitLifeApp extends StatelessWidget {
  const FitLifeApp({super.key});

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