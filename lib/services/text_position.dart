/// Converts a character [offset] into a 1-based (line, column) position within
/// [text]. Used for sharing cursor presence with peers.
({int line, int column}) lineColumnForOffset(String text, int offset) {
  final end = offset.clamp(0, text.length);
  var line = 1;
  var column = 1;
  for (var i = 0; i < end; i++) {
    if (text.codeUnitAt(i) == 0x0A) {
      line++;
      column = 1;
    } else {
      column++;
    }
  }
  return (line: line, column: column);
}
