import 'package:flutter_test/flutter_test.dart';
import 'package:netpad/core/qr_connect_payload.dart';
import 'package:netpad/core/qr_image_decode.dart';
import 'package:netpad/core/qr_image_encode.dart';

void main() {
  test('encode/decode QR PNG round-trips connect payload', () {
    final payload = QrConnectPayload.encode(
      host: '192.168.1.42',
      port: 54321,
      displayName: 'Phone',
    );
    final raw = decodeQrFromImageBytes(encodeQrPng(payload));
    expect(raw, payload);
    final parsed = QrConnectPayload.tryParse(raw!);
    expect(parsed?.host, '192.168.1.42');
    expect(parsed?.port, 54321);
    expect(parsed?.displayName, 'Phone');
  });
}
