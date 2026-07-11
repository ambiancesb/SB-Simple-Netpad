import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:netpad/core/models/peer.dart';
import 'package:netpad/core/models/peer_presence.dart';
import 'package:netpad/core/models/trusted_peer.dart';
import 'package:netpad/data/repositories/connection_log_repository.dart';
import 'package:netpad/data/repositories/discovery_repository.dart';
import 'package:netpad/data/repositories/pairing_repository.dart';
import 'package:netpad/data/repositories/sync_repository.dart';
import 'package:netpad/data/repositories/trust_store.dart';
import 'package:netpad/features/entitlements/pro_gate.dart';
import 'package:netpad/features/peers/manual_connect_dialog.dart';
import 'package:netpad/features/peers/session_security_banner.dart';
import 'package:netpad/features/peers/this_device_banner.dart';
import 'package:netpad/services/entitlements/entitlement_service.dart';
import 'package:netpad/services/tls_identity.dart';
import 'package:provider/provider.dart';

class PeersPanel extends StatelessWidget {
  const PeersPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final discovery = context.watch<DiscoveryRepository>();
    final connectionLog = context.watch<ConnectionLogRepository>();
    final sync = context.watch<SyncRepository>();
    final trust = context.watch<TrustStore>();
    final pairing = context.watch<PairingRepository>();

    final connected = discovery.connectedPeers
        .where((p) => !trust.isBlocked(p.id))
        .toList();
    final nearby = discovery.discoveredPeers
        .where(
          (p) =>
              p.connectionState != PeerConnectionState.connected &&
              !trust.isBlocked(p.id),
        )
        .toList();

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        ThisDeviceBanner(port: discovery.serverPort),
        if (discovery.networkingError != null)
          _NetworkingErrorBanner(
            message: discovery.networkingError!,
            onRetry: () => discovery.retryNetworking(),
          ),
        if (discovery.networkingPolicyNote != null)
          _NetworkingInfoBanner(
            message: discovery.networkingPolicyNote!,
            icon: Icons.signal_cellular_alt,
            title: 'Local network required',
          )
        else if (discovery.serverPort == null)
          _NetworkingInfoBanner(
            message:
                'This device is not listening for peers yet. Wait a few seconds '
                'after joining Wi‑Fi, or tap Retry on a networking error banner.',
            icon: Icons.cloud_off,
            title: 'Not listening',
          ),
        if (discovery.networkingNote != null)
          _NetworkingInfoBanner(message: discovery.networkingNote!),
        const SessionSecurityBanner(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: OutlinedButton.icon(
            onPressed: discovery.canDiscoverPeers
                ? () => _manualConnect(context)
                : null,
            icon: const Icon(Icons.add_link),
            label: const Text('Connect by IP'),
          ),
        ),
        _sectionHeader(context, 'Connected'),
        if (connected.isEmpty) const _EmptyHint('No active connections'),
        ...connected.map(
          (peer) => _PeerRow(
            peer: peer,
            presence: sync.presence[peer.id],
            actions: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                PeerSecurityIcon(peerId: peer.id),
                IconButton(
                  icon: const Icon(Icons.link_off, size: 20),
                  tooltip: 'Disconnect',
                  onPressed: () => pairing.disconnectPeer(peer.id),
                ),
                _BlockButton(peer: peer),
              ],
            ),
          ),
        ),
        const Divider(height: 24),
        _TrustedSection(
          trusted: trust.trustedPeers,
          discovery: discovery,
          pairing: pairing,
        ),
        const Divider(height: 24),
        _sectionHeader(context, 'Nearby'),
        if (nearby.isEmpty)
          _EmptyHint(
            discovery.canDiscoverPeers
                ? 'No discovered peers — Linux must be on the same Wi‑Fi subnet '
                  'as This device (check the address above), or use Connect by IP'
                : 'Peer discovery is paused until you join a local network',
          ),
        ...nearby.map(
          (peer) => _PeerRow(
            peer: peer,
            actions: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (trust.canAutoSync(peer.id)) ...[
                  if (!pairing.isReconnectInFlight(peer.id))
                    TextButton(
                      onPressed: () => _connect(context, peer),
                      child: const Text('Connect now'),
                    ),
                ] else
                  _ConnectButton(
                    peer: peer,
                    onConnect: () => _connect(context, peer),
                  ),
                _BlockButton(peer: peer),
              ],
            ),
            status: trust.canAutoSync(peer.id)
                ? pairing.trustedReconnectStatus(
                    peerId: peer.id,
                    connected: false,
                    autoSyncEnabled: true,
                  )
                : null,
          ),
        ),
        const Divider(height: 24),
        _BlockedSection(blocked: trust.blocked),
        const Divider(height: 24),
        _ConnectionLogSection(connectionLog: connectionLog),
      ],
    );
  }

  Widget _sectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }

  Future<void> _manualConnect(BuildContext context) async {
    final result = await showManualConnectDialog(context);
    if (result == null || !context.mounted) return;

    final discovery = context.read<DiscoveryRepository>();
    final peer = discovery.registerManualPeer(
      host: result.host,
      port: result.port,
      displayName: result.displayName,
    );
    await _connect(context, peer);
  }

  Future<void> _connect(BuildContext context, Peer peer) async {
    if (!peer.isManual &&
        !peer.isConnectable &&
        peer.resolveState != PeerResolveState.failed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Still resolving ${peer.displayName}…')),
      );
      return;
    }
    if (!peer.isManual && peer.resolveState == PeerResolveState.failed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not resolve ${peer.displayName}. Check Avahi and same subnet, or use Connect by IP.',
          ),
        ),
      );
      return;
    }

    final sync = context.read<SyncRepository>();
    final allowed = await ProGate.connectPeerAllowed(
      context,
      currentConnectedCount: sync.authenticatedPeerCount,
    );
    if (!allowed || !context.mounted) return;

    final pairing = context.read<PairingRepository>();
    try {
      await pairing.requestConnection(peer);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pairing request sent to ${peer.displayName}'),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        final message = e is StateError ? e.message : e.toString();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not connect: $message')));
      }
    }
  }
}

