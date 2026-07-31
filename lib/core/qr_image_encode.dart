import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:zxing2/qrcode.dart';

/// Renders [payload] as a high-contrast PNG QR code.
Uint8List encodeQrPng(String payload, {int scale = 6}) {
  final qrcode = Encoder.encode(payload, ErrorCorrectionLevel.m);
  final matrix = qrcode.matrix!;
  final image = img.Image(
    width: matrix.width * scale,
    height: matrix.height * scale,
    numChannels: 4,
  );
  img.fill(image, color: img.ColorRgba8(255, 255, 255, 255));
  for (var x = 0; x < matrix.width; x++) {
    for (var y = 0; y < matrix.height; y++) {
      if (matrix.get(x, y) == 1) {
        img.fillRect(
          image,
          x1: x * scale,
          y1: y * scale,
          x2: x * scale + scale,
          y2: y * scale + scale,
          color: img.ColorRgba8(0, 0, 0, 255),
        );
      }
    }
  }
  return Uint8List.fromList(img.encodePng(image));
}
