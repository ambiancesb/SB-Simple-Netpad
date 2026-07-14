import 'package:flutter_test/flutter_test.dart';
import 'package:netpad/core/auto_sync_token.dart';
import 'package:netpad/core/constants.dart';
import 'package:netpad/core/models/protocol_message.dart';
import 'package:netpad/core/session_token_gate.dart';
import 'package:netpad/core/trust_offer_negotiation.dart';
import 'package:netpad/data/repositories/trust_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<TrustStore> _store() async {
  SharedPreferences.setMockInitialValues({});
  return TrustStore(await SharedPreferences.getInstance());
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('trust offer negotiation', () {
    test('smaller instance id owns token issuance', () {
      expect(ownsTrustTokenIssuance('aaa', 'bbb'), isTrue);
      expect(ownsTrustTokenIssuance('bbb', 'aaa'), isFalse);
    });

    test('simultaneous dual offer: issuer vs wait', () {
      expect(
        simultaneousTrustAction(
          localInstanceId: 'aaa',
          remoteInstanceId: 'bbb',
        ),
        SimultaneousTrustAction.completeAsIssuer,
      );
      expect(
        simultaneousTrustAction(
          localInstanceId: 'bbb',
          remoteInstanceId: 'aaa',
        ),
        SimultaneousTrustAction.waitForPeerResponse,
      );
    });
  });

  group('session token gate for mid-session trust', () {
    test('trust_offer and trust_response require session token', () {
      expect(messageTypeRequiresSessionToken(MessageTypes.trustOffer), isTrue);
      expect(
        messageTypeRequiresSessionToken(MessageTypes.trustResponse),
        isTrue,
      );
    });

    test('pairing messages do not require session token', () {
      expect(
        messageTypeRequiresSessionToken(MessageTypes.pairRequest),
        isFalse,
      );
      expect(
        messageTypeRequiresSessionToken(MessageTypes.pairComplete),
        isFalse,
      );
    });
  });

  group('mid-session mutual trust storage', () {
    test('offer accept path stores matching token on both devices', () async {
      final deviceA = await _store();
      final deviceB = await _store();
      const peerA = 'instance-a';
      const peerB = 'instance-b';
      final token = generateAutoSyncToken();

      await deviceA.pin(peerB, 'AA:BB');
      await deviceB.pin(peerA, 'CC:DD');

      // B accepts and issues the token (same as SyncRepository._completeTrustAsIssuer).
      await deviceB.setTrustedPeer(
        peerId: peerA,
        displayName: 'Device A',
        autoSyncToken: token,
      );
      // A receives trust_response and stores the same token.
      await deviceA.setTrustedPeer(
        peerId: peerB,
        displayName: 'Device B',
        autoSyncToken: token,
      );

      expect(deviceA.canAutoSync(peerB), isTrue);
      expect(deviceB.canAutoSync(peerA), isTrue);
      expect(deviceA.autoSyncToken(peerB), token);
      expect(deviceB.autoSyncToken(peerA), token);
    });

    test('offer decline path leaves neither store trusted', () async {
      final deviceA = await _store();
      final deviceB = await _store();
      const peerA = 'instance-a';
      const peerB = 'instance-b';

      // Decline: no setTrustedPeer on either side.
      expect(deviceA.canAutoSync(peerB), isFalse);
      expect(deviceB.canAutoSync(peerA), isFalse);
      expect(deviceA.trustedPeers, isEmpty);
      expect(deviceB.trustedPeers, isEmpty);
    });

    test('simultaneous offer resolves to one shared token', () async {
      final deviceA = await _store();
      final deviceB = await _store();
      const idA = 'aaa';
      const idB = 'bbb';

      expect(ownsTrustTokenIssuance(idA, idB), isTrue);

      final token = generateAutoSyncToken();
      // A owns issuance; both end with the same token.
      await deviceA.setTrustedPeer(
        peerId: idB,
        displayName: 'B',
        autoSyncToken: token,
      );
      await deviceB.setTrustedPeer(
        peerId: idA,
        displayName: 'A',
        autoSyncToken: token,
      );

      expect(deviceA.autoSyncToken(idB), deviceB.autoSyncToken(idA));
    });
  });

  group('protocol trust messages', () {
    test('trust_offer encodes protocol version 4', () {
      final msg = ProtocolMessage(
        type: MessageTypes.trustOffer,
        payload: {
          'requestId': 'r1',
          'fromId': 'a',
          'fromName': 'A',
          'sessionToken': 'sess',
        },
      );
      expect(msg.toJson()['v'], kProtocolVersion);
      expect(msg.toJson()['v'], 4);
      expect(msg.toJson()['type'], MessageTypes.trustOffer);
    });

    test('trust_response carries autoSyncToken when accepted', () {
      final msg = ProtocolMessage(
        type: MessageTypes.trustResponse,
        payload: {
          'requestId': 'r1',
          'accepted': true,
          'autoSyncToken': 'tok',
          'sessionToken': 'sess',
        },
      );
      expect(msg.payload['accepted'], isTrue);
      expect(msg.payload['autoSyncToken'], 'tok');
    });
  });
}
