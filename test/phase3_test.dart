import 'package:flutter_test/flutter_test.dart';
<<<<<<< Updated upstream
import 'package:netpad/data/repositories/document_repository.dart';
import 'package:netpad/services/note_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loadExternalText replaces text, bumps revision, broadcasts local edit', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final storage = NoteStorageService(prefs);

    int? broadcastRevision;
    String? broadcastText;
    String? broadcastOrigin;
    final repo = DocumentRepository(
      instanceId: 'instance-A',
      storage: storage,
      onLocalEditReady: (rev, text, origin) {
        broadcastRevision = rev;
        broadcastText = text;
        broadcastOrigin = origin;
      },
    );

    final before = repo.revision;
    repo.loadExternalText('hello from file');

    expect(repo.revision, before + 1);
    expect(repo.text, 'hello from file');
    expect(broadcastRevision, repo.revision);
    expect(broadcastText, 'hello from file');
    expect(broadcastOrigin, 'instance-A');

    repo.dispose();
=======
import 'package:netpad/core/models/peer_presence.dart';
import 'package:netpad/services/text_position.dart';

void main() {
  group('lineColumnForOffset', () {
    test('start of document is line 1, column 1', () {
      expect(lineColumnForOffset('hello', 0), (line: 1, column: 1));
    });

    test('counts columns on a single line', () {
      expect(lineColumnForOffset('hello', 3), (line: 1, column: 4));
    });

    test('advances line after newline', () {
      const text = 'ab\ncd';
      expect(lineColumnForOffset(text, 3), (line: 2, column: 1));
      expect(lineColumnForOffset(text, 5), (line: 2, column: 3));
    });

    test('clamps out-of-range offsets', () {
      expect(lineColumnForOffset('ab', 99), (line: 1, column: 3));
      expect(lineColumnForOffset('ab', -5), (line: 1, column: 1));
    });
  });

  test('PeerPresence label is human readable', () {
    final presence = PeerPresence(
      line: 4,
      column: 2,
      updatedAt: DateTime(2026),
    );
    expect(presence.label, 'line 4, col 2');
>>>>>>> Stashed changes
  });
}
