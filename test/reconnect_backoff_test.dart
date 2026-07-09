import 'package:flutter_test/flutter_test.dart';
import 'package:netpad/core/reconnect_backoff.dart';

void main() {
  group('reconnectBackoffDuration', () {
    test('uses longer backoff for already-connected races', () {
      expect(
        reconnectBackoffDuration(
          failureCount: 1,
          connectionRefused: false,
          alreadyConnected: true,
        ),
        const Duration(seconds: 30),
      );
    });

    test('uses refused backoff for connection refused', () {
      expect(
        reconnectBackoffDuration(
          failureCount: 1,
          connectionRefused: true,
          alreadyConnected: false,
        ),
        const Duration(seconds: 20),
      );
    });

    test('escalates generic failures up to 30 seconds', () {
      expect(
        reconnectBackoffDuration(
          failureCount: 1,
          connectionRefused: false,
          alreadyConnected: false,
        ),
        const Duration(seconds: 5),
      );
      expect(
        reconnectBackoffDuration(
          failureCount: 2,
          connectionRefused: false,
          alreadyConnected: false,
        ),
        const Duration(seconds: 10),
      );
      expect(
        reconnectBackoffDuration(
          failureCount: 4,
          connectionRefused: false,
          alreadyConnected: false,
        ),
        const Duration(seconds: 30),
      );
      expect(
        reconnectBackoffDuration(
          failureCount: 99,
          connectionRefused: false,
          alreadyConnected: false,
        ),
        const Duration(seconds: 30),
      );
    });
  });
}
