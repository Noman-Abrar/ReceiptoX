import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'receipt_preview_screen.dart';

class CameraScreen extends StatefulWidget {
  final CameraDescription camera;

  const CameraScreen({super.key, required this.camera});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  FlashMode _flashMode = FlashMode.off;

  @override
  void initState() {
    super.initState();

    _controller = CameraController(
      widget.camera,
      ResolutionPreset.high,
      enableAudio: false,
    );

    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // 🔦 Flash toggle
  Future<void> _toggleFlash() async {
    if (!_controller.value.isInitialized) return;

    FlashMode newMode;
    if (_flashMode == FlashMode.off) {
      newMode = FlashMode.always;
    } else if (_flashMode == FlashMode.always) {
      newMode = FlashMode.auto;
    } else {
      newMode = FlashMode.off;
    }

    await _controller.setFlashMode(newMode);
    setState(() => _flashMode = newMode);
  }

  IconData _flashIcon() {
    switch (_flashMode) {
      case FlashMode.always:
        return Icons.flash_on;
      case FlashMode.auto:
        return Icons.flash_auto;
      default:
        return Icons.flash_off;
    }
  }

  // 📸 Capture Image
  Future<void> _captureImage() async {
    try {
      await _initializeControllerFuture;

      final image = await _controller.takePicture();

      if (!mounted) return;

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ReceiptPreviewScreen(imagePath: image.path),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Camera error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Scan Receipt',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(_flashIcon()),
            onPressed: _toggleFlash,
          ),
        ],
      ),
      body: FutureBuilder(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                CameraPreview(_controller),

                // 🎯 Capture Button
                Positioned(
                  bottom: 35,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: FloatingActionButton(
                      backgroundColor: Colors.blueAccent,
                      onPressed: _captureImage,
                      child: const Icon(Icons.camera_alt, size: 30),
                    ),
                  ),
                ),
              ],
            );
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
