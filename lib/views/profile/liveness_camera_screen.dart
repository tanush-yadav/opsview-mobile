import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:face_anti_spoofing_detector/face_anti_spoofing_detector.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

/// A camera screen that performs real-time liveness detection
/// using the FaceAntiSpoofingDetector SDK with YUV camera frames.
/// 
/// Returns a [LivenessResult] containing the captured image path
/// and the final liveness score if successful, or null if cancelled.
class LivenessCameraScreen extends StatefulWidget {
  const LivenessCameraScreen({super.key});

  @override
  State<LivenessCameraScreen> createState() => _LivenessCameraScreenState();
}

class LivenessResult {
  final String imagePath;
  final double livenessScore;

  LivenessResult({required this.imagePath, required this.livenessScore});
}

class _LivenessCameraScreenState extends State<LivenessCameraScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isProcessing = false;
  bool _isCapturing = false;
  double _currentLivenessScore = 0.0;
  String _statusMessage = 'Initializing camera...';
  bool _livenessCheckPassed = false;
  int _consecutivePassCount = 0;
  static const int _requiredConsecutivePasses = 3;
  static const double _livenessThreshold = 0.5;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      // Initialize the liveness detector
      await FaceAntiSpoofingDetector.initialize();

      // Get available cameras
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        setState(() {
          _statusMessage = 'No cameras available';
        });
        return;
      }

      // Find front camera
      final frontCamera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras!.first,
      );

      // Initialize controller with YUV420 format for liveness detection
      _controller = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await _controller!.initialize();

      if (!mounted) return;

      setState(() {
        _isInitialized = true;
        _statusMessage = 'Position your face in the frame';
      });

      // Start image stream for liveness detection
      await _controller!.startImageStream(_processFrame);
    } catch (e) {
      setState(() {
        _statusMessage = 'Camera error: $e';
      });
    }
  }

  Future<void> _processFrame(CameraImage image) async {
    if (_isProcessing || _isCapturing) return;
    _isProcessing = true;

    try {
      // Convert CameraImage planes to YUV bytes
      final yuvBytes = _convertToYUV(image);

      // Estimate face region (center of frame)
      final faceRect = Rect.fromLTWH(
        image.width * 0.15,
        image.height * 0.1,
        image.width * 0.7,
        image.height * 0.8,
      );

      // Run liveness detection
      final score = await FaceAntiSpoofingDetector.detect(
        yuvBytes: yuvBytes,
        previewWidth: image.width,
        previewHeight: image.height,
        orientation: 0,
        faceContour: faceRect,
      );

      if (!mounted) return;

      setState(() {
        _currentLivenessScore = score ?? 0.0;

        if (_currentLivenessScore >= _livenessThreshold) {
          _consecutivePassCount++;
          if (_consecutivePassCount >= _requiredConsecutivePasses) {
            _livenessCheckPassed = true;
            _statusMessage = 'Liveness verified! Tap to capture';
          } else {
            _statusMessage = 'Verifying... (${_consecutivePassCount}/$_requiredConsecutivePasses)';
          }
        } else {
          _consecutivePassCount = 0;
          _livenessCheckPassed = false;
          _statusMessage = 'Position your face clearly';
        }
      });
    } catch (e) {
      // Ignore individual frame errors
    } finally {
      _isProcessing = false;
    }
  }

  Uint8List _convertToYUV(CameraImage image) {
    // For YUV420 format, we need to combine the planes
    // Plane 0: Y (luminance)
    // Plane 1: U (chrominance)
    // Plane 2: V (chrominance)
    
    final int width = image.width;
    final int height = image.height;
    final int ySize = width * height;
    final int uvSize = (width ~/ 2) * (height ~/ 2);
    
    // Total size for YUV420: Y + U + V
    final Uint8List yuvBytes = Uint8List(ySize + uvSize * 2);
    
    // Copy Y plane
    final yPlane = image.planes[0];
    int yIndex = 0;
    for (int row = 0; row < height; row++) {
      final rowStart = row * yPlane.bytesPerRow;
      for (int col = 0; col < width; col++) {
        yuvBytes[yIndex++] = yPlane.bytes[rowStart + col];
      }
    }

    // Copy U and V planes (interleaved in planes[1] and planes[2])
    if (image.planes.length >= 3) {
      final uPlane = image.planes[1];
      final vPlane = image.planes[2];
      
      int uvIndex = ySize;
      for (int row = 0; row < height ~/ 2; row++) {
        for (int col = 0; col < width ~/ 2; col++) {
          // U plane
          final uRowStart = row * uPlane.bytesPerRow;
          yuvBytes[uvIndex++] = uPlane.bytes[uRowStart + col * uPlane.bytesPerPixel!];
        }
      }
      for (int row = 0; row < height ~/ 2; row++) {
        for (int col = 0; col < width ~/ 2; col++) {
          // V plane
          final vRowStart = row * vPlane.bytesPerRow;
          yuvBytes[uvIndex++] = vPlane.bytes[vRowStart + col * vPlane.bytesPerPixel!];
        }
      }
    }

    return yuvBytes;
  }

  Future<void> _capturePhoto() async {
    if (!_livenessCheckPassed || _isCapturing || _controller == null) return;

    setState(() {
      _isCapturing = true;
      _statusMessage = 'Capturing...';
    });

    try {
      // Stop stream before capture
      await _controller!.stopImageStream();

      // Capture image
      final XFile photo = await _controller!.takePicture();

      // Save to app documents
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final savedPath = '${directory.path}/selfie_$timestamp.jpg';
      await File(photo.path).copy(savedPath);

      // Cleanup
      await FaceAntiSpoofingDetector.destroy();

      if (mounted) {
        Navigator.of(context).pop(LivenessResult(
          imagePath: savedPath,
          livenessScore: _currentLivenessScore,
        ));
      }
    } catch (e) {
      setState(() {
        _isCapturing = false;
        _statusMessage = 'Capture failed. Try again.';
      });
      // Restart stream
      await _controller?.startImageStream(_processFrame);
    }
  }

  @override
  void dispose() {
    _controller?.stopImageStream();
    _controller?.dispose();
    FaceAntiSpoofingDetector.destroy();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Camera preview
            if (_isInitialized && _controller != null)
              Positioned.fill(
                child: AspectRatio(
                  aspectRatio: _controller!.value.aspectRatio,
                  child: CameraPreview(_controller!),
                ),
              )
            else
              const Positioned.fill(
                child: Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),

            // Face frame overlay
            Positioned.fill(
              child: CustomPaint(
                painter: _FaceFramePainter(
                  isLive: _livenessCheckPassed,
                  score: _currentLivenessScore,
                ),
              ),
            ),

            // Top bar with close button
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 28),
                    onPressed: () => Navigator.of(context).pop(null),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'Score: ${(_currentLivenessScore * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        color: _livenessCheckPassed ? Colors.green : Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom status and capture button
            Positioned(
              bottom: 32,
              left: 16,
              right: 16,
              child: Column(
                children: [
                  // Status message
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _statusMessage,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Capture button
                  GestureDetector(
                    onTap: _livenessCheckPassed ? _capturePhoto : null,
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _livenessCheckPassed ? Colors.green : Colors.white38,
                          width: 4,
                        ),
                        color: _livenessCheckPassed ? Colors.green.withOpacity(0.3) : Colors.transparent,
                      ),
                      child: _isCapturing
                          ? const Center(
                              child: CircularProgressIndicator(color: Colors.white),
                            )
                          : Icon(
                              Icons.camera,
                              size: 36,
                              color: _livenessCheckPassed ? Colors.white : Colors.white38,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Paints an oval face frame with color based on liveness status
class _FaceFramePainter extends CustomPainter {
  final bool isLive;
  final double score;

  _FaceFramePainter({required this.isLive, required this.score});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.4);
    final ovalRect = Rect.fromCenter(
      center: center,
      width: size.width * 0.7,
      height: size.height * 0.45,
    );

    final paint = Paint()
      ..color = isLive ? Colors.green : Colors.orange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawOval(ovalRect, paint);

    // Draw corner brackets for visual guidance
    final bracketPaint = Paint()
      ..color = isLive ? Colors.green.withOpacity(0.5) : Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final bracketSize = 30.0;
    final rect = ovalRect.inflate(20);

    // Top-left bracket
    canvas.drawLine(Offset(rect.left, rect.top + bracketSize), Offset(rect.left, rect.top), bracketPaint);
    canvas.drawLine(Offset(rect.left, rect.top), Offset(rect.left + bracketSize, rect.top), bracketPaint);

    // Top-right bracket
    canvas.drawLine(Offset(rect.right - bracketSize, rect.top), Offset(rect.right, rect.top), bracketPaint);
    canvas.drawLine(Offset(rect.right, rect.top), Offset(rect.right, rect.top + bracketSize), bracketPaint);

    // Bottom-left bracket
    canvas.drawLine(Offset(rect.left, rect.bottom - bracketSize), Offset(rect.left, rect.bottom), bracketPaint);
    canvas.drawLine(Offset(rect.left, rect.bottom), Offset(rect.left + bracketSize, rect.bottom), bracketPaint);

    // Bottom-right bracket
    canvas.drawLine(Offset(rect.right - bracketSize, rect.bottom), Offset(rect.right, rect.bottom), bracketPaint);
    canvas.drawLine(Offset(rect.right, rect.bottom), Offset(rect.right, rect.bottom - bracketSize), bracketPaint);
  }

  @override
  bool shouldRepaint(covariant _FaceFramePainter oldDelegate) {
    return oldDelegate.isLive != isLive || oldDelegate.score != score;
  }
}
