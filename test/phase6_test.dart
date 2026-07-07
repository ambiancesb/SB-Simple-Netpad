import 'package:flutter_test/flutter_test.dart';
import 'package:netpad/core/constants.dart';
import 'package:netpad/core/models/protocol_message.dart';
import 'package:netpad/data/repositories/document_repository.dart';
import 'package:netpad/services/note_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<NoteStorageService> _storage() async {
  SharedPreferences.setMockInitialValues({});
  return NoteStorageService(await SharedPreferences.getInstance());
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Protocol v3', () {
    test('kProtocolVersion is 3', () {
      expect(kProtocolVersion, 3);
    });

    test('messages encode wire version from constant', () {
      final msg = ProtocolMessage(
        type: MessageTypes.pairRequest,
        payload: {'protocolVersion': kProtocolVersion},
      );
      expect(msg.toJson()['v'], kProtocolVersion);
    });

    test('versionFromJson reads top-level v field', () {
      expect(
        ProtocolMessage.versionFromJson({'type': 'ping', 'v': 2}),
        2,
      );
      expect(ProtocolMessage.versionFromJson({'type': 'ping'}), 1);
    });
  });

  group('live edit conflict detection', () {
    test('isLiveEditConflict is true for same revision, different text', () async {
      final storage = await _storage();
      final doc = DocumentRepository(
        instanceId: 'aaa',
        id: 'doc1',
        title: 'Note',
        text: 'local',
        revision: 3,
        storage: storage,
        onLocalEditReady: (_, _, _, _) {},
      );
      expect(
        doc.isLiveEditConflict(
          revision: 3,
          text: 'remote',
          originId: 'bbb',
        ),
        isTrue,
      );
    });

    test('isLiveEditConflict is false for own edits', () async {
      final storage = await _storage();
      final doc = DocumentRepository(
        instanceId: 'aaa',
        id: 'doc1',
        title: 'Note',
        text: 'local',
        revision: 3,
        storage: storage,
        onLocalEditReady: (_, _, _, _) {},
      );
      expect(
        doc.isLiveEditConflict(
          revision: 3,
          text: 'other',
          originId: 'aaa',
        ),
        isFalse,
      );
    });

    test('isLiveEditConflict is false when revision differs', () async {
      final storage = await _storage();
      final doc = DocumentRepository(
        instanceId: 'aaa',
        id: 'doc1',
        title: 'Note',
        text: 'local',
        revision: 3,
        storage: storage,
        onLocalEditReady: (_, _, _, _) {},
      );
      expect(
        doc.isLiveEditConflict(
          revision: 4,
          text: 'remote',
          originId: 'bbb',
        ),
        isFalse,
      );
    });

    test('remoteRevisionWins uses originId tie-break at equal revision', () async {
      final storage = await _storage();
      final doc = DocumentRepository(
        instanceId: 'aaa',
        id: 'doc1',
        title: 'Note',
        text: 'local',
        revision: 3,
        storage: storage,
        onLocalEditReady: (_, _, _, _) {},
      );
      expect(doc.remoteRevisionWins(3, 'bbb'), isTrue);
      expect(doc.remoteRevisionWins(3, 'aaa'), isFalse);
    });
  });

  group('heartbeat constants', () {
    test('interval and timeout match Phase 6 spec', () {
      expect(kHeartbeatInterval, const Duration(seconds: 15));
      expect(kHeartbeatTimeout, const Duration(seconds: 45));
    });
  });
}
