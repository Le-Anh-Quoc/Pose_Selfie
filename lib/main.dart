import 'package:flutter/material.dart';
import 'package:pose_selfie_app/src/features/home/ui/home/home_binding.dart';
import 'package:pose_selfie_app/src/features/splash/splash_screen.dart';
import 'package:get/get.dart';

Future<void> main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Pose Selfie',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Comfortaa',
      ),
      home: const SplashScreen(),
      initialBinding: HomeBinding(),
    );
  }
}