class _ConnectButton extends StatelessWidget {
  const _ConnectButton({required this.peer, required this.onConnect});

  final Peer peer;
  final VoidCallback onConnect;

  @override
  Widget build(BuildContext context) {
    final connecting =
        peer.connectionState == PeerConnectionState.connecting ||
        peer.connectionState == PeerConnectionState.pendingOutgoing;
    final resolving =
        !peer.isManual && peer.resolveState == PeerResolveState.resolving;

    return FilledButton.tonal(
      onPressed: (connecting || resolving) ? null : onConnect,
      child: Text(
        connecting
            ? '…'
            : resolving
            ? 'Resolving…'
            : 'Connect',
      ),
    );
  }
}

String _peerSubtitle(Peer peer) {
  if (peer.isManual) {
    final host = peer.primaryHost;
    return host != null ? '$host:${peer.port} (manual)' : 'Manual';
  }
  if (peer.resolveState == PeerResolveState.failed) {
    return 'Resolve failed — try Connect by IP';
  }
  if (peer.resolveState == PeerResolveState.resolving) {
    return 'Resolving address…';
  }
  final host = peer.primaryHost;
  if (host != null) {
    return '$host:${peer.port}';
  }
  return 'No address yet';
}

String _formatPairedAt(DateTime pairedAt) {
  final local = pairedAt.toLocal();
  final y = local.year;
  final m = local.month.toString().padLeft(2, '0');
  final d = local.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

class _PeerRow extends StatelessWidget {
  const _PeerRow({
    required this.peer,
    required this.actions,
    this.presence,
    this.status,
  });

  final Peer peer;
  final Widget actions;
  final PeerPresence? presence;
  final String? status;

  @override
  Widget build(BuildContext context) {
    final color = switch (peer.connectionState) {
      PeerConnectionState.connected => Colors.green,
      PeerConnectionState.connecting => Colors.orange,
      _ => peer.isManual ? Colors.blue : Colors.grey,
    };

    final subtitle = presence == null
        ? _peerSubtitle(peer)
        : '${_peerSubtitle(peer)} • ${presence!.label}';
    final trust = context.watch<TrustStore>();
    final pinned = trust.hasPin(peer.id);
    final securityLabel = peer.connectionState == PeerConnectionState.connected
        ? pinned
              ? 'Encrypted · pinned ${shortFingerprint(trust.pinnedFingerprint(peer.id)!)}'
              : 'Encrypted (WSS/TLS)'
        : null;
    final fullSubtitle = securityLabel == null
        ? subtitle
        : '$subtitle • $securityLabel';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 8, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Icon(Icons.circle, size: 10, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(peer.displayName),
                    Text(
                      fullSubtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (status != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        status!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Align(alignment: Alignment.centerRight, child: actions),
        ],
      ),
    );
  }
}

class _TrustedDeviceRow extends StatelessWidget {
  const _TrustedDeviceRow({
    required this.displayName,
    required this.subtitle,
    required this.autoSyncEnabled,
    required this.onAutoSyncChanged,
    required this.onRevoke,
  });

  final String displayName;
  final String subtitle;
  final bool autoSyncEnabled;
  final ValueChanged<bool> onAutoSyncChanged;
  final VoidCallback onRevoke;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 8, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                autoSyncEnabled ? Icons.sync : Icons.sync_disabled,
                size: 20,
                color: autoSyncEnabled
                    ? colorScheme.primary
                    : colorScheme.outline,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(displayName),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('Auto-sync', style: Theme.of(context).textTheme.bodySmall),
              Switch(
                value: autoSyncEnabled,
                onChanged: onAutoSyncChanged,
              ),
              TextButton(onPressed: onRevoke, child: const Text('Revoke')),
            ],
          ),
        ],
      ),
    );
  }
}

