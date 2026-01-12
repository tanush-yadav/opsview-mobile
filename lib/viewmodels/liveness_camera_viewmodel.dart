import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:face_anti_spoofing_detector/face_anti_spoofing_detector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

// State class
class LivenessCameraState {

  const LivenessCameraState({
    this.isInitialized = false,
    this.isProcessing = false,
    this.isCapturing = false,
    this.livenessScore = 0.0,
    this.statusMessage = 'Initializing camera...',
    this.livenessCheckPassed = false,
    this.consecutivePassCount = 0,
    this.capturedImagePath,
    this.errorMessage,
  });
  final bool isInitialized;
  final bool isProcessing;
  final bool isCapturing;
  final double livenessScore;
  final String statusMessage;
  final bool livenessCheckPassed;
  final int consecutivePassCount;
  final String? capturedImagePath;
  final String? errorMessage;

  LivenessCameraState copyWith({
    bool? isInitialized,
    bool? isProcessing,
    bool? isCapturing,
    double? livenessScore,
    String? statusMessage,
    bool? livenessCheckPassed,
    int? consecutivePassCount,
    String? capturedImagePath,
    String? errorMessage,
  }) {
    return LivenessCameraState(
      isInitialized: isInitialized ?? this.isInitialized,
      isProcessing: isProcessing ?? this.isProcessing,
      isCapturing: isCapturing ?? this.isCapturing,
      livenessScore: livenessScore ?? this.livenessScore,
      statusMessage: statusMessage ?? this.statusMessage,
      livenessCheckPassed: livenessCheckPassed ?? this.livenessCheckPassed,
      consecutivePassCount: consecutivePassCount ?? this.consecutivePassCount,
      capturedImagePath: capturedImagePath ?? this.capturedImagePath,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// ViewModel
class LivenessCameraViewModel extends Notifier<LivenessCameraState> {
  static const int _requiredConsecutivePasses = 3;
  static const double _livenessThreshold = 0.5;

  CameraController? _controller;
  CameraImage? _latestFrame;
  int _frameWidth = 0;
  int _frameHeight = 0;

  CameraController? get controller => _controller;

  @override
  LivenessCameraState build() {
    // Register cleanup when provider is disposed
    ref.onDispose(() {
      try {
        _controller?.stopImageStream();
      } catch (_) {}
      _controller?.dispose();
      FaceAntiSpoofingDetector.destroy();
    });
    return const LivenessCameraState();
  }

  Future<void> initialize() async {
    try {
      await FaceAntiSpoofingDetector.initialize();

      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        state = state.copyWith(
          errorMessage: 'No cameras available',
          statusMessage: 'No cameras available',
        );
        return;
      }

      final frontCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _controller = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await _controller!.initialize();

      state = state.copyWith(
        isInitialized: true,
        statusMessage: 'Position your face in the frame',
      );

      await _controller!.startImageStream(_processFrame);
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Camera error: $e',
        statusMessage: 'Camera error',
      );
    }
  }

  Future<void> _processFrame(CameraImage image) async {
    _latestFrame = image;
    _frameWidth = image.width;
    _frameHeight = image.height;

    if (state.isProcessing || state.isCapturing) return;
    state = state.copyWith(isProcessing: true);

    try {
      final yuvBytes = _convertToYUV(image);

      final faceRect = Rect.fromLTWH(
        image.width * 0.15,
        image.height * 0.1,
        image.width * 0.7,
        image.height * 0.8,
      );

      final score = await FaceAntiSpoofingDetector.detect(
        yuvBytes: yuvBytes,
        previewWidth: image.width,
        previewHeight: image.height,
        orientation: 0,
        faceContour: faceRect,
      );

      // Check if still mounted after async operation
      if (!ref.mounted) return;

      final newScore = score ?? 0.0;
      int newPassCount = state.consecutivePassCount;
      bool passed = state.livenessCheckPassed;
      String message = state.statusMessage;

      if (newScore >= _livenessThreshold) {
        newPassCount++;
        if (newPassCount >= _requiredConsecutivePasses) {
          passed = true;
          message = 'Liveness verified! Tap to capture.';
        } else {
          message = 'Verifying... ($newPassCount/$_requiredConsecutivePasses)';
        }
      } else {
        newPassCount = 0;
        passed = false;
        message = 'Position your face in the frame';
      }

      state = state.copyWith(
        livenessScore: newScore,
        consecutivePassCount: newPassCount,
        livenessCheckPassed: passed,
        statusMessage: message,
        isProcessing: false,
      );
    } catch (e) {
      if (ref.mounted) {
        state = state.copyWith(isProcessing: false);
      }
    }
  }

  Uint8List _convertToYUV(CameraImage image) {
    final int width = image.width;
    final int height = image.height;
    final int ySize = width * height;
    final int uvSize = (width ~/ 2) * (height ~/ 2);

    final Uint8List yuvBytes = Uint8List(ySize + uvSize * 2);

    final yPlane = image.planes[0];
    int yIndex = 0;
    for (int row = 0; row < height; row++) {
      final rowStart = row * yPlane.bytesPerRow;
      for (int col = 0; col < width; col++) {
        yuvBytes[yIndex++] = yPlane.bytes[rowStart + col];
      }
    }

    if (image.planes.length >= 3) {
      final uPlane = image.planes[1];
      final vPlane = image.planes[2];

      int uvIndex = ySize;
      for (int row = 0; row < height ~/ 2; row++) {
        for (int col = 0; col < width ~/ 2; col++) {
          final uRowStart = row * uPlane.bytesPerRow;
          yuvBytes[uvIndex++] =
              uPlane.bytes[uRowStart + col * uPlane.bytesPerPixel!];
        }
      }
      for (int row = 0; row < height ~/ 2; row++) {
        for (int col = 0; col < width ~/ 2; col++) {
          final vRowStart = row * vPlane.bytesPerRow;
          yuvBytes[uvIndex++] =
              vPlane.bytes[vRowStart + col * vPlane.bytesPerPixel!];
        }
      }
    }

    return yuvBytes;
  }

  Uint8List _convertYUVToRGB(CameraImage image) {
    final int width = image.width;
    final int height = image.height;
    final yPlane = image.planes[0];
    final uPlane = image.planes[1];
    final vPlane = image.planes[2];

    final Uint8List rgb = Uint8List(width * height * 3);

    int rgbIndex = 0;
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final yIndex = y * yPlane.bytesPerRow + x;
        final uvIndex =
            (y ~/ 2) * uPlane.bytesPerRow + (x ~/ 2) * uPlane.bytesPerPixel!;

        final yValue = yPlane.bytes[yIndex];
        final uValue = uPlane.bytes[uvIndex];
        final vValue = vPlane.bytes[uvIndex];

        final int r = (yValue + 1.370705 * (vValue - 128)).round().clamp(0, 255);
        final int g = (yValue - 0.337633 * (uValue - 128) - 0.698001 * (vValue - 128))
            .round()
            .clamp(0, 255);
        final int b = (yValue + 1.732446 * (uValue - 128)).round().clamp(0, 255);

        rgb[rgbIndex++] = r;
        rgb[rgbIndex++] = g;
        rgb[rgbIndex++] = b;
      }
    }

