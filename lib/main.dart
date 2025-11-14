import 'package:fitlife/controllers/motivation_controller.dart';
import 'package:fitlife/controllers/progress_controoler.dart';
import 'package:fitlife/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'views/home_page.dart';
import 'views/auth/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

 await Firebase.initializeApp();


  Get.put(ProgressController());
  Get.put(MotivationController());
  Get.put(AuthController());

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

        // If NOT logged in → show login
        if (auth.user == null) {
          return LoginPage();
        }

        // If logged in → home
        return HomePage();
      }),
    );
  }
}
