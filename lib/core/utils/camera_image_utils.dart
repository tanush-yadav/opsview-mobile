import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class CameraImageUtils {
  CameraImageUtils._();

  /// Convert CameraImage (YUV_420_888) to NV21 byte array for ML Kit.
  static Uint8List convertToNV21(CameraImage image) {
    final int width = image.width;
    final int height = image.height;
    final yPlane = image.planes[0];
    final uPlane = image.planes[1];
    final vPlane = image.planes[2];

    final int ySize = width * height;
    final int uvSize = (width ~/ 2) * (height ~/ 2) * 2;
    final nv21 = Uint8List(ySize + uvSize);

    int yIndex = 0;
    for (int row = 0; row < height; row++) {
      final rowStart = row * yPlane.bytesPerRow;
      for (int col = 0; col < width; col++) {
        nv21[yIndex++] = yPlane.bytes[rowStart + col];
      }
    }

    int uvIndex = ySize;
    for (int row = 0; row < height ~/ 2; row++) {
      for (int col = 0; col < width ~/ 2; col++) {
        final vIdx = row * vPlane.bytesPerRow + col * vPlane.bytesPerPixel!;
        final uIdx = row * uPlane.bytesPerRow + col * uPlane.bytesPerPixel!;
        nv21[uvIndex++] = vPlane.bytes[vIdx];
        nv21[uvIndex++] = uPlane.bytes[uIdx];
      }
    }

    return nv21;
  }

  /// Convert CameraImage to packed YUV bytes for FaceAntiSpoofingDetector.
  static Uint8List convertToYUV(CameraImage image) {
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

  /// Convert CameraImage YUV data to RGB bytes for JPEG encoding.
  static Uint8List convertYUVToRGB(CameraImage image) {
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

        final int r =
            (yValue + 1.370705 * (vValue - 128)).round().clamp(0, 255);
        final int g =
            (yValue - 0.337633 * (uValue - 128) - 0.698001 * (vValue - 128))
                .round()
                .clamp(0, 255);
        final int b =
            (yValue + 1.732446 * (uValue - 128)).round().clamp(0, 255);

        rgb[rgbIndex++] = r;
        rgb[rgbIndex++] = g;
        rgb[rgbIndex++] = b;
      }
    }

    return rgb;
  }

  /// Calculate brightness variance of Y channel to detect blank/covered images.
  /// Returns low values (< 500) for blank/dark/covered camera.
  static double calculateBrightnessVariance(
    Uint8List yBytes,
    int width,
    int height,
  ) {
    const sampleStep = 10;
    int sum = 0;
    int count = 0;

    for (int i = 0; i < yBytes.length; i += sampleStep) {
      sum += yBytes[i];
      count++;
    }

    if (count == 0) return 0;
    final mean = sum / count;

    double varianceSum = 0;
    for (int i = 0; i < yBytes.length; i += sampleStep) {
      final diff = yBytes[i] - mean;
      varianceSum += diff * diff;
    }

    return varianceSum / count;
  }

  /// Build an ML Kit InputImage from a CameraImage.
  static InputImage buildInputImage(
    CameraImage image,
    CameraDescription? camera,
  ) {
    final sensorOrientation = camera?.sensorOrientation ?? 0;
    final rotation = InputImageRotationValue.fromRawValue(sensorOrientation) ??
        InputImageRotation.rotation0deg;

    if (Platform.isAndroid) {
      final nv21Bytes = convertToNV21(image);
      final metadata = InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: InputImageFormat.nv21,
        bytesPerRow: image.planes[0].bytesPerRow,
      );
      return InputImage.fromBytes(bytes: nv21Bytes, metadata: metadata);
    } else {
      final allBytes = WriteBuffer();
      for (final plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();
      final metadata = InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: InputImageFormat.bgra8888,
        bytesPerRow: image.planes[0].bytesPerRow,
      );
      return InputImage.fromBytes(bytes: bytes, metadata: metadata);
    }
  }
}
