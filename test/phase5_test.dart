import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart' show TextSelection;
import 'package:netpad/core/constants.dart';
import 'package:netpad/core/models/history_entry.dart';
import 'package:netpad/data/repositories/document_repository.dart';
import 'package:netpad/data/repositories/workspace_repository.dart';
import 'package:netpad/services/note_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<NoteStorageService> _storage() async {
  SharedPreferences.setMockInitialValues({});
  return NoteStorageService(await SharedPreferences.getInstance());
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HistoryEntry', () {
    test('round-trips through JSON', () {
      final entry = HistoryEntry(
        text: 'line one\nline two',
        revision: 7,
        savedAt: DateTime.fromMillisecondsSinceEpoch(1700000000000),
        label: 'Before remote update',
      );
      final decoded = HistoryEntry.fromJson(entry.toJson());
      expect(decoded.text, entry.text);
      expect(decoded.revision, 7);
      expect(decoded.label, 'Before remote update');
      expect(decoded.savedAt, entry.savedAt);
    });

    test('preview uses the first non-empty line', () {
      final entry = HistoryEntry(
        text: '\n\n  hello world  ',
        revision: 1,
        savedAt: DateTime.fromMillisecondsSinceEpoch(0),
        label: 'x',
      );
      expect(entry.preview, 'hello world');
    });
  });

  group('DocumentRepository history', () {
    test('captures the previous text before a remote clobber', () async {
      final storage = await _storage();
      final doc = DocumentRepository(
        instanceId: 'aaa',
        id: 'doc1',
        title: 'Note',
        text: 'original',
        revision: 1,
        storage: storage,
        onLocalEditReady: (_, _, _, _) {},
      );

      final applied = doc.applyRemote(
        revision: 2,
        text: 'replaced',
        originId: 'bbb',
      );

      expect(applied, isTrue);
      expect(doc.text, 'replaced');
      expect(doc.history, isNotEmpty);
      expect(doc.history.first.text, 'original');
    });

    test('restore rebroadcasts the chosen version', () async {
      final storage = await _storage();
      var lastBroadcast = '';
      final doc = DocumentRepository(
        instanceId: 'aaa',
        id: 'doc1',
        title: 'Note',
        text: 'first',
        revision: 1,
        storage: storage,
        onLocalEditReady: (_, _, text, _) => lastBroadcast = text,
      );
      doc.applyRemote(revision: 2, text: 'second', originId: 'bbb');

      final old = doc.history.firstWhere((h) => h.text == 'first');
      doc.restore(old);

      expect(doc.text, 'first');
      expect(lastBroadcast, 'first');
    });

    test('applyRemote applies title only when revision wins', () async {
      final storage = await _storage();
      final doc = DocumentRepository(
        instanceId: 'aaa',
        id: 'doc1',
        title: 'Current',
        text: 'body',
        revision: 5,
        storage: storage,
        onLocalEditReady: (_, _, _, _) {},
      );

      expect(
        doc.applyRemote(
          revision: 3,
          text: 'body',
          originId: 'bbb',
          title: 'Stale',
        ),
        isFalse,
      );
      expect(doc.title, 'Current');

      expect(
        doc.applyRemote(
          revision: 6,
          text: 'new body',
          originId: 'bbb',
          title: 'Updated',
        ),
        isTrue,
      );
      expect(doc.title, 'Updated');
      expect(doc.text, 'new body');
    });

    test('applyDictation updates partial text then commits on final', () async {
      final storage = await _storage();
      final doc = DocumentRepository(
        instanceId: 'aaa',
        id: 'doc1',
        title: 'Note',
        text: 'hello world',
        revision: 1,
        storage: storage,
        onLocalEditReady: (_, _, _, _) {},
      );

      doc.applyDictation(
        anchorOffset: 5,
        previousSpan: '',
        recognizedWords: 'br',
        isFinal: false,
      );
      expect(doc.text, 'hello br world');

      doc.applyDictation(
        anchorOffset: 5,
        previousSpan: ' br',
        recognizedWords: 'brave',
        isFinal: true,
      );
      expect(doc.text, 'hello brave world');
    });

    test('insertAtSelection inserts at the caret', () async {
      final storage = await _storage();
      final doc = DocumentRepository(
        instanceId: 'aaa',
        id: 'doc1',
        title: 'Note',
        text: 'hello world',
        revision: 1,
        storage: storage,
        onLocalEditReady: (_, _, _, _) {},
      );
      doc.controller.selection = const TextSelection.collapsed(offset: 5);

      doc.insertAtSelection('brave');

      expect(doc.text, 'hello brave world');
      expect(doc.controller.selection.baseOffset, 11);
    });

    test('direct controller text change triggers local edit broadcast', () async {
      final storage = await _storage();
      var broadcastText = '';
      final doc = DocumentRepository(
        instanceId: 'aaa',
        id: 'doc1',
        title: 'Note',
        text: 'hello',
        revision: 1,
        storage: storage,
        onLocalEditReady: (_, _, text, _) => broadcastText = text,
      );

      doc.controller.text = 'hello pasted';
      await Future<void>.delayed(kDocDebounce + const Duration(milliseconds: 50));

      expect(broadcastText, 'hello pasted');
    });

    test('remote apply does not trigger local edit broadcast', () async {
      final storage = await _storage();
      var broadcastCount = 0;
      final doc = DocumentRepository(
        instanceId: 'aaa',
        id: 'doc1',
        title: 'Note',
        text: 'hello',
        revision: 1,
        storage: storage,
        onLocalEditReady: (_, _, _, _) => broadcastCount++,
      );

      doc.applyRemote(revision: 2, text: 'from peer', originId: 'bbb');
      await Future<void>.delayed(kDocDebounce + const Duration(milliseconds: 50));

      expect(doc.text, 'from peer');
      expect(broadcastCount, 0);
    });

    test('skips snapshots when note text exceeds per-entry cap', () async {
      final storage = await _storage();
      final large = 'x' * (kMaxHistorySnapshotChars + 1);
      final doc = DocumentRepository(
        instanceId: 'aaa',
        id: 'doc1',
        title: 'Note',
        text: large,
        revision: 1,
        storage: storage,
        onLocalEditReady: (_, _, _, _) {},
      );
      doc.replaceLocal('$large\nedit');
      expect(doc.history, isEmpty);
    });

    test('trims oldest snapshots when total stored chars exceed cap', () async {
      final storage = await _storage();
      final chunk = 'a' * 100000;
      final doc = DocumentRepository(
        instanceId: 'aaa',
        id: 'doc1',
        title: 'Note',
        text: chunk,
        revision: 1,
        storage: storage,
        onLocalEditReady: (_, _, _, _) {},
      );
      for (var i = 0; i < 6; i++) {
        doc.replaceLocal('$chunk$i');
      }
      final totalChars = doc.history.fold<int>(
        0,
        (sum, entry) => sum + entry.text.length,
      );
      expect(totalChars, lessThanOrEqualTo(kMaxHistoryTotalChars));
      expect(doc.history.length, lessThan(6));
    });
  });

  group('WorkspaceRepository', () {
    test('load seeds a single default note', () async {
      final ws = WorkspaceRepository(instanceId: 'aaa', storage: await _storage());
      await ws.load();
      expect(ws.documents, hasLength(1));
      expect(ws.active, isNotNull);
    });

    test('create / rename / delete keeps at least one note', () async {
      final ws = WorkspaceRepository(instanceId: 'aaa', storage: await _storage());
      await ws.load();
      final created = ws.createNote(title: 'Second');
      expect(ws.documents, hasLength(2));
      expect(ws.activeId, created.id);

      ws.renameNote(created.id, 'Renamed');
      expect(ws.documentById(created.id)!.title, 'Renamed');

      for (final doc in [...ws.documents]) {
        ws.deleteNote(doc.id);
      }
      expect(ws.documents, hasLength(1));
    });

    test('ensureDocument creates remote note shells', () async {
      final ws = WorkspaceRepository(instanceId: 'aaa', storage: await _storage());
      await ws.load();
      ws.ensureDocument('remote-1', title: 'From Peer');
      expect(ws.documentById('remote-1'), isNotNull);
      expect(ws.documentById('remote-1')!.title, 'From Peer');

      ws.receiveRemoteRename(
        docId: 'remote-1',
        title: 'Renamed Remotely',
        revision: 2,
        originId: 'bbb',
      );
      expect(ws.documentById('remote-1')!.title, 'Renamed Remotely');
    });

    test('mergeCatalog learns peer notes on connect', () async {
      final ws = WorkspaceRepository(instanceId: 'aaa', storage: await _storage());
      await ws.load();
      ws.mergeCatalog([
        {'docId': 'peer-a', 'title': 'Shopping', 'revision': 3},
        {'docId': 'peer-b', 'title': 'Ideas', 'revision': 1},
      ], 'peer-device', orderRevision: 1);
      expect(ws.hasDocument('peer-a'), isTrue);
      expect(ws.hasDocument('peer-b'), isTrue);
      expect(ws.documentById('peer-a')!.title, 'Shopping');
    });

    test('mergeCatalog persists new peer note shells', () async {
      final storage = await _storage();
      final ws = WorkspaceRepository(instanceId: 'aaa', storage: storage);
      await ws.load();
      ws.mergeCatalog([
        {'docId': 'peer-a', 'title': 'Shopping', 'revision': 3},
      ], 'peer-device', orderRevision: 1);
      await Future<void>.delayed(Duration.zero);

      final reloaded = WorkspaceRepository(instanceId: 'aaa', storage: storage);
      await reloaded.load();
      expect(reloaded.hasDocument('peer-a'), isTrue);
      expect(reloaded.documentById('peer-a')!.title, 'Shopping');
      expect(reloaded.documentById('peer-a')!.revision, 3);
    });

    test('rename broadcasts doc_rename only, not doc_update', () async {
      final ws = WorkspaceRepository(instanceId: 'aaa', storage: await _storage());
      await ws.load();
      final created = ws.createNote(title: 'Second');
      ws.setSyncEnabled(created.id, true);
      var updateCount = 0;
      var renameCount = 0;
      ws.onDocUpdate = (_, _, _, _, _) => updateCount++;
      ws.onDocRename = (_, _, _, _) => renameCount++;

      ws.renameNote(created.id, 'Renamed');

      expect(renameCount, 1);
      expect(updateCount, 0);
      // createNote starts at rev 1; enabling sync bumps once; rename bumps again.
      expect(ws.documentById(created.id)!.revision, 3);
    });

    test('mergeCatalog applies peer note order', () async {
      final ws = WorkspaceRepository(instanceId: 'aaa', storage: await _storage());
      await ws.load();
      final first = ws.documents.first.id;
      ws.mergeCatalog([
        {'docId': 'peer-a', 'title': 'Shopping', 'revision': 1},
        {'docId': first, 'title': 'Note', 'revision': 0},
      ], 'peer-device', orderRevision: 2);
      expect(ws.noteOrder.first, 'peer-a');
      expect(ws.noteOrder.last, first);
    });

    test('reorderNote broadcasts a new order revision', () async {
      final ws = WorkspaceRepository(instanceId: 'aaa', storage: await _storage());
      await ws.load();
      final second = ws.createNote(title: 'Second');
      ws.setSyncEnabled(ws.documents.first.id, true);
      ws.setSyncEnabled(second.id, true);
      List<String>? broadcastOrder;
      var broadcastRevision = 0;
      ws.onOrderChanged = (order, revision, _) {
        broadcastOrder = order;
        broadcastRevision = revision;
      };
      ws.reorderNote(1, 0);
      expect(broadcastOrder, isNotNull);
      expect(broadcastOrder!.first, ws.documents.first.id);
      expect(broadcastRevision, greaterThan(0));
    });

    test('applyRemoteOrder respects orderRevision conflicts', () async {
      final ws = WorkspaceRepository(instanceId: 'aaa', storage: await _storage());
      await ws.load();
      ws.createNote(title: 'B');
      final ids = List<String>.of(ws.noteOrder);
      expect(ws.applyRemoteOrder(ids.reversed.toList(), 5, 'peer'), isTrue);
      expect(ws.noteOrder, ids.reversed);
      expect(ws.applyRemoteOrder(ids, 4, 'peer'), isFalse);
    });

    test('receiveRemoteCreate adds a peer note to the workspace', () async {
      final ws = WorkspaceRepository(instanceId: 'aaa', storage: await _storage());
      await ws.load();
      ws.receiveRemoteCreate(
        docId: 'new-peer-note',
        title: 'Standup',
        revision: 1,
        originId: 'bbb',
      );
      expect(ws.documentById('new-peer-note')!.title, 'Standup');
      expect(ws.documentById('new-peer-note')!.revision, 1);
    });

    test('search matches across note titles and bodies', () async {
      final ws = WorkspaceRepository(instanceId: 'aaa', storage: await _storage());
      await ws.load();
      ws.createNote(title: 'Groceries').replaceLocal('milk eggs bread');
      ws.createNote(title: 'Standup').replaceLocal('discuss milk delivery');
      ws.createNote(title: 'Ideas').replaceLocal('nothing relevant here');

      final hits = ws.search('milk');
      expect(hits, hasLength(2));
      expect(hits.first.matchCount, greaterThanOrEqualTo(1));
    });
  });
}
