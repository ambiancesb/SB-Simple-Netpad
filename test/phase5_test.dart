import 'package:flutter_test/flutter_test.dart';
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

    test('ensureDocument creates remote notes and updates titles', () async {
      final ws = WorkspaceRepository(instanceId: 'aaa', storage: await _storage());
      await ws.load();
      ws.ensureDocument('remote-1', 'From Peer');
      expect(ws.documentById('remote-1'), isNotNull);
      expect(ws.documentById('remote-1')!.title, 'From Peer');

      ws.ensureDocument('remote-1', 'Renamed Remotely');
      expect(ws.documentById('remote-1')!.title, 'Renamed Remotely');
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
