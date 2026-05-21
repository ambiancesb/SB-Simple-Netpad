import 'package:flutter/material.dart';
import 'package:netpad/core/models/peer.dart';
import 'package:netpad/data/repositories/discovery_repository.dart';
import 'package:netpad/data/repositories/pairing_repository.dart';
import 'package:provider/provider.dart';

class PeersPanel extends StatelessWidget {
  const PeersPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final discovery = context.watch<DiscoveryRepository>();
    final pairing = context.read<PairingRepository>();

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        _sectionHeader(context, 'Connected'),
        if (discovery.connectedPeers.isEmpty)
          const _EmptyHint('No active connections'),
        ...discovery.connectedPeers.map(
          (peer) => _PeerTile(
            peer: peer,
            trailing: IconButton(
              icon: const Icon(Icons.link_off, size: 20),
              tooltip: 'Disconnect',
              onPressed: () => pairing.disconnectPeer(peer.id),
            ),
          ),
        ),
        const Divider(height: 24),
        _sectionHeader(context, 'Nearby'),
        if (discovery.discoveredPeers
            .where((p) => p.connectionState != PeerConnectionState.connected)
            .isEmpty)
          const _EmptyHint('No other instances found on this network'),
        ...discovery.discoveredPeers
            .where((p) => p.connectionState != PeerConnectionState.connected)
            .map(
          (peer) => _PeerTile(
            peer: peer,
            trailing: _ConnectButton(
              peer: peer,
              onConnect: () => _connect(context, peer),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Port ${discovery.serverPort ?? "…"}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _sectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Future<void> _connect(BuildContext context, Peer peer) async {
    final pairing = context.read<PairingRepository>();
    try {
      await pairing.requestConnection(peer);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pairing request sent to ${peer.displayName}')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not connect: $e')),
        );
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
    final connecting = peer.connectionState == PeerConnectionState.connecting ||
        peer.connectionState == PeerConnectionState.pendingOutgoing;

    return FilledButton.tonal(
      onPressed: connecting ? null : onConnect,
      child: Text(connecting ? '…' : 'Connect'),
    );
  }
}

class _PeerTile extends StatelessWidget {
  const _PeerTile({required this.peer, required this.trailing});

  final Peer peer;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    final color = switch (peer.connectionState) {
      PeerConnectionState.connected => Colors.green,
      PeerConnectionState.connecting => Colors.orange,
      _ => Colors.grey,
    };

    return ListTile(
      dense: true,
      leading: Icon(Icons.circle, size: 10, color: color),
      title: Text(peer.displayName),
      subtitle: peer.primaryHost != null
          ? Text('${peer.primaryHost}:${peer.port}')
          : const Text('Resolving…'),
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
