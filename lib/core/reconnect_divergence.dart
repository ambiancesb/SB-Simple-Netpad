/// True when both sides have different non-empty note bodies after reconnect.
bool noteTextsDiverged(String localText, String remoteText) {
  return remoteText != localText &&
      localText.trim().isNotEmpty &&
      remoteText.trim().isNotEmpty;
}

/// Only the lexicographically smaller [localInstanceId] prompts so both
/// devices converge on one reconnect divergence decision.
bool isReconnectDivergencePromptDevice({
  required String localInstanceId,
  required String remoteOriginId,
  required String localText,
  required String remoteText,
}) {
  return noteTextsDiverged(localText, remoteText) &&
      localInstanceId.compareTo(remoteOriginId) < 0;
}
