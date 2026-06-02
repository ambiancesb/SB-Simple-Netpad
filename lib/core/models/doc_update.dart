/// Full-document sync payload exchanged after pairing.
class DocUpdate {
  const DocUpdate({
    required this.revision,
    required this.text,
    required this.originId,
  });

  final int revision;
  final String text;
  final String originId;

  factory DocUpdate.fromPayload(Map<String, dynamic> payload) {
    return DocUpdate(
      revision: payload['revision'] as int? ?? 0,
      text: payload['text'] as String? ?? '',
      originId: payload['originId'] as String? ?? '',
    );
  }

  Map<String, dynamic> toPayload() => {
    'revision': revision,
    'text': text,
    'originId': originId,
  };
}
