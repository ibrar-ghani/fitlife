import 'package:flutter/material.dart';
import 'views/home_page.dart';
import 'package:get/get.dart';

void main() {
  runApp(FitLifeApp());
}

class FitLifeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FitLife',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: HomePage(),
    );
  }
}
