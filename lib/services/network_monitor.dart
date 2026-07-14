import 'dart:async';

import 'package:netpad/core/local_network.dart';

/// Polls active LAN subnets and invokes a callback when they change (e.g.
/// Wi‑Fi drop, VPN, switching networks). Discovery/broadcast restart when the
/// set of private subnets changes — not on ephemeral IPv6 / AWDL churn.
class NetworkMonitor {
  NetworkMonitor({this.interval = const Duration(seconds: 5)});

  final Duration interval;
  Timer? _timer;
  String? _lastSignature;

  void start(Future<void> Function() onChange) {
    _timer?.cancel();
    unawaited(_prime());
    _timer = Timer.periodic(interval, (_) async {
      final signature = await _signature();
      if (_lastSignature != null && signature != _lastSignature) {
        _lastSignature = signature;
        await onChange();
      } else {
        _lastSignature = signature;
      }
    });
  }

  Future<void> _prime() async {
    _lastSignature = await _signature();
  }

  /// Stable signature of [LocalNetwork.activeSubnets] (IPv4/ULA segments that
  /// discovery uses). Ignores temporary interface address noise.
  Future<String> _signature() async {
    try {
      await LocalNetwork.refreshActiveSubnets();
      final parts = LocalNetwork.activeSubnets
          .map((s) => '${s.base.address}/${s.prefixLength}')
          .toList()
        ..sort();
      return parts.join(',');
    } catch (_) {
      return '';
    }
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }
}
