import 'dart:io';

import 'package:flutter/services.dart';
import 'package:netpad/core/local_network.dart';
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

  /// Best-effort Wi‑Fi/Ethernet IPv4 from Android link properties.
  static Future<String?> getLanIpv4() async {
    if (!Platform.isAndroid) return null;
    try {
      final value = await _channel.invokeMethod<String>('getLanIpv4');
      if (value == null || value.isEmpty) return null;
      return value;
    } catch (_) {
      return null;
    }
  }
}
