/// Bonsoir service type for LAN discovery.
const String kServiceType = '_sbnetpad._tcp';

/// Protocol version sent in messages (bump when wire format changes).
const int kProtocolVersion = 3;

/// Debounce delay before broadcasting local edits.
const Duration kDocDebounce = Duration(milliseconds: 300);

/// Debounce delay before broadcasting cursor presence.
const Duration kPresenceDebounce = Duration(milliseconds: 180);

/// Interval between heartbeat pings on authenticated peer links.
const Duration kHeartbeatInterval = Duration(seconds: 15);

/// Disconnect a peer when no pong arrives within this window.
const Duration kHeartbeatTimeout = Duration(seconds: 45);

/// Debounce before background auto-reconnect attempts to trusted peers.
const Duration kTrustedReconnectDebounce = Duration(seconds: 2);

/// Monospace font bundled in assets.
const String kEditorFontFamily = 'JetBrainsMono';

/// Default session / room group advertised in TXT records.
const String kDefaultRoom = 'default';

/// Title used for a freshly created note before the user renames it.
const String kDefaultNoteTitle = 'Untitled note';

/// Maximum number of local version snapshots kept per note.
const int kMaxHistoryEntries = 50;

/// Notes larger than this skip version-history snapshots (shared_preferences).
const int kMaxHistorySnapshotChars = 100 * 1024;

/// Total characters stored across all history entries for one note.
const int kMaxHistoryTotalChars = 512 * 1024;

/// Minimum spacing between automatic local version snapshots.
const Duration kHistoryMinInterval = Duration(minutes: 2);
