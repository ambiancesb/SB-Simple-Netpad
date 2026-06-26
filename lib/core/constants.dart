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
