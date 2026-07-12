import 'package:flutter/material.dart';
import 'package:netpad/features/entitlements/paywall_sheet.dart';
import 'package:netpad/l10n/l10n_ext.dart';
import 'package:netpad/services/entitlements/entitlement_constants.dart';
import 'package:netpad/services/entitlements/entitlement_service.dart';
import 'package:netpad/services/entitlements/standard_features.dart';
import 'package:netpad/theme/app_skin.dart';
import 'package:provider/provider.dart';

/// UI helpers that show the paywall when a Standard feature is blocked.
abstract final class StandardGate {
  static Future<bool> createNoteAllowed(
    BuildContext context, {
    required int currentNoteCount,
  }) async {
    final entitlements = context.read<EntitlementService>();
    if (StandardFeatures.canCreateNote(
      entitlements: entitlements,
      currentNoteCount: currentNoteCount,
    )) {
      return true;
    }
    return showPaywallSheet(
      context,
      highlight: context.l10n.standardHighlightNoteLimit(
        EntitlementConstants.freeNoteLimit,
      ),
    );
  }

  static Future<bool> connectPeerAllowed(
    BuildContext context, {
    required int currentConnectedCount,
  }) async {
    final entitlements = context.read<EntitlementService>();
    if (StandardFeatures.canConnectPeer(
      entitlements: entitlements,
      currentConnectedCount: currentConnectedCount,
    )) {
      return true;
    }
    return showPaywallSheet(
      context,
      highlight: context.l10n.standardHighlightPeerLimit(
        EntitlementConstants.freePeerLimit,
      ),
    );
  }

  static Future<bool> versionHistoryAllowed(BuildContext context) {
    final entitlements = context.read<EntitlementService>();
    if (StandardFeatures.canUseVersionHistory(entitlements)) {
      return Future.value(true);
    }
    return showPaywallSheet(
      context,
      highlight: context.l10n.standardHighlightVersionHistory,
    );
  }

  static Future<bool> voiceInputAllowed(BuildContext context) {
    final entitlements = context.read<EntitlementService>();
    if (StandardFeatures.canUseVoiceInput(entitlements)) {
      return Future.value(true);
    }
    return showPaywallSheet(
      context,
      highlight: context.l10n.standardHighlightVoice,
    );
  }

  static Future<bool> trustedAutoSyncAllowed(BuildContext context) {
    final entitlements = context.read<EntitlementService>();
    if (StandardFeatures.canUseTrustedAutoSync(entitlements)) {
      return Future.value(true);
    }
    return showPaywallSheet(
      context,
      highlight: context.l10n.standardHighlightAutoSync,
    );
  }

  static Future<bool> skinAllowed(BuildContext context, AppSkin skin) {
    final entitlements = context.read<EntitlementService>();
    if (StandardFeatures.isSkinAvailable(skin, entitlements)) {
      return Future.value(true);
    }
    return showPaywallSheet(
      context,
      highlight: context.l10n.standardHighlightSkins,
    );
  }
}
