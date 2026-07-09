import 'package:flutter_test/flutter_test.dart';
import 'package:netpad/core/models/peer.dart';

void main() {
  test('mergeDiscovery keeps existing host addresses when update is empty', () {
    final existing = Peer(
      id: 'peer-1',
      displayName: 'Kitchen',
      port: 4040,
      hostAddresses: ['192.168.1.20'],
    );
    final incoming = Peer(
      id: 'peer-1',
      displayName: 'Kitchen',
      port: 4040,
    );

    final merged = Peer.mergeDiscovery(incoming, existing);
    expect(merged.hostAddresses, ['192.168.1.20']);
    expect(merged.port, 4040);
    expect(merged.resolveState, PeerResolveState.resolved);
  });

  test('mergeDiscovery prefers incoming port when positive', () {
    final existing = Peer(
      id: 'peer-1',
      displayName: 'Kitchen',
      port: 4040,
      hostAddresses: ['192.168.1.20'],
    );
    final incoming = Peer(
      id: 'peer-1',
      displayName: 'Kitchen',
      port: 5050,
      hostAddresses: ['192.168.1.55'],
    );

    final merged = Peer.mergeDiscovery(incoming, existing);
    expect(merged.hostAddresses, ['192.168.1.55', '192.168.1.20']);
    expect(merged.port, 5050);
  });
}