class _BlockButton extends StatelessWidget {
  const _BlockButton({required this.peer});

  final Peer peer;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.block, size: 20),
      tooltip: 'Block',
      onPressed: () async {
        final pairing = context.read<PairingRepository>();
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('Block ${peer.displayName}?'),
            content: const Text(
              'This disconnects the device, forgets its pinned certificate, and '
              'refuses future connection requests until you unblock it.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Block'),
              ),
            ],
          ),
        );
        if (confirmed == true) {
          await pairing.blockPeer(peer.id, peer.displayName);
        }
      },
    );
  }
}

class _TrustedSection extends StatelessWidget {
  const _TrustedSection({
    required this.trusted,
    required this.discovery,
    required this.pairing,
  });

  final Map<String, TrustedPeer> trusted;
  final DiscoveryRepository discovery;
  final PairingRepository pairing;

  @override
  Widget build(BuildContext context) {
    final entitlements = context.watch<EntitlementService>();
    final entries = trusted.entries.toList()
      ..sort((a, b) => a.value.displayName.compareTo(b.value.displayName));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Text(
            'Trusted devices',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        if (entries.isEmpty)
          const _EmptyHint('No trusted devices — pair once to enable auto-sync'),
        ...entries.map((entry) {
          final peerId = entry.key;
          final record = entry.value;
          final livePeer = discovery.peerById(peerId);
          final connected =
              livePeer?.connectionState == PeerConnectionState.connected;
          final autoSyncOn =
              entitlements.isPro && record.autoSyncEnabled;
          final status = pairing.trustedReconnectStatus(
            peerId: peerId,
            connected: connected,
            autoSyncEnabled: record.autoSyncEnabled,
          );
          final subtitle = 'Paired ${_formatPairedAt(record.pairedAt)} · $status';

          return _TrustedDeviceRow(
            displayName: record.displayName,
            subtitle: subtitle,
            autoSyncEnabled: autoSyncOn,
            onAutoSyncChanged: (enabled) async {
              if (enabled) {
                final allowed = await ProGate.trustedAutoSyncAllowed(context);
                if (!allowed || !context.mounted) return;
              }
              await pairing.setPeerAutoSyncEnabled(peerId, enabled);
            },
            onRevoke: () => _confirmRevoke(context, pairing, peerId, record),
          );
        }),
      ],
    );
  }

  Future<void> _confirmRevoke(
    BuildContext context,
    PairingRepository pairing,
    String peerId,
    TrustedPeer record,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Revoke ${record.displayName}?'),
        content: const Text(
          'The next connection will require tapping Accept again. '
          'The security pin is kept so certificate checks still apply.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Revoke'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await pairing.revokeTrustedPeer(peerId);
    }
  }
}

