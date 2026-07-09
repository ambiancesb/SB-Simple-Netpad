import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mdns_dart/mdns_dart.dart';
import 'package:netpad/services/linux_mdns_backend.dart';

void main() {
  test('peerFromMdnsEntry prefers TXT ip over loopback A records', () {
    final entry = ServiceEntry(
      name: 'SBNetpad-deadbeef._sbnetpad._tcp.local.',
      host: 'localhost.local.',
      port: 4040,
      infoFields: [
        'id=peer-uuid',
        'name=Kitchen',
        'port=4040',
        'room=home',
        'ip=192.168.1.55',
      ],
    );
    entry.addIPv4Address(InternetAddress('127.0.0.1'));

    final peer = peerFromMdnsEntry(entry);
    expect(peer, isNotNull);
    expect(peer!.hostAddresses, ['192.168.1.55']);
    expect(peer.hostname, isNull);
  });

  test('peerFromMdnsEntry maps TXT attributes to Peer', () {
    final entry = ServiceEntry(
      name: 'SBNetpad-deadbeef._sbnetpad._tcp.local.',
      host: 'laptop.local.',
      port: 4040,
      infoFields: ['id=peer-uuid', 'name=Kitchen', 'port=4040', 'room=home'],
    );
    entry.addIPv4Address(InternetAddress('192.168.1.20'));

    final peer = peerFromMdnsEntry(entry);
    expect(peer, isNotNull);
    expect(peer!.id, 'peer-uuid');
    expect(peer.displayName, 'Kitchen');
    expect(peer.port, 4040);
    expect(peer.hostAddresses, ['192.168.1.20']);
    expect(peer.hostname, 'laptop');
    expect(peer.resolveState.name, 'resolved');
  });

  test('peerFromMdnsEntry returns null without id', () {
    final entry = ServiceEntry(
      name: 'orphan._sbnetpad._tcp.local.',
      port: 1,
      infoFields: const [],
    );
    expect(peerFromMdnsEntry(entry), isNull);
  });
}
