import 'package:flutter_test/flutter_test.dart';
import 'package:netpad/core/reconnect_divergence.dart';
import 'package:netpad/core/sync_relay.dart';
import 'package:netpad/data/repositories/workspace_repository.dart';
import 'package:netpad/services/entitlements/entitlement_constants.dart';
import 'package:netpad/services/note_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<NoteStorageService> _storage() async {
  SharedPreferences.setMockInitialValues({});
  return NoteStorageService(await SharedPreferences.getInstance());
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('per-note sync flags', () {
    test('new notes default to sync disabled', () async {
      final ws = WorkspaceRepository(instanceId: 'aaa', storage: await _storage());
      await ws.load();
      expect(ws.isSyncEnabled(ws.documents.first.id), isFalse);
      expect(ws.syncedNoteCount, 0);

      final created = ws.createNote(title: 'Second');
      expect(ws.isSyncEnabled(created.id), isFalse);
      expect(ws.syncedNoteCount, 0);
    });

    test('catalogPayload excludes local-only notes', () async {
      final ws = WorkspaceRepository(instanceId: 'aaa', storage: await _storage());
      await ws.load();
      final synced = ws.documents.first.id;
      ws.setSyncEnabled(synced, true);
      final localOnly = ws.createNote(title: 'Private').id;

      final catalog = ws.catalogPayload();
      expect(catalog.map((e) => e['docId']), [synced]);
      expect(catalog.map((e) => e['docId']), isNot(contains(localOnly)));
    });

    test('setSyncEnabled persists across load', () async {
      final storage = await _storage();
      final ws = WorkspaceRepository(instanceId: 'aaa', storage: storage);
      await ws.load();
      final synced = ws.documents.first.id;
      ws.setSyncEnabled(synced, true);
      final localOnly = ws.createNote(title: 'Private').id;
      await ws.flushSaveAll();

      final reloaded = WorkspaceRepository(instanceId: 'aaa', storage: storage);
      await reloaded.load();
      expect(reloaded.isSyncEnabled(localOnly), isFalse);
      expect(reloaded.isSyncEnabled(synced), isTrue);
    });

    test('delete removes sync flag for the note', () async {
      final storage = await _storage();
      final ws = WorkspaceRepository(instanceId: 'aaa', storage: storage);
      await ws.load();
      final localOnly = ws.createNote(title: 'Private').id;
      ws.deleteNote(localOnly);
      await ws.flushSaveAll();

      final prefs = await SharedPreferences.getInstance();
      final disabled = prefs.getStringList('docs_sync_disabled') ?? const [];
      expect(disabled, isNot(contains(localOnly)));
      expect(disabled, contains(ws.documents.first.id));
    });
  });

  group('outbound sync guards', () {
    test('local edit on local-only note does not invoke onDocUpdate', () async {
      final ws = WorkspaceRepository(instanceId: 'aaa', storage: await _storage());
      await ws.load();
      final synced = ws.documents.first.id;
      ws.setSyncEnabled(synced, true);
      final localOnly = ws.createNote(title: 'Private');

      var updateCount = 0;
      ws.onDocUpdate = (_, _, _, _, _) => updateCount++;

      localOnly.replaceLocal('secret text');
      expect(updateCount, 0);

      ws.documentById(synced)!.replaceLocal('synced text');
      expect(updateCount, 1);
    });

    test('rename and delete on local-only note do not broadcast', () async {
      final ws = WorkspaceRepository(instanceId: 'aaa', storage: await _storage());
      await ws.load();
      final localOnly = ws.createNote(title: 'Private').id;

      var renameCount = 0;
      var deleteCount = 0;
      ws.onDocRename = (_, _, _, _) => renameCount++;
      ws.onDocDeleted = (_, _) => deleteCount++;

      ws.renameNote(localOnly, 'Renamed');
      expect(renameCount, 0);

      ws.deleteNote(localOnly);
      expect(deleteCount, 0);
    });

    test('reorder broadcasts only sync-enabled note ids', () async {
      final ws = WorkspaceRepository(instanceId: 'aaa', storage: await _storage());
      await ws.load();
      final synced = ws.documents.first.id;
      ws.setSyncEnabled(synced, true);
      final localOnly = ws.createNote(title: 'Private').id;

      List<String>? broadcastOrder;
      ws.onOrderChanged = (order, _, _) => broadcastOrder = order;
      ws.reorderNote(1, 0);

      expect(broadcastOrder, isNotNull);
      expect(broadcastOrder, [synced]);
      expect(broadcastOrder, isNot(contains(localOnly)));
    });

    test('presence is not broadcast for a local-only active note', () async {
      final ws = WorkspaceRepository(instanceId: 'aaa', storage: await _storage());
      await ws.load();
      final localOnly = ws.createNote(title: 'Private');
      ws.selectNote(localOnly.id);

      var presenceCount = 0;
      ws.onPresence = (_, _, _) => presenceCount++;

      localOnly.controller.text = 'hello';
      await Future<void>.delayed(const Duration(milliseconds: 200));
      expect(presenceCount, 0);
    });
  });

  group('inbound sync guards', () {
    test('receiveRemoteContent ignores local-only docId', () async {
      final ws = WorkspaceRepository(instanceId: 'aaa', storage: await _storage());
      await ws.load();
      final localOnly = ws.createNote(title: 'Private');
      localOnly.replaceLocal('local secret');

      final applied = ws.receiveRemoteContent(
        docId: localOnly.id,
        title: 'Private',
        revision: 5,
        text: 'peer overwrite',
        originId: 'bbb',
      );

      expect(applied, isFalse);
      expect(localOnly.text, 'local secret');
      expect(localOnly.revision, 2);
    });

    test('receiveRemoteRename and create are ignored for local-only notes', () async {
      final ws = WorkspaceRepository(instanceId: 'aaa', storage: await _storage());
      await ws.load();
      final localOnly = ws.createNote(title: 'Private').id;

      ws.receiveRemoteRename(
        docId: localOnly,
        title: 'Peer Title',
        revision: 9,
        originId: 'bbb',
      );
      expect(ws.documentById(localOnly)!.title, 'Private');

      ws.receiveRemoteCreate(
        docId: localOnly,
        title: 'Peer Title',
        revision: 10,
        originId: 'bbb',
      );
      expect(ws.documentById(localOnly)!.title, 'Private');
      expect(ws.documentById(localOnly)!.revision, 1);
    });

    test('removeDocumentRemote keeps a local-only note', () async {
      final ws = WorkspaceRepository(instanceId: 'aaa', storage: await _storage());
      await ws.load();
      final localOnly = ws.createNote(title: 'Private').id;

      ws.removeDocumentRemote(localOnly);

      expect(ws.hasDocument(localOnly), isTrue);
      expect(ws.documents, hasLength(2));
    });

    test('mergeCatalog skips local-only metadata but learns new peer notes', () async {
      final ws = WorkspaceRepository(instanceId: 'aaa', storage: await _storage());
      await ws.load();
      final localOnly = ws.createNote(title: 'Private').id;

      ws.mergeCatalog([
        {'docId': localOnly, 'title': 'Peer Renamed', 'revision': 9},
        {'docId': 'peer-new', 'title': 'From Peer', 'revision': 1},
      ], 'bbb', orderRevision: 3);

      expect(ws.documentById(localOnly)!.title, 'Private');
      expect(ws.hasDocument('peer-new'), isTrue);
      expect(ws.documentById('peer-new')!.title, 'From Peer');
    });

    test('free inbound notes claim sync slots up to the free cap', () async {
      final ws = WorkspaceRepository(
        instanceId: 'aaa',
        storage: await _storage(),
        isStandard: () => false,
      );
      await ws.load();
      expect(ws.syncedNoteCount, 0);

      ws.mergeCatalog([
        for (var i = 1; i <= 5; i++)
          {'docId': 'peer-$i', 'title': 'Note $i', 'revision': 1},
      ], 'bbb', orderRevision: 1);

      expect(ws.documents, hasLength(6)); // default local + 5 peer
      expect(ws.syncedNoteCount, EntitlementConstants.freeSyncedNoteLimit);
      expect(ws.isSyncEnabled('peer-1'), isTrue);
      expect(ws.isSyncEnabled('peer-2'), isTrue);
      expect(ws.isSyncEnabled('peer-3'), isTrue);
      expect(ws.isSyncEnabled('peer-4'), isFalse);
      expect(ws.isSyncEnabled('peer-5'), isFalse);

      // Capped shells still accept the first content snapshot.
      expect(
        ws.receiveRemoteContent(
          docId: 'peer-4',
          title: 'Note 4',
          revision: 2,
          text: 'hello from peer',
          originId: 'bbb',
        ),
        isTrue,
      );
      expect(ws.documentById('peer-4')!.text, 'hello from peer');
      expect(ws.isSyncEnabled('peer-4'), isFalse);

      // Later updates on capped local-only notes are ignored.
      expect(
        ws.receiveRemoteContent(
          docId: 'peer-4',
          title: 'Note 4',
          revision: 3,
          text: 'should not apply',
          originId: 'bbb',
        ),
        isFalse,
      );
      expect(ws.documentById('peer-4')!.text, 'hello from peer');
    });

    test('standard inbound notes are not capped', () async {
      final ws = WorkspaceRepository(
        instanceId: 'aaa',
        storage: await _storage(),
        isStandard: () => true,
      );
      await ws.load();

      ws.mergeCatalog([
        for (var i = 1; i <= 5; i++)
          {'docId': 'peer-$i', 'title': 'Note $i', 'revision': 1},
      ], 'bbb', orderRevision: 1);

      expect(ws.syncedNoteCount, 5);
    });
  });

  group('multi-peer relay targets', () {
    const hubLinks = [
      SyncPeerLink(
        peerId: 'peer-a',
        authenticated: true,
        inboundConnectionId: 'in_a',
      ),
      SyncPeerLink(
        peerId: 'peer-c',
        authenticated: true,
        inboundConnectionId: 'in_c',
        outboundConnectionId: 'out_c',
      ),
    ];

    test('relays from one peer to every other authenticated connection', () {
      final targets = relayConnectionTargets(
        links: hubLinks,
        connectionToPeerId: const {'in_a': 'peer-a', 'in_c': 'peer-c'},
        fromConnectionId: 'in_a',
      );

      expect(targets, ['in_c', 'out_c']);
    });

    test('does not echo back to the sender connection or peer', () {
      final targets = relayConnectionTargets(
        links: hubLinks,
        connectionToPeerId: const {
          'in_a': 'peer-a',
          'in_c': 'peer-c',
          'out_c': 'peer-c',
        },
        fromConnectionId: 'out_c',
      );

      expect(targets, ['in_a']);
      expect(targets, isNot(contains('out_c')));
      expect(targets, isNot(contains('in_c')));
    });

    test('skips unauthenticated links', () {
      final targets = relayConnectionTargets(
        links: const [
          SyncPeerLink(
            peerId: 'peer-a',
            authenticated: true,
            inboundConnectionId: 'in_a',
          ),
          SyncPeerLink(
            peerId: 'peer-pending',
            authenticated: false,
            inboundConnectionId: 'in_pending',
          ),
        ],
        connectionToPeerId: const {
          'in_a': 'peer-a',
          'in_pending': 'peer-pending',
        },
        fromConnectionId: 'in_a',
      );

      expect(targets, isEmpty);
    });
  });

  group('reconnect divergence', () {
    test('noteTextsDiverged requires both sides to be non-empty', () {
      expect(noteTextsDiverged('local', 'remote'), isTrue);
      expect(noteTextsDiverged('', 'remote'), isFalse);
      expect(noteTextsDiverged('local', ''), isFalse);
      expect(noteTextsDiverged('same', 'same'), isFalse);
      expect(noteTextsDiverged('  local  ', 'local'), isTrue);
    });

    test('prompt device is the lexicographically smaller instance id', () {
      expect(
        isReconnectDivergencePromptDevice(
          localInstanceId: 'aaa',
          remoteOriginId: 'bbb',
          localText: 'mine',
          remoteText: 'theirs',
        ),
        isTrue,
      );
      expect(
        isReconnectDivergencePromptDevice(
          localInstanceId: 'bbb',
          remoteOriginId: 'aaa',
          localText: 'mine',
          remoteText: 'theirs',
        ),
        isFalse,
      );
    });

    test('forceApplyRemote converges workspace to peer text on take-theirs', () async {
      final ws = WorkspaceRepository(instanceId: 'aaa', storage: await _storage());
      await ws.load();
      final doc = ws.active!;
      doc.replaceLocal('offline edit');

      doc.forceApplyRemote(revision: 8, text: 'peer version', title: doc.title);

      expect(doc.text, 'peer version');
      expect(doc.revision, 8);
    });

    test('bumpAndBroadcast keeps local text with a higher revision', () async {
      final ws = WorkspaceRepository(instanceId: 'aaa', storage: await _storage());
      await ws.load();
      final doc = ws.active!;
      ws.setSyncEnabled(doc.id, true);
      doc.replaceLocal('keep mine');

      var broadcastRevision = 0;
      ws.onDocUpdate = (_, _, revision, text, originId) {
        broadcastRevision = revision;
        expect(text, 'keep mine');
      };

      doc.bumpAndBroadcast(8);

      expect(doc.revision, 9);
      expect(broadcastRevision, 9);
    });
  });
}
