import 'package:flutter/material.dart';
import 'package:netpad/data/repositories/sync_repository.dart';
import 'package:netpad/data/repositories/workspace_repository.dart';
import 'package:netpad/features/entitlements/paywall_sheet.dart';
import 'package:netpad/l10n/l10n_ext.dart';
import 'package:netpad/services/entitlements/entitlement_constants.dart';
import 'package:netpad/services/entitlements/entitlement_service.dart';
import 'package:provider/provider.dart';

/// Compact free-tier usage strip for Notes / Peers drawers (hidden on Standard).
///
/// Uses [Selector] so only entitlement / quota changes rebuild this leaf —
/// keeps sibling list churn from forcing heavy chrome animations.
class FreeTierUsageBanner extends StatelessWidget {
  const FreeTierUsageBanner({super.key, this.dense = false});

  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Selector3<
      EntitlementService,
      WorkspaceRepository,
      SyncRepository,
      _FreeUsageSnapshot?
    >(
      selector: (_, entitlements, workspace, sync) {
        if (entitlements.isStandard) return null;
        final activeLen = workspace.active?.text.length ?? 0;
        return _FreeUsageSnapshot(
          syncedNotes: workspace.syncedNoteCount,
          syncedLimit: EntitlementConstants.freeSyncedNoteLimit,
          peers: sync.authenticatedPeerCount,
          peerLimit: EntitlementConstants.freePeerLimit,
          noteChars: activeLen,
          noteCharLimit: EntitlementConstants.freeNoteCharLimit,
        );
      },
      builder: (context, snap, _) {
        if (snap == null) return const SizedBox.shrink();
        final l10n = context.l10n;
        final theme = Theme.of(context);
        final atCap =
            snap.syncedNotes >= snap.syncedLimit ||
            snap.peers >= snap.peerLimit ||
            snap.noteChars >= snap.noteCharLimit;

        return Padding(
          padding: EdgeInsets.fromLTRB(dense ? 12 : 16, dense ? 4 : 0, dense ? 12 : 16, 8),
          child: Material(
            color: atCap
                ? theme.colorScheme.errorContainer.withValues(alpha: 0.55)
                : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => showPaywallSheet(
                context,
                highlight: l10n.standardHighlightCharLimit(
                  EntitlementConstants.freeNoteCharLimit,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.freeTierUsageTitle,
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.freeTierUsageLine(
                        snap.syncedNotes,
                        snap.syncedLimit,
                        snap.peers,
                        snap.peerLimit,
                        snap.noteChars,
                        snap.noteCharLimit,
                      ),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FreeUsageSnapshot {
  const _FreeUsageSnapshot({
    required this.syncedNotes,
    required this.syncedLimit,
    required this.peers,
    required this.peerLimit,
    required this.noteChars,
    required this.noteCharLimit,
  });

  final int syncedNotes;
  final int syncedLimit;
  final int peers;
  final int peerLimit;
  final int noteChars;
  final int noteCharLimit;

  @override
  bool operator ==(Object other) {
    return other is _FreeUsageSnapshot &&
        other.syncedNotes == syncedNotes &&
        other.syncedLimit == syncedLimit &&
        other.peers == peers &&
        other.peerLimit == peerLimit &&
        other.noteChars == noteChars &&
        other.noteCharLimit == noteCharLimit;
  }

  @override
  int get hashCode => Object.hash(
    syncedNotes,
    syncedLimit,
    peers,
    peerLimit,
    noteChars,
    noteCharLimit,
  );
}
