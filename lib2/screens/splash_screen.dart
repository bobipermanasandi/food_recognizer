import 'dart:async';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import '../services/tflite_service.dart';
import '../utils/model_diagnostic_util.dart';
import '../utils/env_validator.dart';
import 'dart:developer';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  final TfliteService _tfliteService = TfliteService();
  bool _modelLoaded = false;
  bool _timerComplete = false;
  String _loadingStatus = 'Initializing...';

  @override
  void initState() {
    super.initState();

    // Buat animasi untuk logo
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    // Validasi environment variables
    WidgetsBinding.instance.addPostFrameCallback((_) {
      EnvValidator.validateEnv(context);
    });

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _animationController.forward();

    // Load TFLite model di background
    _loadModel();

    // Pastikan splash screen muncul minimal 2.5 detik
    Timer(const Duration(milliseconds: 2500), () {
      if (!mounted) return;
      setState(() {
        _timerComplete = true;
        _checkNavigate();
      });
    });
  }

  Future<void> _loadModel() async {
    try {
      if (!mounted) return;
      setState(() {
        _loadingStatus = 'Mempersiapkan model AI...';
      });

      // Run diagnostic before attempting to load model
      try {
        final diagnostics = await ModelDiagnosticUtil.runDiagnostics();
        log(diagnostics);
      } catch (e) {
        log('Error running diagnostics: $e');
      }

      // Add timeout to prevent hanging indefinitely
      bool success = await _tfliteService.loadModel().timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          log('Timeout saat memuat model TFLite');
          return false;
        },
      );

      if (!mounted) return;
      setState(() {
        if (success) {
          _loadingStatus = 'Model berhasil dimuat!';
        } else {
          _loadingStatus =
              'Gagal memuat model. Pastikan koneksi internet stabil dan file model tersedia.';
        }
        _modelLoaded = success;

        if (!success) {
          // Even if model failed to load, we should proceed after a delay
          log('Model gagal dimuat, tapi aplikasi akan tetap dilanjutkan');

          // Show a message that we're continuing anyway
          Future.delayed(const Duration(seconds: 1), () {
            if (!mounted) return;
            setState(() {
              _loadingStatus = 'Melanjutkan tanpa model...';
            });

            // Run diagnostic again to determine the cause of failure
            ModelDiagnosticUtil.runDiagnostics().then((diagnostics) {
              log('Post-failure diagnostics:\n$diagnostics');
              // Tampilkan hasil diagnosa ke user
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Diagnosa: $diagnostics'),
                  duration: const Duration(seconds: 5),
                ),
              );
            });

            Future.delayed(const Duration(seconds: 2), () {
              if (!mounted) return;
              setState(() {
                _modelLoaded = true;
                _checkNavigate();
              });
            });
          });
        } else {
          _checkNavigate();
        }
      });
    } catch (e) {
      log('Error saat memuat model: $e');
      if (!mounted) return;
      setState(() {
        _loadingStatus = 'Error: $e';
      });

      // Run diagnostic to determine the cause of the error
      ModelDiagnosticUtil.runDiagnostics().then((diagnostics) {
        log('Error diagnostics:\n$diagnostics');
      });

      // Proceed anyway after error
      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
        setState(() {
          _loadingStatus = 'Melanjutkan tanpa model...';
          _modelLoaded = true; // Force proceed
          _checkNavigate();
        });
      });
    }
  }

  void _checkNavigate() {
    if (_modelLoaded && _timerComplete) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[300]!, Colors.blue[700]!],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _animation,
              child: Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.restaurant_menu,
                    size: 80,
                    color: Colors.blue[700],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            FadeTransition(
              opacity: _animation,
              child: const Text(
                'AI Food Recognizer',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            const SizedBox(height: 20),
            Text(
              _loadingStatus,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
