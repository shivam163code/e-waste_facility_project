import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/splash_screen.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Conditionally initialize Firebase if config is present
  // For now, we wrap in try-catch to allow app to run even if not configured
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase initialization failed (likely missing config): $e');
  }

  runApp(const EWasteLocatorApp());
}

class EWasteLocatorApp extends StatelessWidget {
  const EWasteLocatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-Waste Facility Locator',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
