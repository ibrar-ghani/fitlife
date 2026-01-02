import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'controllers/auth_controller.dart';
import 'controllers/goal_controller.dart';
import 'controllers/water_controller.dart';
import 'controllers/steps_controller.dart';
import 'controllers/progress_controoler.dart';

import 'views/auth/login_page.dart';
import 'views/home_page.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ INITIALIZE FIREBASE FIRST (NO TRY/CATCH)
  if (Firebase.apps.isEmpty) {
  await Firebase.initializeApp();
}

  // ✅ NOW inject controllers (ONCE)
  Get.put<AuthController>(AuthController(), permanent: true);
  Get.put<GoalController>(GoalController(), permanent: true);
  Get.put<WaterController>(WaterController(), permanent: true);
  Get.put<StepsController>(StepsController(), permanent: true);
  Get.put<ProgressController>(ProgressController(), permanent: true);

  runApp(const FitLifeApp());
}

class FitLifeApp extends StatelessWidget {
  const FitLifeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FitLife',
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
      return auth.user == null ? LoginPage() : HomePage();
    });
  }
}
