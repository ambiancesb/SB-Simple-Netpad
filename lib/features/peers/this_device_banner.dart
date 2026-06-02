import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:netpad/services/local_address_service.dart';

/// Shows this device's LAN address and listening port for manual sharing.
class ThisDeviceBanner extends StatefulWidget {
  const ThisDeviceBanner({super.key, required this.port});

  final int? port;

  @override
  State<ThisDeviceBanner> createState() => _ThisDeviceBannerState();
}

class _ThisDeviceBannerState extends State<ThisDeviceBanner> {
  String? _lanIp;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final ip = await LocalAddressService.getLanIpv4();
    if (mounted) setState(() => _lanIp = ip);
  }

  Future<void> _copy(BuildContext context) async {
    final port = widget.port;
    if (_lanIp == null || port == null) return;
    final text = '$_lanIp:$port';
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Copied $text')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final port = widget.port;
    final address = _lanIp != null && port != null ? '$_lanIp:$port' : '…';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Material(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        child: ListTile(
          dense: true,
          leading: const Icon(Icons.computer, size: 20),
          title: const Text('This device'),
          subtitle: Text(address),
          trailing: IconButton(
            icon: const Icon(Icons.copy, size: 20),
            tooltip: 'Copy address',
            onPressed: port == null ? null : () => _copy(context),
          ),
        ),
      ),
    );
  }
}
