import 'package:flutter/material.dart';
import 'package:netpad/core/models/peer.dart';
import 'package:netpad/core/models/peer_presence.dart';
import 'package:netpad/data/repositories/connection_log_repository.dart';
import 'package:netpad/data/repositories/discovery_repository.dart';
import 'package:netpad/data/repositories/pairing_repository.dart';
import 'package:netpad/data/repositories/sync_repository.dart';
import 'package:netpad/features/peers/manual_connect_dialog.dart';
import 'package:netpad/features/peers/this_device_banner.dart';
import 'package:provider/provider.dart';

class PeersPanel extends StatelessWidget {
  const PeersPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final discovery = context.watch<DiscoveryRepository>();
    final connectionLog = context.watch<ConnectionLogRepository>();
    final sync = context.watch<SyncRepository>();
    final pairing = context.read<PairingRepository>();

    final nearby = discovery.discoveredPeers
        .where((p) => p.connectionState != PeerConnectionState.connected)
        .toList();

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        ThisDeviceBanner(port: discovery.serverPort),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: OutlinedButton.icon(
            onPressed: () => _manualConnect(context),
            icon: const Icon(Icons.add_link),
            label: const Text('Connect by IP'),
          ),
        ),
        _sectionHeader(context, 'Connected'),
        if (discovery.connectedPeers.isEmpty)
          const _EmptyHint('No active connections'),
        ...discovery.connectedPeers.map(
          (peer) => _PeerTile(
            peer: peer,
            presence: sync.presence[peer.id],
            trailing: IconButton(
              icon: const Icon(Icons.link_off, size: 20),
              tooltip: 'Disconnect',
              onPressed: () => pairing.disconnectPeer(peer.id),
            ),
          ),
        ),
        const Divider(height: 24),
        _sectionHeader(context, 'Nearby'),
        if (nearby.isEmpty)
          const _EmptyHint(
            'No discovered peers — try Connect by IP or share this device’s address',
          ),
        ...nearby.map(
          (peer) => _PeerTile(
            peer: peer,
            trailing: _ConnectButton(
              peer: peer,
              onConnect: () => _connect(context, peer),
            ),
          ),
        ),
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not connect: $e')));
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

class _PeerTile extends StatelessWidget {
  const _PeerTile({
    required this.peer,
    required this.trailing,
    this.presence,
  });

  final Peer peer;
  final Widget trailing;
  final PeerPresence? presence;

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

    return ListTile(
      dense: true,
      leading: Icon(Icons.circle, size: 10, color: color),
      title: Text(peer.displayName),
      subtitle: Text(subtitle),
      trailing: trailing,
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
                onPressed: entries.isEmpty ? null : connectionLog.clear,
                child: const Text('Clear'),
              ),
            ],
          ),
        ),
        if (entries.isEmpty) const _EmptyHint('No connection events yet'),
        ...entries
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
            ),
      ],
    );
  }
}
