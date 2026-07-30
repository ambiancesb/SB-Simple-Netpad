import 'package:flutter_test/flutter_test.dart';
import 'package:netpad/core/qr_connect_payload.dart';

void main() {
  test('encode builds sbnetpad URI with optional name', () {
    expect(
      QrConnectPayload.encode(host: '192.168.1.42', port: 54321),
      'sbnetpad://connect?host=192.168.1.42&port=54321',
    );
    expect(
      QrConnectPayload.encode(
        host: '192.168.1.42',
        port: 54321,
        displayName: 'Living room PC',
      ),
      'sbnetpad://connect?host=192.168.1.42&port=54321&name=Living+room+PC',
    );
  });

  test('tryParse accepts URI payload', () {
    final result = QrConnectPayload.tryParse(
      'sbnetpad://connect?host=10.0.0.5&port=12345&name=Phone',
    );
    expect(result, isNotNull);
    expect(result!.host, '10.0.0.5');
    expect(result.port, 12345);
    expect(result.displayName, 'Phone');
  });

  test('tryParse accepts plain host:port', () {
    final result = QrConnectPayload.tryParse('192.168.1.42:54321');
    expect(result, isNotNull);
    expect(result!.host, '192.168.1.42');
    expect(result.port, 54321);
    expect(result.displayName, isNull);
  });

  test('tryParse accepts bracketed IPv6 host:port', () {
    final result = QrConnectPayload.tryParse('[fe80::1]:9999');
    expect(result, isNotNull);
    expect(result!.host, 'fe80::1');
    expect(result.port, 9999);
  });

  test('tryParse accepts wss URI', () {
    final result = QrConnectPayload.tryParse('wss://192.168.1.10:4444/ws');
    expect(result, isNotNull);
    expect(result!.host, '192.168.1.10');
    expect(result.port, 4444);
  });

  test('tryParse rejects invalid payloads', () {
    expect(QrConnectPayload.tryParse(''), isNull);
    expect(QrConnectPayload.tryParse('not-a-code'), isNull);
    expect(QrConnectPayload.tryParse('192.168.1.1:99999'), isNull);
    expect(QrConnectPayload.tryParse('sbnetpad://connect?host=&port=1'), isNull);
  });
}
