import 'package:flutter/material.dart';
import 'package:netpad/features/entitlements/paywall_sheet.dart';
import 'package:netpad/l10n/l10n_ext.dart';
import 'package:netpad/services/entitlements/entitlement_constants.dart';
import 'package:netpad/services/entitlements/entitlement_service.dart';
import 'package:netpad/services/entitlements/pro_features.dart';
import 'package:netpad/theme/app_skin.dart';
import 'package:provider/provider.dart';

/// UI helpers that show the paywall when a Pro feature is blocked.
abstract final class ProGate {
  static Future<bool> createNoteAllowed(
    BuildContext context, {
    required int currentNoteCount,
  }) async {
    final entitlements = context.read<EntitlementService>();
    if (ProFeatures.canCreateNote(
      entitlements: entitlements,
      currentNoteCount: currentNoteCount,
    )) {
      return true;
    }
    return showPaywallSheet(
      context,
      highlight: context.l10n.proHighlightNoteLimit(
        EntitlementConstants.freeNoteLimit,
      ),
    );
  }

  static Future<bool> connectPeerAllowed(
    BuildContext context, {
    required int currentConnectedCount,
  }) async {
    final entitlements = context.read<EntitlementService>();
    if (ProFeatures.canConnectPeer(
      entitlements: entitlements,
      currentConnectedCount: currentConnectedCount,
    )) {
      return true;
    }
    return showPaywallSheet(
      context,
      highlight: context.l10n.proHighlightPeerLimit(
        EntitlementConstants.freePeerLimit,
      ),
    );
  }

  static Future<bool> versionHistoryAllowed(BuildContext context) {
    final entitlements = context.read<EntitlementService>();
    if (ProFeatures.canUseVersionHistory(entitlements)) {
      return Future.value(true);
    }
    return showPaywallSheet(
      context,
      highlight: context.l10n.proHighlightVersionHistory,
    );
  }

  static Future<bool> voiceInputAllowed(BuildContext context) {
    final entitlements = context.read<EntitlementService>();
    if (ProFeatures.canUseVoiceInput(entitlements)) {
      return Future.value(true);
    }
    return showPaywallSheet(
      context,
      highlight: context.l10n.proHighlightVoice,
    );
  }

  static Future<bool> trustedAutoSyncAllowed(BuildContext context) {
    final entitlements = context.read<EntitlementService>();
    if (ProFeatures.canUseTrustedAutoSync(entitlements)) {
      return Future.value(true);
    }
    return showPaywallSheet(
      context,
      highlight: context.l10n.proHighlightAutoSync,
    );
  }

  static Future<bool> skinAllowed(BuildContext context, AppSkin skin) {
    final entitlements = context.read<EntitlementService>();
    if (ProFeatures.isSkinAvailable(skin, entitlements)) {
      return Future.value(true);
    }
    return showPaywallSheet(
      context,
      highlight: context.l10n.proHighlightSkins,
    );
  }
}
