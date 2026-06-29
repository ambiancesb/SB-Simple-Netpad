/// Bonsoir service type for LAN discovery.
const String kServiceType = '_sbnetpad._tcp';

/// Protocol version sent in messages.
const int kProtocolVersion = 1;

/// Debounce delay before broadcasting local edits.
const Duration kDocDebounce = Duration(milliseconds: 300);

/// Debounce delay before broadcasting cursor presence.
const Duration kPresenceDebounce = Duration(milliseconds: 180);

/// Monospace font bundled in assets.
const String kEditorFontFamily = 'JetBrainsMono';

/// Default session / room group advertised in TXT records.
const String kDefaultRoom = 'default';

/// Title used for a freshly created note before the user renames it.
const String kDefaultNoteTitle = 'Untitled note';

/// Maximum number of local version snapshots kept per note.
const int kMaxHistoryEntries = 50;

/// Minimum spacing between automatic local version snapshots.
const Duration kHistoryMinInterval = Duration(minutes: 2);
