import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../viewmodels/liveness_camera_viewmodel.dart';

class LivenessCameraScreen extends ConsumerStatefulWidget {
  const LivenessCameraScreen({super.key});

  @override
  ConsumerState<LivenessCameraScreen> createState() =>
      _LivenessCameraScreenState();
}

class LivenessResult {
  LivenessResult({required this.imagePath, required this.livenessScore});
  final String imagePath;
  final double livenessScore;
}

class _LivenessCameraScreenState extends ConsumerState<LivenessCameraScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(livenessCameraViewModelProvider.notifier).initialize();
    });
  }

  // No dispose needed - provider auto-disposes with ref.onDispose

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(livenessCameraViewModelProvider);
    final viewModel = ref.read(livenessCameraViewModelProvider.notifier);

    // Listen for capture completion and navigate (fires once per state change)
    ref.listen<LivenessCameraState>(livenessCameraViewModelProvider, (
      previous,
      next,
    ) {
      if (previous?.capturedImagePath == null &&
          next.capturedImagePath != null) {
        Navigator.of(context).pop(
          LivenessResult(
            imagePath: next.capturedImagePath!,
            livenessScore: next.livenessScore,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Camera preview
            if (state.isInitialized && viewModel.controller != null)
              Positioned.fill(
                child: AspectRatio(
                  aspectRatio: viewModel.controller!.value.aspectRatio,
                  child: CameraPreview(viewModel.controller!),
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
                  isLive: state.livenessCheckPassed,
                  score: state.livenessScore,
                ),
              ),
            ),

            // Top bar
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: () {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop(null);
                      }
                    },
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'Score: ${(state.livenessScore * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        color: state.livenessCheckPassed
                            ? Colors.green
                            : Colors.orange,
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      state.statusMessage,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: state.livenessCheckPassed
                        ? viewModel.capturePhoto
                        : null,
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: state.livenessCheckPassed
                              ? Colors.green
                              : Colors.white38,
                          width: 4,
                        ),
                        color: state.livenessCheckPassed
                            ? Colors.green.withValues(alpha: 0.3)
                            : Colors.transparent,
                      ),
                      child: state.isCapturing
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          : Icon(
                              Icons.camera,
                              size: 36,
                              color: state.livenessCheckPassed
                                  ? Colors.white
                                  : Colors.white38,
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

class _FaceFramePainter extends CustomPainter {
  _FaceFramePainter({required this.isLive, required this.score});
  final bool isLive;
  final double score;

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

    final bracketPaint = Paint()
      ..color = isLive
          ? Colors.green.withValues(alpha: 0.5)
          : Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    const bracketSize = 30.0;
    final rect = ovalRect.inflate(20);

    // Top-left
    canvas.drawLine(
      Offset(rect.left, rect.top + bracketSize),
      Offset(rect.left, rect.top),
      bracketPaint,
    );
    canvas.drawLine(
      Offset(rect.left, rect.top),
      Offset(rect.left + bracketSize, rect.top),
      bracketPaint,
    );
    // Top-right
    canvas.drawLine(
      Offset(rect.right - bracketSize, rect.top),
      Offset(rect.right, rect.top),
      bracketPaint,
    );
    canvas.drawLine(
      Offset(rect.right, rect.top),
      Offset(rect.right, rect.top + bracketSize),
      bracketPaint,
    );
    // Bottom-left
    canvas.drawLine(
      Offset(rect.left, rect.bottom - bracketSize),
      Offset(rect.left, rect.bottom),
      bracketPaint,
    );
    canvas.drawLine(
      Offset(rect.left, rect.bottom),
      Offset(rect.left + bracketSize, rect.bottom),
      bracketPaint,
    );
    // Bottom-right
    canvas.drawLine(
      Offset(rect.right - bracketSize, rect.bottom),
      Offset(rect.right, rect.bottom),
      bracketPaint,
    );
    canvas.drawLine(
      Offset(rect.right, rect.bottom),
      Offset(rect.right, rect.bottom - bracketSize),
      bracketPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _FaceFramePainter oldDelegate) {
    return oldDelegate.isLive != isLive || oldDelegate.score != score;
  }
}
