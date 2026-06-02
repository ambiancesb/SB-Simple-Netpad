import 'package:flutter_test/flutter_test.dart';
import 'package:netpad/data/repositories/connection_log_repository.dart';
import 'package:netpad/services/pairing_verification_code.dart';

void main() {
  test('pairing verification code is symmetric and stable', () {
    final first = PairingVerificationCode.generate('device-a', 'device-b');
    final second = PairingVerificationCode.generate('device-b', 'device-a');

    expect(first, second);
    expect(first, matches(RegExp(r'^\d{3}-\d{3}$')));
  });

  test('connection log caps entries and clears', () {
    final log = ConnectionLogRepository(maxEntries: 2);

    log.add('first');
    log.add('second');
    log.add('third', revision: 3);

    expect(log.entries, hasLength(2));
    expect(log.entries.first.message, 'third');
    expect(log.entries.first.revision, 3);
    expect(log.entries.last.message, 'second');

    log.clear();

    expect(log.entries, isEmpty);
  });
}
