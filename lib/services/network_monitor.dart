import 'dart:async';
import 'dart:io';

/// Polls the list of network interfaces and invokes a callback when the set of
/// addresses changes (e.g. Wi-Fi drop, VPN, switching networks). This lets
/// discovery/broadcast restart on real interface changes instead of only on a
/// fixed timer.
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

  Future<String> _signature() async {
    try {
      final interfaces = await NetworkInterface.list(
        includeLoopback: false,
        type: InternetAddressType.any,
      );
      final addresses = <String>[];
      for (final interface in interfaces) {
        for (final address in interface.addresses) {
          addresses.add('${interface.name}|${address.address}');
        }
      }
      addresses.sort();
      return addresses.join(',');
    } catch (_) {
      return '';
    }
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }
}