class _BlockedSection extends StatelessWidget {
  const _BlockedSection({required this.blocked});

  final Map<String, String> blocked;

  @override
  Widget build(BuildContext context) {
    final pairing = context.read<PairingRepository>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Text(
            'Blocked',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        if (blocked.isEmpty) const _EmptyHint('No blocked devices'),
        ...blocked.entries.map(
          (entry) => ListTile(
            dense: true,
            leading: const Icon(Icons.block, size: 18, color: Colors.red),
            title: Text(entry.value),
            trailing: TextButton(
              onPressed: () => pairing.unblockPeer(entry.key),
              child: const Text('Unblock'),
            ),
          ),
        ),
      ],
    );
  }
}

class _NetworkingInfoBanner extends StatelessWidget {
  const _NetworkingInfoBanner({
    required this.message,
    this.icon = Icons.info_outline,
    this.title = 'Discovery mode',
  });

  final String message;
  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Material(
        color: Theme.of(context).colorScheme.secondaryContainer.withValues(
          alpha: 0.45,
        ),
        borderRadius: BorderRadius.circular(8),
        child: ListTile(
          dense: true,
          leading: Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.secondary,
          ),
          title: Text(title),
          subtitle: Text(message),
        ),
      ),
    );
  }
}

class _NetworkingErrorBanner extends StatelessWidget {
  const _NetworkingErrorBanner({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Material(
        color: Theme.of(context).colorScheme.errorContainer.withValues(
          alpha: 0.55,
        ),
        borderRadius: BorderRadius.circular(8),
        child: ListTile(
          dense: true,
          leading: Icon(
            Icons.wifi_off,
            size: 20,
            color: Theme.of(context).colorScheme.error,
          ),
          title: const Text('Peer discovery unavailable'),
          subtitle: Text(message),
          trailing: IconButton(
            icon: const Icon(Icons.refresh, size: 20),
            tooltip: 'Retry discovery',
            onPressed: onRetry,
          ),
        ),
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.outline,
        ),
      ),
    );
  }
}

class _ConnectionLogSection extends StatelessWidget {
  const _ConnectionLogSection({required this.connectionLog});

  final ConnectionLogRepository connectionLog;

  @override
  Widget build(BuildContext context) {
    final entries = connectionLog.entries;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 8, 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Connection log',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              TextButton(
                onPressed: entries.isEmpty ? null : () => _copyLog(context),
                child: const Text('Copy'),
              ),
              TextButton(
                onPressed: entries.isEmpty ? null : connectionLog.clear,
                child: const Text('Clear'),
              ),
            ],
          ),
        ),
        if (entries.isEmpty) const _EmptyHint('No connection events yet'),
        if (entries.isNotEmpty)
          SelectionArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: entries
                  .take(8)
                  .map(
                    (entry) => ListTile(
                      dense: true,
                      visualDensity: VisualDensity.compact,
                      title: Text(entry.message),
                      subtitle: Text(
                        entry.revision == null
                            ? entry.timeLabel
                            : '${entry.timeLabel} • revision ${entry.revision}',
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
      ],
    );
  }

  Future<void> _copyLog(BuildContext context) async {
    final text = connectionLog.clipboardText;
    if (text.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      final count = connectionLog.entries.length;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            count == 1 ? 'Copied 1 log entry' : 'Copied $count log entries',
          ),
        ),
      );
    }
  }
}
