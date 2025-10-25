import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'utils/env_validator.dart';
import 'dart:developer';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Pastikan binding diinisialisasi

  // Load .env file
  try {
    await dotenv.load(fileName: ".env");
    // Log environment status in debug mode (masked for security)
    assert(() {
      EnvValidator.logEnvStatus();
      return true;
    }());
  } catch (e) {
    log('ERROR: Failed to load .env file: $e');
    // Continue execution - EnvValidator will show warning dialogs later
  }

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Recognizer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true, // Gunakan Material Design 3
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue[700],
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false, // Hapus banner debug
    );
  }
}
