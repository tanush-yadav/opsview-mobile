import 'dart:io';
import 'package:image/image.dart';

void main() async {
  try {
    print('Loading assets/images/icon.png...');
    final iconFile = File('assets/images/icon.png');
    if (!await iconFile.exists()) {
      print('Error: assets/images/icon.png not found');
      exit(1);
    }

    final iconBytes = await iconFile.readAsBytes();
    final icon = decodeImage(iconBytes);

    if (icon == null) {
      print('Error: Could not decode icon.png');
      exit(1);
    }

    print('Original size: ${icon.width}x${icon.height}');

    // Create new background image
    // Using strict #0F172A
    final bg = Image(width: icon.width, height: icon.height);

    // Fill with #0F172A (R=15, G=23, B=42)
    // In image v4, colors are typically defined by Color structure or ints
    // Using fill to set background color
    fill(bg, color: ColorRgb8(15, 23, 42));

    // Resize original icon to 45%
    final scale = 0.45;
    final newWidth = (icon.width * scale).round();
    final newHeight = (icon.height * scale).round();

    print('Resizing to: ${newWidth}x${newHeight}');

    final resizedIcon = copyResize(
      icon,
      width: newWidth,
      height: newHeight,
      interpolation: Interpolation.cubic,
    );

    // Center the icon
    final x = (bg.width - newWidth) ~/ 2;
    final y = (bg.height - newHeight) ~/ 2;

    print('Compositing at $x, $y');

    compositeImage(bg, resizedIcon, dstX: x, dstY: y);

    final outFile = File('assets/images/icon_foreground_navy.png');
    await outFile.writeAsBytes(encodePng(bg));
    print('Success! Generated ${outFile.path}');
  } catch (e, stack) {
    print('Error: $e');
    print(stack);
    exit(1);
  }
}
