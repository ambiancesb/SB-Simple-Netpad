/// Bonsoir service type for LAN discovery.
const String kServiceType = '_sbnetpad._tcp';

/// Protocol version sent in messages.
const int kProtocolVersion = 1;

/// Debounce delay before broadcasting local edits.
const Duration kDocDebounce = Duration(milliseconds: 300);

/// Monospace font bundled in assets.
const String kEditorFontFamily = 'JetBrainsMono';
