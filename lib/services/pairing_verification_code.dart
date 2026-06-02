class PairingVerificationCode {
  const PairingVerificationCode._();

  static String generate(String firstId, String secondId) {
    final ids = [firstId, secondId]..sort();
    final input = '${ids[0]}:${ids[1]}';
    var hash = 0x811c9dc5;

    for (var i = 0; i < input.length; i++) {
      hash ^= input.codeUnitAt(i);
      hash = (hash * 0x01000193) & 0xffffffff;
    }

    final code = (hash % 1000000).abs().toString().padLeft(6, '0');
    return '${code.substring(0, 3)}-${code.substring(3)}';
  }
}
