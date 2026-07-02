import 'package:flutter/material.dart';
import 'package:netpad/data/repositories/discovery_repository.dart';
import 'package:netpad/data/repositories/trust_store.dart';
import 'package:netpad/services/tls_identity.dart';
import 'package:provider/provider.dart';

/// Shared security counts and labels for peers UI chrome and banners.
class SessionSecuritySummary {
  const SessionSecuritySummary({
    required this.connectedCount,
    required this.pinnedCount,
    required this.localCode,
  });

  final int connectedCount;
  final int pinnedCount;
  final String localCode;

  factory SessionSecuritySummary.of(BuildContext context) {
    final tls = context.read<TlsIdentity>();
    final trust = context.watch<TrustStore>();
    final discovery = context.watch<DiscoveryRepository>();
    final connected = discovery.connectedPeers
        .where((p) => !trust.isBlocked(p.id))
        .toList();
    final pinnedCount = connected.where((p) => trust.hasPin(p.id)).length;
    return SessionSecuritySummary(
      connectedCount: connected.length,
      pinnedCount: pinnedCount,
      localCode: shortFingerprint(tls.fingerprint),
    );
  }

  String get bannerSubtitle => connectedCount == 0
      ? 'This device advertises over WSS/TLS · code $localCode'
      : '$connectedCount encrypted session(s) · '
            '$pinnedCount certificate${pinnedCount == 1 ? '' : 's'} pinned';

  String get compactLabel => connectedCount == 0
      ? 'WSS/TLS · code $localCode'
      : '$connectedCount encrypted · $pinnedCount pinned';
}

/// Summarises transport security for this device and any connected peers.
class SessionSecurityBanner extends StatelessWidget {
  const SessionSecurityBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final security = SessionSecuritySummary.of(context);
    final subtitle = security.bannerSubtitle;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Material(
        color: Theme.of(context).colorScheme.primaryContainer.withValues(
          alpha: 0.45,
        ),
        borderRadius: BorderRadius.circular(8),
        child: ListTile(
          dense: true,
          leading: Icon(
            Icons.lock,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
          title: const Text('Secured sessions'),
          subtitle: Text(subtitle),
        ),
      ),
    );
  }
}

/// Per-peer lock showing encrypted transport and whether the cert is pinned.
class PeerSecurityIcon extends StatelessWidget {
  const PeerSecurityIcon({super.key, required this.peerId});

  final String peerId;

  @override
  Widget build(BuildContext context) {
    final trust = context.watch<TrustStore>();
    final pinned = trust.hasPin(peerId);
    final fingerprint = trust.pinnedFingerprint(peerId);

    return Tooltip(
      message: pinned
          ? 'Encrypted (WSS/TLS) · pinned ${shortFingerprint(fingerprint!)}'
          : 'Encrypted (WSS/TLS) · active session',
      child: Icon(
        pinned ? Icons.lock : Icons.lock_outline,
        size: 18,
        color: pinned
            ? Colors.green.shade700
            : Theme.of(context).colorScheme.outline,
      ),
    );
  }
}
