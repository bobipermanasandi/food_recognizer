import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../services/camera_service.dart';
import '../services/tflite_service.dart';
import 'result_screen.dart';
import 'dart:developer';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final CameraService _cameraService = CameraService();
  final TfliteService _tfliteService = TfliteService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      await _cameraService.initializeCamera();
      await _tfliteService.loadModel();
    } catch (e) {
      log('Error initializing services: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menginisialisasi kamera: $e')),
      );
    }

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _takePictureAndPredict() async {
    if (_isLoading) return;

    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      // Ambil gambar dari kamera
      final File? imageFile = await _cameraService.takePicture();

      if (imageFile == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Gagal mengambil gambar')));
        return;
      }

      // Tampilkan image cropper
      if (!mounted) return;
      final File? croppedFile = await _cameraService.cropImage(
        imageFile,
        context,
      );

      // Jika user membatalkan crop atau gagal
      if (croppedFile == null) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pemotongan gambar dibatalkan atau gagal'),
          ),
        );
        return;
      }

      // Lakukan prediksi dengan gambar yang sudah di-crop
      final PredictionResult predictionResult = await _tfliteService
          .predictImage(croppedFile);

      if (predictionResult.status == PredictionStatus.success &&
          predictionResult.prediction != null) {
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              imageFile: croppedFile,
              prediction: predictionResult.prediction!,
            ),
          ),
        );
      } else {
        if (!mounted) return;
        final errorMsg =
            predictionResult.errorMessage ??
            'Gagal mendapatkan prediksi makanan';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMsg)));
      }
    } catch (e) {
      log('Error during capture and prediction: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _cameraService.dispose();
    _tfliteService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kamera'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Menginisialisasi kamera...'),
                ],
              ),
            )
          : !_cameraService.isInitialized
          ? const Center(
              child: Text(
                'Gagal menginisialisasi kamera',
                style: TextStyle(fontSize: 16),
              ),
            )
          : Stack(
              children: [
                // Camera Preview
                Positioned.fill(
                  child: CameraPreview(_cameraService.controller!),
                ),

                // Overlay UI
                Positioned(
                  bottom: 50,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Back button
                      FloatingActionButton(
                        heroTag: "back",
                        onPressed: () => Navigator.pop(context),
                        backgroundColor: Colors.grey.withValues(alpha: .8),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                      ),

                      // Capture button
                      FloatingActionButton(
                        heroTag: "capture",
                        onPressed: _isLoading ? null : _takePictureAndPredict,
                        backgroundColor: Colors.blue,
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 30,
                              ),
                      ),

                      // Placeholder for symmetry
                      const SizedBox(width: 56),
                    ],
                  ),
                ),

                // Center focus indicator
                const Center(
                  child: Icon(
                    Icons.center_focus_weak,
                    size: 100,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
    );
  }
}
