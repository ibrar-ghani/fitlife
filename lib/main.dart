import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'controllers/auth_controller.dart';
import 'views/auth/login_page.dart';
import 'views/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase safely
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  // Initialize AuthController once
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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
        useMaterial3: true,
      ),
      home: HomeOrLogin(),
    );
  }
}

class HomeOrLogin extends StatelessWidget {
  HomeOrLogin({super.key});

  final AuthController auth = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return auth.user == null ? LoginPage() : HomePage();
    });
  }
}
