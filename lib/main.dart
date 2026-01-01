import 'package:fitlife/controllers/goal_controller.dart';
import 'package:fitlife/controllers/progress_controoler.dart';
import 'package:fitlife/controllers/water_controller.dart';
import 'package:fitlife/controllers/steps_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'controllers/auth_controller.dart';
import 'views/auth/login_page.dart';
import 'views/home_page.dart';
import 'theme/app_theme.dart'; // ✅ GLOBAL THEME

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ SAFE Firebase init
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    print("Firebase already initialized: $e");
  }

  // ✅ Initialize controllers only after Firebase
  Get.put(AuthController(), permanent: true);
  Get.put(GoalController(), permanent: true);
  Get.put(WaterController(), permanent: true);
  Get.put(StepsController(), permanent: true);
  Get.put(ProgressController(), permanent: true);

  // ✅ Inject AuthController ONCE
  Get.put<AuthController>(AuthController(), permanent: true);

  runApp(const FitLifeApp());
}

class FitLifeApp extends StatelessWidget {
  const FitLifeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FitLife',

      // 🎨 APPLY FITLIFE THEME
      theme: AppTheme.lightTheme,

      home: const HomeOrLogin(),
    );
  }
}

class HomeOrLogin extends StatelessWidget {
  const HomeOrLogin({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController auth = Get.find<AuthController>();

    return Obx(() {
      return auth.user == null
          ? LoginPage()
          : HomePage();
    });
  }
}
