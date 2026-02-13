import 'dart:io';

import 'package:camera/camera.dart';
import 'package:face_anti_spoofing_detector/face_anti_spoofing_detector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

import '../core/utils/camera_image_utils.dart';

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
      consecutivePassCount:
          consecutivePassCount ?? this.consecutivePassCount,
      capturedImagePath: capturedImagePath ?? this.capturedImagePath,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// ViewModel
class LivenessCameraViewModel extends Notifier<LivenessCameraState> {
  static const int _requiredConsecutivePasses = 3;
  static const double _livenessThreshold = 0.5;
  static const double _minBrightnessVariance = 500.0;
  static const int _frameSkipInterval = 2;

  CameraController? _controller;
  CameraImage? _latestFrame;
  int _frameWidth = 0;
  int _frameHeight = 0;
  late final FaceDetector _faceDetector;
  CameraDescription? _cameraDescription;
  int _frameSkipCount = 0;

  CameraController? get controller => _controller;

  @override
  LivenessCameraState build() {
    ref.onDispose(() {
      try {
        _controller?.stopImageStream();
      } catch (_) {}
      _controller?.dispose();
      _faceDetector.close();
      FaceAntiSpoofingDetector.destroy();
    });
    return const LivenessCameraState();
  }

  Future<void> initialize() async {
    try {
      _faceDetector = FaceDetector(
        options: FaceDetectorOptions(
          enableClassification: false,
          enableLandmarks: false,
          enableContours: false,
          enableTracking: false,
          performanceMode: FaceDetectorMode.fast,
          minFaceSize: 0.25,
        ),
      );

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
      _cameraDescription = frontCamera;

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

    _frameSkipCount++;
    if (_frameSkipCount % (_frameSkipInterval + 1) != 0) return;

    state = state.copyWith(isProcessing: true);

    try {
      // Step 1: Reject blank/covered camera
      final variance = CameraImageUtils.calculateBrightnessVariance(
        image.planes[0].bytes,
        image.width,
        image.height,
      );
      if (variance < _minBrightnessVariance) {
        if (ref.mounted) {
          state = state.copyWith(
            livenessScore: 0.0,
            consecutivePassCount: 0,
            livenessCheckPassed: false,
            statusMessage: 'Please uncover the camera',
            isProcessing: false,
          );
        }
        return;
      }

      // Step 2: ML Kit face detection
      final inputImage = CameraImageUtils.buildInputImage(
        image,
        _cameraDescription,
      );
      final faces = await _faceDetector.processImage(inputImage);
      if (!ref.mounted) return;

      if (faces.isEmpty) {
        state = state.copyWith(
          livenessScore: 0.0,
          consecutivePassCount: 0,
          livenessCheckPassed: false,
          statusMessage: 'Position your face in the frame',
          isProcessing: false,
        );
        return;
      }

      // Step 3: Get real face bounding box (largest face)
      final detectedFace = faces.reduce(
        (a, b) => a.boundingBox.width * a.boundingBox.height >
                b.boundingBox.width * b.boundingBox.height
            ? a
            : b,
      );
      final mlKitRect = detectedFace.boundingBox;
      final faceRect = Rect.fromLTRB(
        mlKitRect.left.clamp(0, image.width.toDouble()),
        mlKitRect.top.clamp(0, image.height.toDouble()),
        mlKitRect.right.clamp(0, image.width.toDouble()),
        mlKitRect.bottom.clamp(0, image.height.toDouble()),
      );

      // Step 4: Anti-spoofing with real face rect
      final yuvBytes = CameraImageUtils.convertToYUV(image);
      final score = await FaceAntiSpoofingDetector.detect(
        yuvBytes: yuvBytes,
        previewWidth: image.width,
        previewHeight: image.height,
        orientation: 0,
        faceContour: faceRect,
      );
      if (!ref.mounted) return;

      // Step 5: Evaluate score
      _evaluateScore(score ?? 0.0);
    } catch (e) {
      if (ref.mounted) {
        state = state.copyWith(isProcessing: false);
      }
    }
  }

  void _evaluateScore(double score) {
    int passCount = state.consecutivePassCount;
    bool passed = state.livenessCheckPassed;
    String message;

    if (score >= _livenessThreshold) {
      passCount++;
      if (passCount >= _requiredConsecutivePasses) {
        passed = true;
        message = 'Liveness verified! Tap to capture.';
      } else {
        message = 'Verifying... ($passCount/$_requiredConsecutivePasses)';
      }
    } else {
      passCount = 0;
      passed = false;
      message = 'Hold steady, verifying face...';
    }

    state = state.copyWith(
      livenessScore: score,
      consecutivePassCount: passCount,
      livenessCheckPassed: passed,
      statusMessage: message,
      isProcessing: false,
    );
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
      final rgbBytes = CameraImageUtils.convertYUVToRGB(frame);

      var image = img.Image(width: _frameWidth, height: _frameHeight);
      int rgbIndex = 0;
      for (int y = 0; y < _frameHeight; y++) {
        for (int x = 0; x < _frameWidth; x++) {
          image.setPixelRgb(
            x,
            y,
            rgbBytes[rgbIndex++],
            rgbBytes[rgbIndex++],
            rgbBytes[rgbIndex++],
          );
        }
      }

      // Fix front camera orientation (portrait mode on Android)
      image = img.copyRotate(image, angle: 270);

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
