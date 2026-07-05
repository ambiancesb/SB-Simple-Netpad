import 'dart:async';
import 'dart:io';

/// Per-peer link state owned by [SyncRepository].
class PeerConnection {
  PeerConnection({
    required this.peerId,
    required this.displayName,
  });

  final String peerId;
  final String displayName;
  String? sessionToken;
  bool authenticated = false;
  String? inboundConnectionId;
  String? outboundConnectionId;
  WebSocket? outboundSocket;
  StreamSubscription<dynamic>? outboundSub;

  /// Held until [outboundSocket] closes; required when using [WebSocket.connect]
  /// with a custom TLS client.
  HttpClient? outboundHttpClient;

  /// Server cert fingerprint captured during the TLS handshake, pinned on
  /// successful pairing (TOFU).
  String? pendingCertFingerprint;

  DateTime? lastPongAt;
  Timer? heartbeatTimer;
}

/// Closes outbound socket, subscription, and TLS client for [link].
void tearDownPeerOutbound(PeerConnection link) {
  unawaited(link.outboundSub?.cancel());
  link.outboundSub = null;
  final socket = link.outboundSocket;
  link.outboundSocket = null;
  if (socket != null) {
    unawaited(socket.close());
  }
  link.outboundHttpClient?.close(force: true);
  link.outboundHttpClient = null;
  link.outboundConnectionId = null;
  link.pendingCertFingerprint = null;
}
