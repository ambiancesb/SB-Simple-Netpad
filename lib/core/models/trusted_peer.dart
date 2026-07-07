/// Persistent trust record for a paired peer (Phase 9 auto-sync).
class TrustedPeer {
  const TrustedPeer({
    required this.displayName,
    required this.autoSyncToken,
    required this.pairedAt,
    this.autoSyncEnabled = true,
  });

  final String displayName;
  final String autoSyncToken;
  final DateTime pairedAt;
  final bool autoSyncEnabled;

  Map<String, dynamic> toJson() => {
    'displayName': displayName,
    'autoSyncToken': autoSyncToken,
    'pairedAt': pairedAt.toUtc().toIso8601String(),
    'autoSyncEnabled': autoSyncEnabled,
  };

  factory TrustedPeer.fromJson(Map<String, dynamic> json) {
    return TrustedPeer(
      displayName: json['displayName'] as String? ?? '',
      autoSyncToken: json['autoSyncToken'] as String? ?? '',
      pairedAt: DateTime.tryParse(json['pairedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      autoSyncEnabled: json['autoSyncEnabled'] as bool? ?? true,
    );
  }

  TrustedPeer copyWith({
    String? displayName,
    String? autoSyncToken,
    DateTime? pairedAt,
    bool? autoSyncEnabled,
  }) {
    return TrustedPeer(
      displayName: displayName ?? this.displayName,
      autoSyncToken: autoSyncToken ?? this.autoSyncToken,
      pairedAt: pairedAt ?? this.pairedAt,
      autoSyncEnabled: autoSyncEnabled ?? this.autoSyncEnabled,
    );
  }
}
