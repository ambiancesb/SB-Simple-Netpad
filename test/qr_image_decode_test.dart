import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:netpad/core/qr_connect_payload.dart';
import 'package:netpad/core/qr_image_decode.dart';
import 'package:zxing2/qrcode.dart';

Uint8List _encodePng(String payload) {
  final qrcode = Encoder.encode(payload, ErrorCorrectionLevel.m);
  final matrix = qrcode.matrix!;
  const scale = 4;
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

void main() {
  test('decodeQrFromImageBytes recovers connect payload', () {
    final payload = QrConnectPayload.encode(
      host: '192.168.1.42',
      port: 54321,
      displayName: 'Phone',
    );
    final raw = decodeQrFromImageBytes(_encodePng(payload));
    expect(raw, payload);
    final parsed = QrConnectPayload.tryParse(raw!);
    expect(parsed?.host, '192.168.1.42');
    expect(parsed?.port, 54321);
    expect(parsed?.displayName, 'Phone');
  });
}
