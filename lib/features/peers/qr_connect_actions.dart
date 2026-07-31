import 'package:flutter/material.dart';
import 'package:netpad/data/repositories/discovery_repository.dart';
import 'package:netpad/features/peers/qr_show_dialog.dart';
import 'package:netpad/l10n/l10n_ext.dart';
import 'package:netpad/services/local_address_service.dart';
import 'package:provider/provider.dart';

/// Resolves this device's LAN endpoint and shows the connect QR dialog.
Future<void> showThisDeviceQrCode(BuildContext context) async {
  final discovery = context.read<DiscoveryRepository>();
  final l10n = context.l10n;
  final messenger = ScaffoldMessenger.maybeOf(context);
  final scaffold = Scaffold.maybeOf(context);
  final rootNav = Navigator.of(context, rootNavigator: true);
  final displayName = discovery.displayName;
  final port = discovery.serverPort;

  final host = await LocalAddressService.getLanIpv4();
  if (host == null || port == null) {
    messenger?.showSnackBar(
      SnackBar(content: Text(l10n.qrShowNotReady)),
    );
    return;
  }

  // Avoid showing from the endDrawer route (content can end up behind the
  // drawer scrim). Close the drawer, then present on the root navigator.
  scaffold?.closeEndDrawer();

  if (!rootNav.mounted) return;
  await showQrConnectDialog(
    rootNav.context,
    host: host,
    port: port,
    displayName: displayName,
  );
}
