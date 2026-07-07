import 'dart:io';

import 'package:flutter/services.dart';
import 'package:netpad/data/repositories/discovery_repository.dart';

/// Android-specific hooks: multicast lock and permission-change retries.
class AndroidNetworking {
  AndroidNetworking._();

  static const _channel = MethodChannel('com.sb.netpad/networking');

  static Future<void> initialize(DiscoveryRepository discovery) async {
    if (!Platform.isAndroid) return;

    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'permissionsChanged':
          await discovery.retryNetworking();
        case 'networkChanged':
          discovery.scheduleRetryNetworking();
      }
    });

    await acquireMulticastLock();
  }

  static Future<void> acquireMulticastLock() async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod<void>('acquireMulticastLock');
    } catch (_) {
      // Native hook is best-effort.
    }
  }

  /// True when Wi‑Fi or Ethernet is up, even if mobile data is the default route.
  static Future<bool> hasLanTransport() async {
    if (!Platform.isAndroid) return false;
    try {
      final value = await _channel.invokeMethod<bool>('hasLanTransport');
      return value ?? false;
    } catch (_) {
      return false;
    }
  }
}
