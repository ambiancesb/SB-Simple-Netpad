import 'package:flutter_test/flutter_test.dart';
import 'package:netpad/core/local_network.dart';
import 'package:netpad/core/peer_endpoint.dart';

void main() {
  tearDown(LocalNetwork.clearActiveSubnetsForTesting);

  test('isLoopbackHost rejects localhost and loopback literals', () {
    expect(PeerEndpoint.isLoopbackHost('localhost'), isTrue);
    expect(PeerEndpoint.isLoopbackHost('127.0.0.1'), isTrue);
    expect(PeerEndpoint.isLoopbackHost('192.168.1.10'), isFalse);
  });

  test('usableAddresses prefers TXT ip and drops loopback', () {
    final hosts = PeerEndpoint.usableAddresses(
      const ['127.0.0.1', '192.168.1.20'],
      txtIp: '192.168.1.55',
    );
    expect(hosts, ['192.168.1.55', '192.168.1.20']);
  });

  test('usableHostname drops localhost', () {
    expect(PeerEndpoint.usableHostname('localhost'), isNull);
    expect(PeerEndpoint.usableHostname('phone.local'), 'phone.local');
  });
}
