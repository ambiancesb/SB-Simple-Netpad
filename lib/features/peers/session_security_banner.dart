import 'package:flutter/material.dart';
import 'package:netpad/data/repositories/discovery_repository.dart';
import 'package:netpad/data/repositories/trust_store.dart';
import 'package:netpad/l10n/l10n_ext.dart';
import 'package:netpad/services/tls_identity.dart';
import 'package:netpad/theme/app_spacing.dart';
import 'package:provider/provider.dart';

/// Shared security counts and labels for peers UI chrome and banners.
class SessionSecuritySummary {
  const SessionSecuritySummary({
    required this.connectedCount,
    required this.pinnedCount,
    required this.localCode,
    required this.bannerSubtitle,
    required this.compactLabel,
  });

  final int connectedCount;
  final int pinnedCount;
  final String localCode;

  /// Full subtitle shown in [SessionSecurityBanner].
  final String bannerSubtitle;

  /// Compact one-line label shown in the desktop panel header.
  final String compactLabel;

  factory SessionSecuritySummary.of(BuildContext context) {
    final tls = context.read<TlsIdentity>();
    final trust = context.watch<TrustStore>();
    final discovery = context.watch<DiscoveryRepository>();
    final l10n = context.l10n;

    final connected = discovery.connectedPeers
        .where((p) => !trust.isBlocked(p.id))
        .toList();
    final pinnedCount = connected.where((p) => trust.hasPin(p.id)).length;
    final localCode = shortFingerprint(tls.fingerprint);
    final connectedCount = connected.length;

    return SessionSecuritySummary(
      connectedCount: connectedCount,
      pinnedCount: pinnedCount,
      localCode: localCode,
      bannerSubtitle: connectedCount == 0
          ? l10n.peersSecurityBannerIdle(localCode)
          : l10n.peersSecurityBannerActive(connectedCount, pinnedCount),
      compactLabel: connectedCount == 0
          ? l10n.peersSecurityCompactIdle(localCode)
          : l10n.peersSecurityCompactActive(connectedCount, pinnedCount),
    );
  }
}

/// Summarises transport security for this device and any connected peers.
class SessionSecurityBanner extends StatelessWidget {
  const SessionSecurityBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final security = SessionSecuritySummary.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Material(
        color: Theme.of(context).colorScheme.primaryContainer.withValues(
          alpha: 0.45,
        ),
        borderRadius: AppRadii.smAll,
        child: ListTile(
          dense: true,
          leading: Icon(
            Icons.lock,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
          title: Text(context.l10n.peersSecuredSessions),
          subtitle: Text(security.bannerSubtitle),
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
    final l10n = context.l10n;
    final trust = context.watch<TrustStore>();
    final pinned = trust.hasPin(peerId);
    final fingerprint = trust.pinnedFingerprint(peerId);

    return Tooltip(
      message: pinned
          ? l10n.peersSecurityTooltipPinned(shortFingerprint(fingerprint!))
          : l10n.peersSecurityTooltipActive,
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
