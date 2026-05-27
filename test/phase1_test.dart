import 'package:flutter_test/flutter_test.dart';
import 'package:netpad/core/models/peer.dart';

void main() {
  test('Peer.manual is connectable with stable id', () {
    final peer = Peer.manual(
      host: '192.168.1.10',
      port: 45678,
      displayName: 'Office PC',
    );
    expect(peer.isManual, isTrue);
    expect(peer.id, 'manual:192.168.1.10:45678');
    expect(peer.isConnectable, isTrue);
    expect(peer.port, 45678);
    expect(peer.displayName, 'Office PC');
  });
}
