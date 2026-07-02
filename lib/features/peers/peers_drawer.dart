import 'package:flutter/material.dart';
import 'package:netpad/data/repositories/discovery_repository.dart';
import 'package:netpad/features/peers/peers_sidebar.dart';
import 'package:netpad/features/peers/session_security_banner.dart';
import 'package:netpad/features/shell/desktop_side_panel.dart';
import 'package:provider/provider.dart';

/// Mobile slide-out drawer wrapping [PeersSidebar].
class PeersDrawer extends StatelessWidget {
  const PeersDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return const Drawer(
      width: 320,
      child: SafeArea(child: PeersSidebar()),
    );
  }
}

/// Docked peers panel for desktop with device identity and security in the chrome.
class PeersDesktopPanel extends StatelessWidget {
  const PeersDesktopPanel({super.key, required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final discovery = context.watch<DiscoveryRepository>();
    final security = SessionSecuritySummary.of(context);

    return DesktopSidePanel(
      title: discovery.displayName,
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Room "${discovery.roomId}"'),
          const SizedBox(height: 2),
          Row(
            children: [
              Icon(
                security.connectedCount > 0 ? Icons.lock : Icons.lock_outline,
                size: 14,
                color: security.connectedCount > 0
                    ? Colors.green.shade700
                    : Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  security.compactLabel,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ],
      ),
      width: 320,
      onClose: onClose,
      child: const PeersSidebar(showHeader: false),
    );
  }
}
