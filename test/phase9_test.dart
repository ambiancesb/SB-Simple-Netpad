import 'package:flutter_test/flutter_test.dart';
import 'package:netpad/core/auto_sync_token.dart';
import 'package:netpad/core/auto_sync_validation.dart';
import 'package:netpad/core/constants.dart';
import 'package:netpad/core/pair_request_payload.dart';
import 'package:netpad/core/peer_disconnect_validation.dart';
import 'package:netpad/core/models/trusted_peer.dart';
import 'package:netpad/data/repositories/trust_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('shouldHonorPeerDisconnect', () {
    test('honors when payload names the sender', () {
      expect(
        shouldHonorPeerDisconnect(
          senderPeerId: 'peer-a',
          payloadPeerId: 'peer-a',
        ),
        isTrue,
      );
    });

    test('rejects when payload names a different peer', () {
      expect(
        shouldHonorPeerDisconnect(
          senderPeerId: 'peer-a',
          payloadPeerId: 'peer-b',
        ),
        isFalse,
      );
    });

    test('rejects empty payload or unknown sender', () {
      expect(
        shouldHonorPeerDisconnect(
          senderPeerId: 'peer-a',
          payloadPeerId: '',
        ),
        isFalse,
      );
      expect(
        shouldHonorPeerDisconnect(
          senderPeerId: null,
          payloadPeerId: 'peer-a',
        ),
        isFalse,
      );
    });
  });

  group('canAutoAcceptPairRequest', () {
    const pin = 'AA:BB';
    const token = 'stored-token';

    test('accepts when token, pin, and protocol match', () {
      expect(
        canAutoAcceptPairRequest(
          isBlocked: false,
          peerProtocol: kProtocolVersion,
          alreadyConnected: false,
          canAutoSync: true,
          storedToken: token,
          requestToken: token,
          pinnedFingerprint: pin,
          requestFingerprint: pin,
        ),
        isTrue,
      );
    });

    test('rejects wrong or missing token', () {
      expect(
        canAutoAcceptPairRequest(
          isBlocked: false,
          peerProtocol: kProtocolVersion,
          alreadyConnected: false,
          canAutoSync: true,
          storedToken: token,
          requestToken: 'other-token',
          pinnedFingerprint: pin,
          requestFingerprint: pin,
        ),
        isFalse,
      );
      expect(
        canAutoAcceptPairRequest(
          isBlocked: false,
          peerProtocol: kProtocolVersion,
          alreadyConnected: false,
          canAutoSync: true,
          storedToken: token,
          requestToken: null,
          pinnedFingerprint: pin,
          requestFingerprint: pin,
        ),
        isFalse,
      );
    });

    test('rejects when blocked, already connected, or auto-sync disabled', () {
      final base = (
        isBlocked: false,
        peerProtocol: kProtocolVersion,
        alreadyConnected: false,
        canAutoSync: true,
        storedToken: token,
        requestToken: token,
        pinnedFingerprint: pin,
        requestFingerprint: pin,
      );

      expect(
        canAutoAcceptPairRequest(
          isBlocked: true,
          peerProtocol: base.peerProtocol,
          alreadyConnected: base.alreadyConnected,
          canAutoSync: base.canAutoSync,
          storedToken: base.storedToken,
          requestToken: base.requestToken,
          pinnedFingerprint: base.pinnedFingerprint,
          requestFingerprint: base.requestFingerprint,
        ),
        isFalse,
      );
      expect(
        canAutoAcceptPairRequest(
          isBlocked: base.isBlocked,
          peerProtocol: base.peerProtocol,
          alreadyConnected: true,
          canAutoSync: base.canAutoSync,
          storedToken: base.storedToken,
          requestToken: base.requestToken,
          pinnedFingerprint: base.pinnedFingerprint,
          requestFingerprint: base.requestFingerprint,
        ),
        isFalse,
      );
      expect(
        canAutoAcceptPairRequest(
          isBlocked: base.isBlocked,
          peerProtocol: base.peerProtocol,
          alreadyConnected: base.alreadyConnected,
          canAutoSync: false,
          storedToken: base.storedToken,
          requestToken: base.requestToken,
          pinnedFingerprint: base.pinnedFingerprint,
          requestFingerprint: base.requestFingerprint,
        ),
        isFalse,
      );
    });

    test('rejects protocol mismatch and fingerprint mismatch', () {
      expect(
        canAutoAcceptPairRequest(
          isBlocked: false,
          peerProtocol: 2,
          alreadyConnected: false,
          canAutoSync: true,
          storedToken: token,
          requestToken: token,
          pinnedFingerprint: pin,
          requestFingerprint: pin,
        ),
        isFalse,
      );
      expect(
        canAutoAcceptPairRequest(
          isBlocked: false,
          peerProtocol: kProtocolVersion,
          alreadyConnected: false,
          canAutoSync: true,
          storedToken: token,
          requestToken: token,
          pinnedFingerprint: pin,
          requestFingerprint: 'CC:DD',
        ),
        isFalse,
      );
    });
  });

  group('shouldRefuseTrustedReconnect', () {
    test('is true when token present but fingerprint mismatches pin', () {
      expect(
        shouldRefuseTrustedReconnect(
          requestToken: 'tok',
          pinnedFingerprint: 'AA:BB',
          requestFingerprint: 'CC:DD',
        ),
        isTrue,
      );
    });

    test('is false without token or pin', () {
      expect(
        shouldRefuseTrustedReconnect(
          requestToken: null,
          pinnedFingerprint: 'AA:BB',
          requestFingerprint: 'CC:DD',
        ),
        isFalse,
      );
      expect(
        shouldRefuseTrustedReconnect(
          requestToken: 'tok',
          pinnedFingerprint: null,
          requestFingerprint: 'CC:DD',
        ),
        isFalse,
      );
    });
  });

  group('buildPairRequestPayload', () {
    test('always includes protocol fields and cert fingerprint', () {
      final payload = buildPairRequestPayload(
        requestId: 'req-1',
        fromId: 'self-id',
        fromName: 'My Device',
        certFingerprint: 'AA:BB',
      );

      expect(payload['requestId'], 'req-1');
      expect(payload['fromId'], 'self-id');
      expect(payload['fromName'], 'My Device');
      expect(payload['certFingerprint'], 'AA:BB');
      expect(payload.containsKey('autoSyncToken'), isFalse);
    });

    test('includes autoSyncToken when provided', () {
      final payload = buildPairRequestPayload(
        requestId: 'req-1',
        fromId: 'self-id',
        fromName: 'My Device',
        certFingerprint: 'AA:BB',
        autoSyncToken: 'stored-token',
      );

      expect(payload['autoSyncToken'], 'stored-token');
    });

    test('omits empty autoSyncToken', () {
      final payload = buildPairRequestPayload(
        requestId: 'req-1',
        fromId: 'self-id',
        fromName: 'My Device',
        certFingerprint: 'AA:BB',
        autoSyncToken: '',
      );

      expect(payload.containsKey('autoSyncToken'), isFalse);
    });
  });

  group('shouldSendAutoSyncToken', () {
    test('is true only when canAutoSync and token present', () {
      expect(
        shouldSendAutoSyncToken(canAutoSync: true, autoSyncToken: 'tok'),
        isTrue,
      );
      expect(
        shouldSendAutoSyncToken(canAutoSync: false, autoSyncToken: 'tok'),
        isFalse,
      );
      expect(
        shouldSendAutoSyncToken(canAutoSync: true, autoSyncToken: null),
        isFalse,
      );
      expect(
        shouldSendAutoSyncToken(canAutoSync: true, autoSyncToken: ''),
        isFalse,
      );
    });
  });

  group('generateAutoSyncToken', () {
    test('produces a non-empty base64url string', () {
      final token = generateAutoSyncToken();
      expect(token, isNotEmpty);
      expect(token.contains('='), isFalse);
      expect(RegExp(r'^[A-Za-z0-9_-]+$').hasMatch(token), isTrue);
    });

    test('tokens are distinct across calls', () {
      final a = generateAutoSyncToken();
      final b = generateAutoSyncToken();
      expect(a, isNot(b));
    });
  });

  group('TrustedPeer', () {
    test('serializes to and from JSON', () {
      final pairedAt = DateTime.utc(2026, 7, 7, 14, 30);
      final peer = TrustedPeer(
        displayName: 'Laptop',
        autoSyncToken: 'tok-abc',
        pairedAt: pairedAt,
        autoSyncEnabled: false,
      );

      final restored = TrustedPeer.fromJson(peer.toJson());
      expect(restored.displayName, 'Laptop');
      expect(restored.autoSyncToken, 'tok-abc');
      expect(restored.pairedAt, pairedAt);
      expect(restored.autoSyncEnabled, isFalse);
    });
  });

  group('TrustStore trusted peers', () {
    Future<TrustStore> store() async {
      SharedPreferences.setMockInitialValues({});
      return TrustStore(await SharedPreferences.getInstance());
    }

    test('setTrustedPeer persists across reload', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final trust = TrustStore(prefs);

      await trust.pin('peer-1', 'AB:CD');
      await trust.setTrustedPeer(
        peerId: 'peer-1',
        displayName: 'Laptop',
        autoSyncToken: 'secret-token',
        pairedAt: DateTime.utc(2026, 1, 1),
      );

      final reloaded = TrustStore(prefs);
      final peer = reloaded.trustedPeer('peer-1');
      expect(peer, isNotNull);
      expect(peer!.displayName, 'Laptop');
      expect(peer.autoSyncToken, 'secret-token');
      expect(peer.pairedAt, DateTime.utc(2026, 1, 1));
      expect(peer.autoSyncEnabled, isTrue);
    });

    test('canAutoSync requires pin, token, and enabled flag', () async {
      final trust = await store();
      const peerId = 'peer-1';
      const token = 'secret-token';

      expect(trust.canAutoSync(peerId), isFalse);

      await trust.setTrustedPeer(
        peerId: peerId,
        displayName: 'Laptop',
        autoSyncToken: token,
      );
      expect(trust.canAutoSync(peerId), isFalse);

      await trust.pin(peerId, 'AB:CD');
      expect(trust.canAutoSync(peerId), isTrue);

      await trust.setAutoSyncEnabled(peerId, false);
      expect(trust.canAutoSync(peerId), isFalse);

      await trust.setAutoSyncEnabled(peerId, true);
      expect(trust.canAutoSync(peerId), isTrue);
    });

    test('revokeAutoSync removes token but keeps pin', () async {
      final trust = await store();
      const peerId = 'peer-1';

      await trust.pin(peerId, 'AB:CD');
      await trust.setTrustedPeer(
        peerId: peerId,
        displayName: 'Laptop',
        autoSyncToken: 'secret-token',
      );
      expect(trust.canAutoSync(peerId), isTrue);

      await trust.revokeAutoSync(peerId);
      expect(trust.trustedPeer(peerId), isNull);
      expect(trust.hasPin(peerId), isTrue);
      expect(trust.canAutoSync(peerId), isFalse);
    });

    test('block removes trusted peer and disables auto-sync', () async {
      final trust = await store();
      const peerId = 'peer-1';

      await trust.pin(peerId, 'AB:CD');
      await trust.setTrustedPeer(
        peerId: peerId,
        displayName: 'Laptop',
        autoSyncToken: 'secret-token',
      );
      expect(trust.canAutoSync(peerId), isTrue);

      await trust.block(peerId, 'Laptop');
      expect(trust.isBlocked(peerId), isTrue);
      expect(trust.trustedPeer(peerId), isNull);
      expect(trust.trustedPeers, isEmpty);
      expect(trust.canAutoSync(peerId), isFalse);
    });

    test('trustedPeers excludes blocked entries', () async {
      final trust = await store();

      await trust.pin('peer-1', 'AA');
      await trust.setTrustedPeer(
        peerId: 'peer-1',
        displayName: 'Laptop',
        autoSyncToken: 'tok-1',
      );
      await trust.pin('peer-2', 'BB');
      await trust.setTrustedPeer(
        peerId: 'peer-2',
        displayName: 'Phone',
        autoSyncToken: 'tok-2',
      );
      await trust.block('peer-2', 'Phone');

      expect(trust.trustedPeers.keys, ['peer-1']);
    });

    test('autoSyncToken returns stored value', () async {
      final trust = await store();
      await trust.setTrustedPeer(
        peerId: 'peer-1',
        displayName: 'Laptop',
        autoSyncToken: 'my-token',
      );
      expect(trust.autoSyncToken('peer-1'), 'my-token');
      expect(trust.autoSyncToken('missing'), isNull);
    });

    test('outbound reconnect attaches token when canAutoSync', () async {
      final trust = await store();
      const peerId = 'peer-1';
      const token = 'stored-token';

      await trust.pin(peerId, 'AB:CD');
      await trust.setTrustedPeer(
        peerId: peerId,
        displayName: 'Laptop',
        autoSyncToken: token,
      );

      final payload = buildPairRequestPayload(
        requestId: 'req-1',
        fromId: 'self',
        fromName: 'Self',
        certFingerprint: '11:22',
        autoSyncToken:
            trust.canAutoSync(peerId) ? trust.autoSyncToken(peerId) : null,
      );

      expect(payload['autoSyncToken'], token);
      expect(
        shouldSendAutoSyncToken(
          canAutoSync: trust.canAutoSync(peerId),
          autoSyncToken: trust.autoSyncToken(peerId),
        ),
        isTrue,
      );
    });

    test('first pair omits token when peer is not trusted', () async {
      final trust = await store();
      const peerId = 'peer-1';

      final payload = buildPairRequestPayload(
        requestId: 'req-1',
        fromId: 'self',
        fromName: 'Self',
        certFingerprint: '11:22',
        autoSyncToken:
            trust.canAutoSync(peerId) ? trust.autoSyncToken(peerId) : null,
      );

      expect(payload.containsKey('autoSyncToken'), isFalse);
      expect(trust.canAutoSync(peerId), isFalse);
    });

    test('revoked token falls back to manual pair validation', () async {
      final trust = await store();
      const peerId = 'peer-1';
      const pin = 'AA:BB';
      const token = 'stored-token';

      await trust.pin(peerId, pin);
      await trust.setTrustedPeer(
        peerId: peerId,
        displayName: 'Laptop',
        autoSyncToken: token,
      );
      await trust.revokeAutoSync(peerId);

      expect(trust.canAutoSync(peerId), isFalse);
      expect(
        canAutoAcceptPairRequest(
          isBlocked: false,
          peerProtocol: kProtocolVersion,
          alreadyConnected: false,
          canAutoSync: trust.canAutoSync(peerId),
          storedToken: trust.autoSyncToken(peerId),
          requestToken: token,
          pinnedFingerprint: pin,
          requestFingerprint: pin,
        ),
        isFalse,
      );
    });

    test('blocklist overrides auto-sync even with matching credentials', () async {
      final trust = await store();
      const peerId = 'peer-1';
      const pin = 'AA:BB';
      const token = 'stored-token';

      await trust.pin(peerId, pin);
      await trust.setTrustedPeer(
        peerId: peerId,
        displayName: 'Laptop',
        autoSyncToken: token,
      );
      await trust.block(peerId, 'Laptop');

      expect(
        canAutoAcceptPairRequest(
          isBlocked: trust.isBlocked(peerId),
          peerProtocol: kProtocolVersion,
          alreadyConnected: false,
          canAutoSync: trust.canAutoSync(peerId),
          storedToken: trust.autoSyncToken(peerId),
          requestToken: token,
          pinnedFingerprint: pin,
          requestFingerprint: pin,
        ),
        isFalse,
      );
    });
  });
}
