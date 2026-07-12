import 'package:flutter_test/flutter_test.dart';
import 'package:netpad/core/models/peer.dart';

void main() {
  group('Peer stale helpers', () {
    test('manual peers are identifiable for TTL exemption', () {
      final peer = Peer.manual(host: '192.168.1.10', port: 12345);
      expect(peer.isManual, isTrue);
      expect(peer.id.startsWith('manual:'), isTrue);
    });

    test('discovered peers are not manual', () {
      final peer = Peer(
        id: 'abc',
        displayName: 'Phone',
        port: 12345,
        hostAddresses: const ['192.168.1.20'],
      );
      expect(peer.isManual, isFalse);
    });
  });
}
