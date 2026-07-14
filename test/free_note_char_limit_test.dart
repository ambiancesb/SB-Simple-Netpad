import 'package:flutter_test/flutter_test.dart';
import 'package:netpad/core/constants.dart';
import 'package:netpad/data/repositories/document_repository.dart';
import 'package:netpad/services/entitlements/entitlement_constants.dart';
import 'package:netpad/services/note_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<NoteStorageService> _storage() async {
  SharedPreferences.setMockInitialValues({});
  return NoteStorageService(await SharedPreferences.getInstance());
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('free note character limit', () {
    test('clamps local edits past freeNoteCharLimit', () async {
      final storage = await _storage();
      final doc = DocumentRepository(
        instanceId: 'inst',
        id: 'doc-1',
        title: 'Note',
        revision: 0,
        text: '',
        storage: storage,
        onLocalEditReady: (_, __, ___, ____) {},
        maxCharacters: () => EntitlementConstants.freeNoteCharLimit,
      );

      final over = 'a' * (EntitlementConstants.freeNoteCharLimit + 25);
      doc.controller.text = over;
      // Listener clamps synchronously on controller change.
      expect(doc.text.length, EntitlementConstants.freeNoteCharLimit);
      doc.dispose();
    });

    test('standard (null limit) allows longer notes', () async {
      final storage = await _storage();
      final doc = DocumentRepository(
        instanceId: 'inst',
        id: 'doc-1',
        title: 'Note',
        revision: 0,
        text: '',
        storage: storage,
        onLocalEditReady: (_, __, ___, ____) {},
        maxCharacters: () => null,
      );

      final over = 'a' * (EntitlementConstants.freeNoteCharLimit + 25);
      doc.controller.text = over;
      expect(doc.text.length, over.length);
      doc.dispose();
    });

    test('replaceLocal truncates to free limit', () async {
      final storage = await _storage();
      final doc = DocumentRepository(
        instanceId: 'inst',
        id: 'doc-1',
        title: 'Note',
        revision: 0,
        text: '',
        storage: storage,
        onLocalEditReady: (_, __, ___, ____) {},
        maxCharacters: () => EntitlementConstants.freeNoteCharLimit,
      );

      doc.replaceLocal('x' * 600);
      expect(doc.text.length, EntitlementConstants.freeNoteCharLimit);
      doc.dispose();
    });

    test('kDocDebounce is unchanged', () {
      expect(kDocDebounce, const Duration(milliseconds: 300));
    });
  });
}