    return rgb;
  }

  Future<void> capturePhoto() async {
    if (!state.livenessCheckPassed ||
        state.isCapturing ||
        _latestFrame == null) {
      return;
    }

    state = state.copyWith(isCapturing: true, statusMessage: 'Capturing...');

    try {
      final frame = _latestFrame!;
      final width = _frameWidth;
      final height = _frameHeight;

      // Create an image from the YUV data
      final rgbBytes = _convertYUVToRGB(frame);

      // Create image using the image package
      var image = img.Image(width: width, height: height);
      int rgbIndex = 0;
      for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
          final r = rgbBytes[rgbIndex++];
          final g = rgbBytes[rgbIndex++];
          final b = rgbBytes[rgbIndex++];
          image.setPixelRgb(x, y, r, g, b);
        }
      }

      // Fix front camera orientation:
      // 1. Rotate 90° anti-clockwise (for portrait mode on Android)
      image = img.copyRotate(image, angle: 270);

      // Encode to JPEG
      final jpegBytes = img.encodeJpg(image, quality: 90);

      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final savedPath = '${directory.path}/selfie_$timestamp.jpg';

      await File(savedPath).writeAsBytes(jpegBytes);

      state = state.copyWith(capturedImagePath: savedPath, isCapturing: false);
    } catch (e) {
      state = state.copyWith(
        isCapturing: false,
        statusMessage: 'Capture failed: $e',
      );
    }
  }
}

// Provider
final livenessCameraViewModelProvider =
    NotifierProvider.autoDispose<LivenessCameraViewModel, LivenessCameraState>(
      LivenessCameraViewModel.new,
    );
