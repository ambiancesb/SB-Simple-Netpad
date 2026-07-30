import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:netpad/data/repositories/discovery_repository.dart';
import 'package:netpad/features/peers/qr_show_dialog.dart';
import 'package:netpad/l10n/l10n_ext.dart';
import 'package:netpad/services/local_address_service.dart';
import 'package:netpad/theme/app_spacing.dart';
import 'package:provider/provider.dart';

class ThisDeviceBanner extends StatefulWidget {
  const ThisDeviceBanner({super.key, required this.port});

  final int? port;

  @override
  State<ThisDeviceBanner> createState() => _ThisDeviceBannerState();
}

class _ThisDeviceBannerState extends State<ThisDeviceBanner> {
  String? _lanIp;
  int? _lastRefreshKey;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant ThisDeviceBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.port != widget.port) {
      unawaited(_load());
    }
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.discoveryCopiedAddress(text))),
      );
    }
  }

  Future<void> _showQr(BuildContext context) async {
    final port = widget.port;
    final host = _lanIp;
    if (host == null || port == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.qrShowNotReady)),
      );
      return;
    }
    final discovery = context.read<DiscoveryRepository>();
    await showQrConnectDialog(
      context,
      host: host,
      port: port,
      displayName: discovery.displayName,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final discovery = context.watch<DiscoveryRepository>();
    final refreshKey = Object.hash(
      widget.port,
      discovery.canDiscoverPeers,
      discovery.networkingError,
      discovery.networkingPolicyNote,
    );
    if (_lastRefreshKey != refreshKey) {
      _lastRefreshKey = refreshKey;
      unawaited(_load());
    }

    final port = widget.port;
    final ready = _lanIp != null && port != null;
    final address = ready ? '$_lanIp:$port' : '…';

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Material(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: AppRadii.smAll,
        child: ListTile(
          dense: true,
          leading: const Icon(Icons.computer, size: 20),
          title: Text(l10n.discoveryThisDevice),
          subtitle: Text(address),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.qr_code_2, size: 20),
                tooltip: l10n.peersShowQrTooltip,
                onPressed: ready ? () => _showQr(context) : null,
              ),
              IconButton(
                icon: const Icon(Icons.copy, size: 20),
                tooltip: l10n.discoveryCopyAddress,
                onPressed: ready ? () => _copy(context) : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
