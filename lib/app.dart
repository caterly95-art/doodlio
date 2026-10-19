import 'package:flutter/material.dart';
import 'core/constants/app_theme.dart';
import 'screens/splash/splash_screen.dart';

class DoodlioApp extends StatelessWidget {
  const DoodlioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Doodlio',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}

