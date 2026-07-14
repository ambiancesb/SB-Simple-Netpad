import 'package:flutter/material.dart';
import 'package:netpad/data/repositories/discovery_repository.dart';
import 'package:netpad/features/entitlements/free_tier_usage_banner.dart';
import 'package:netpad/features/peers/peers_panel.dart';
import 'package:netpad/l10n/l10n_ext.dart';
import 'package:provider/provider.dart';

/// Peers list with device header — used in drawer (mobile) and docked panel.
class PeersSidebar extends StatelessWidget {
  const PeersSidebar({super.key, this.showHeader = true});

  final bool showHeader;

  @override
  Widget build(BuildContext context) {
    final discovery = context.watch<DiscoveryRepository>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showHeader)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  discovery.displayName,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  context.l10n.peersRoomLabel(discovery.roomId),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        const FreeTierUsageBanner(dense: true),
        const Expanded(child: PeersPanel()),
      ],
    );
  }
}
