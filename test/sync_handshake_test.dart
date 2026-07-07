import 'package:flutter_test/flutter_test.dart';
import 'package:netpad/core/constants.dart';
import 'package:netpad/core/models/protocol_message.dart';
import 'package:netpad/services/local_server.dart';
import 'package:netpad/services/protocol_codec.dart';
import 'package:netpad/services/tls_identity.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

void main() {
  group('pairing handshake integration', () {
    test('mock peer pairing flow over LocalServer message handler', () async {
      SharedPreferences.setMockInitialValues({});
      final tls = await TlsIdentity.loadOrCreate(
        await SharedPreferences.getInstance(),
      );
      final server = LocalServer(securityContext: tls.serverContext);
      await server.start();

      const requestId = 'req-integration';
      const peerId = 'peer-integration';
      final sessionToken = const Uuid().v4();
      final autoSyncToken = 'auto-sync-token-integration';
      final inbound = <ProtocolMessage>[];
      final outbound = <ProtocolMessage>[];

      server.onMessage = (connectionId, message) {
        inbound.add(message);
        if (message.type != MessageTypes.pairRequest) return;

        final response = ProtocolMessage(
          type: MessageTypes.pairResponse,
          payload: {
            'requestId': requestId,
            'accepted': true,
            'protocolVersion': kProtocolVersion,
          },
        );
        final complete = ProtocolMessage(
          type: MessageTypes.pairComplete,
          payload: {
            'sessionToken': sessionToken,
            'autoSyncToken': autoSyncToken,
          },
        );
        outbound.addAll([response, complete]);
        server.send(connectionId, response);
        server.send(connectionId, complete);
      };

      final pairRequest = ProtocolMessage(
        type: MessageTypes.pairRequest,
        payload: {
          'requestId': requestId,
          'fromId': peerId,
          'fromName': 'Integration Peer',
          'protocolVersion': kProtocolVersion,
        },
      );

      server.onMessage!('in_test', pairRequest);

      expect(inbound, hasLength(1));
      expect(inbound.single.type, MessageTypes.pairRequest);
      expect(outbound.map((m) => m.type), [
        MessageTypes.pairResponse,
        MessageTypes.pairComplete,
      ]);
      expect(outbound.last.payload['sessionToken'], sessionToken);
      expect(outbound.last.payload['autoSyncToken'], autoSyncToken);

      final ping = ProtocolMessage(
        type: MessageTypes.ping,
        payload: {
          'peerId': peerId,
          'sessionToken': sessionToken,
          'sentAt': DateTime.now().millisecondsSinceEpoch,
        },
      );
      final wire = ProtocolCodec.encode(ping);
      final decoded = ProtocolCodec.decode(wire);
      expect(decoded, isNotNull);
      expect(decoded!.payload['sessionToken'], sessionToken);
      expect(ProtocolMessage.versionFromJson(decoded.toJson()), kProtocolVersion);

      await server.stop();
    });
  });
}
