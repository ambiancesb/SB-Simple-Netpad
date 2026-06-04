import 'package:flutter_test/flutter_test.dart';
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
  });
}
