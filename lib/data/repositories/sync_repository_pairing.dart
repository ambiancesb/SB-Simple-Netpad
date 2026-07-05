part of 'sync_repository.dart';

extension SyncRepositoryPairing on SyncRepository {
  Future<void> connectAndRequestPair(Peer peer) async {
    if (_trustStore.isBlocked(peer.id)) {
      throw StateError('${peer.displayName} is blocked. Unblock it to connect.');
    }
    final existing = _linksByPeerId[peer.id];
    if (existing?.authenticated == true) {
      throw StateError('Already connected to ${peer.displayName}.');
    }
    if (existing?.outboundSocket != null) {
      throw StateError('Already connecting to ${peer.displayName}.');
    }

    final refreshed = peer.isManual
        ? peer
        : await _discovery.refreshPeerForConnect(peer.id) ?? peer;
    final host = await PeerHostResolver.resolveConnectHost(refreshed);
    if (host == null) {
      throw StateError(
        'Peer ${peer.displayName} has no resolved address. '
        'On Linux, ensure Avahi is running and both devices are on the same subnet.',
      );
    }
    _discovery.markPeerConnecting(peer.id);
    final requestId = const Uuid().v4();
    final hostInUri = PeerHostResolver.formatForWebSocket(host);
    final uri = Uri.parse('wss://$hostInUri:${refreshed.port}/ws');

    final httpClient = HttpClient(
      context: SecurityContext(withTrustedRoots: false),
    );
    String? capturedFingerprint;
    var pinMismatch = false;
    httpClient.badCertificateCallback = (cert, certHost, certPort) {
      final fingerprint = fingerprintFromDer(cert.der);
      final pinned = _trustStore.pinnedFingerprint(peer.id);
      if (pinned != null && pinned != fingerprint) {
        pinMismatch = true;
        return false;
      }
      capturedFingerprint = fingerprint;
      return true;
    };

    final WebSocket socket;
    try {
      socket = await WebSocket.connect(
        uri.toString(),
        customClient: httpClient,
      ).timeout(
        SyncRepository._connectTimeout,
        onTimeout: () {
          throw TimeoutException(
            'Timed out reaching ${peer.displayName} at $hostInUri:${refreshed.port}',
          );
        },
      );
    } catch (e) {
      httpClient.close(force: true);
      _discovery.markPeerDisconnected(peer.id);
      if (pinMismatch) {
        throw StateError(
          'Certificate for ${peer.displayName} does not match the pinned one. '
          'Possible impersonation — connection refused.',
        );
      }
      rethrow;
    }

    final connectionId = 'out_${peer.id}';
    _pendingOutboundRequestId[connectionId] = requestId;

    final link = _linksByPeerId[peer.id] ??
        PeerConnection(peerId: peer.id, displayName: peer.displayName);
    link.outboundConnectionId = connectionId;
    link.outboundSocket = socket;
    link.outboundHttpClient = httpClient;
    link.pendingCertFingerprint = capturedFingerprint;
    _linksByPeerId[peer.id] = link;
    _connectionToPeerId[connectionId] = peer.id;

    link.outboundSub = socket.listen(
      (data) {
        if (data is String) {
          final msg = ProtocolCodec.decode(data);
          if (msg != null) _handleMessage(connectionId, msg, isOutbound: true);
        }
      },
      onDone: () => _handleDisconnect(connectionId),
      onError: (_) => _handleDisconnect(connectionId),
      cancelOnError: true,
    );

    _sendOnConnection(
      connectionId,
      ProtocolMessage(
        type: MessageTypes.pairRequest,
        payload: {
          'requestId': requestId,
          'fromId': instanceId,
          'fromName': _displayName,
          'protocolVersion': kProtocolVersion,
        },
      ),
    );
    _startPairingTimeout(connectionId, peer.id, peer.displayName);

    final verificationCode = peer.isManual
        ? null
        : PairingVerificationCode.generate(instanceId, peer.id);
    _connectionLog.add(
      verificationCode == null
          ? 'Pairing request sent to ${peer.displayName}'
          : 'Pairing request sent to ${peer.displayName} (code $verificationCode)',
      peerId: peer.id,
      peerName: peer.displayName,
    );
  }

  void respondToPairRequest({
    required String connectionId,
    required String requestId,
    required String fromId,
    required String fromName,
    required bool accepted,
  }) {
    if (accepted) {
      final token = const Uuid().v4();
      final link = _linksByPeerId[fromId] ??
          PeerConnection(peerId: fromId, displayName: fromName);
      link.inboundConnectionId = connectionId;
      link.sessionToken = token;
      link.authenticated = true;
      _linksByPeerId[fromId] = link;
      _connectionToPeerId[connectionId] = fromId;
      _cancelPairingTimeoutForPeer(fromId);

      _sendOnConnection(
        connectionId,
        ProtocolMessage(
          type: MessageTypes.pairResponse,
          payload: {
            'requestId': requestId,
            'accepted': true,
            'protocolVersion': kProtocolVersion,
          },
        ),
      );
      _sendOnConnection(
        connectionId,
        ProtocolMessage(
          type: MessageTypes.pairComplete,
          payload: {'sessionToken': token},
        ),
      );

      _discovery.markPeerConnected(
        Peer(
          id: fromId,
          displayName: fromName,
          port: _discovery.serverPort ?? 0,
          connectionState: PeerConnectionState.connected,
        ),
      );
      _connectionLog.add(
        'Accepted pairing with $fromName',
        peerId: fromId,
        peerName: fromName,
      );
      _sendDocSnapshot(connectionId);
      _startHeartbeat(fromId);
    } else {
      _sendOnConnection(
        connectionId,
        ProtocolMessage(
          type: MessageTypes.pairResponse,
          payload: {'requestId': requestId, 'accepted': false},
        ),
      );
      _connectionLog.add(
        'Rejected pairing with $fromName',
        peerId: fromId,
        peerName: fromName,
      );
      unawaited(_server.closeConnection(connectionId));
    }
  }

  void _startPairingTimeout(
    String connectionId,
    String peerId,
    String peerName,
  ) {
    _cancelPairingTimeout(connectionId);
    _pairingTimeouts[connectionId] = Timer(SyncRepository._pairingTimeout, () {
      _pairingTimeouts.remove(connectionId);
      final link = _linksByPeerId[peerId];
      if (link == null || link.authenticated) return;
      _connectionLog.add(
        'Pairing timed out with $peerName',
        peerId: peerId,
        peerName: peerName,
      );
      onPairRequestResolved?.call(peerId, false);
      _cleanupConnection(connectionId);
    });
  }

  void _cancelPairingTimeout(String connectionId) {
    _pairingTimeouts.remove(connectionId)?.cancel();
  }

  void _cancelPairingTimeoutForPeer(String peerId) {
    final link = _linksByPeerId[peerId];
    if (link == null) return;
    if (link.inboundConnectionId != null) {
      _cancelPairingTimeout(link.inboundConnectionId!);
    }
    if (link.outboundConnectionId != null) {
      _cancelPairingTimeout(link.outboundConnectionId!);
    }
  }

  void _abandonOutbound(String peerId) {
    final link = _linksByPeerId[peerId];
    if (link == null) return;

    final outId = link.outboundConnectionId;
    if (outId != null) {
      _cancelPairingTimeout(outId);
      _pendingOutboundRequestId.remove(outId);
      _connectionToPeerId.remove(outId);
    }
    tearDownPeerOutbound(link);

    if (link.inboundConnectionId == null && !link.authenticated) {
      _linksByPeerId.remove(peerId);
      _discovery.markPeerDisconnected(peerId);
      notifyPeersChanged();
    }
  }

  void _handlePairingMessage(
    String connectionId,
    ProtocolMessage message, {
    required bool isOutbound,
  }) {
    switch (message.type) {
      case MessageTypes.pairRequest:
        final requestId = message.payload['requestId'] as String? ?? '';
        final fromId = message.payload['fromId'] as String? ?? '';
        final fromName = message.payload['fromName'] as String? ?? 'Unknown';
        final peerProtocol = message.payload['protocolVersion'] as int? ?? 1;
        _connectionToPeerId[connectionId] = fromId;
        if (_trustStore.isBlocked(fromId)) {
          _sendOnConnection(
            connectionId,
            ProtocolMessage(
              type: MessageTypes.pairResponse,
              payload: {'requestId': requestId, 'accepted': false},
            ),
          );
          _connectionLog.add(
            'Refused blocked peer $fromName',
            peerId: fromId,
            peerName: fromName,
          );
          unawaited(_server.closeConnection(connectionId));
          return;
        }
        if (peerProtocol != kProtocolVersion) {
          _sendOnConnection(
            connectionId,
            ProtocolMessage(
              type: MessageTypes.pairResponse,
              payload: {
                'requestId': requestId,
                'accepted': false,
                'protocolVersion': kProtocolVersion,
                'reason': 'protocol_mismatch',
              },
            ),
          );
          _connectionLog.add(
            'Refused $fromName: protocol v$peerProtocol '
            '(requires v$kProtocolVersion)',
            peerId: fromId,
            peerName: fromName,
          );
          unawaited(_server.closeConnection(connectionId));
          return;
        }
        final existingLink = _linksByPeerId[fromId];
        if (existingLink?.authenticated == true) {
          _sendOnConnection(
            connectionId,
            ProtocolMessage(
              type: MessageTypes.pairResponse,
              payload: {
                'requestId': requestId,
                'accepted': false,
                'reason': 'already_connected',
              },
            ),
          );
          _connectionLog.add(
            'Refused duplicate pairing from $fromName (already connected)',
            peerId: fromId,
            peerName: fromName,
          );
          unawaited(_server.closeConnection(connectionId));
          return;
        }
        final outboundId = existingLink?.outboundConnectionId;
        if (outboundId != null &&
            _pendingOutboundRequestId.containsKey(outboundId) &&
            existingLink?.outboundSocket != null) {
          if (outboundPairingWins(instanceId, fromId)) {
            _sendOnConnection(
              connectionId,
              ProtocolMessage(
                type: MessageTypes.pairResponse,
                payload: {
                  'requestId': requestId,
                  'accepted': false,
                  'reason': 'simultaneous_connect',
                },
              ),
            );
            _connectionLog.add(
              'Declined inbound pairing from $fromName '
              '(outbound request in progress)',
              peerId: fromId,
              peerName: fromName,
            );
            unawaited(_server.closeConnection(connectionId));
            return;
          }
          _connectionLog.add(
            'Dropped outbound pairing to $fromName (accepting their request)',
            peerId: fromId,
            peerName: fromName,
          );
          _abandonOutbound(fromId);
        }
        onIncomingPairRequest?.call(fromId, fromName, requestId, connectionId);
      case MessageTypes.pairResponse:
        final accepted = message.payload['accepted'] as bool? ?? false;
        final peerId = _connectionToPeerId[connectionId];
        if (peerId != null) {
          final peerName = _discovery.peerById(peerId)?.displayName ?? peerId;
          if (accepted) {
            final peerProtocol =
                message.payload['protocolVersion'] as int? ?? 1;
            if (peerProtocol != kProtocolVersion) {
              _connectionLog.add(
                'Pairing failed with $peerName: protocol v$peerProtocol '
                '(requires v$kProtocolVersion)',
                peerId: peerId,
                peerName: peerName,
              );
              onPairRequestResolved?.call(peerId, false);
              _cleanupConnection(connectionId);
              _pendingOutboundRequestId.remove(connectionId);
              return;
            }
          }
          _connectionLog.add(
            accepted
                ? 'Pairing accepted by $peerName'
                : 'Pairing rejected by $peerName'
                    '${message.payload['reason'] != null ? ' (${message.payload['reason']})' : ''}',
            peerId: peerId,
            peerName: peerName,
          );
          onPairRequestResolved?.call(peerId, accepted);
          if (!accepted) {
            _cleanupConnection(connectionId);
          } else {
            _startPairingTimeout(connectionId, peerId, peerName);
          }
        }
        _pendingOutboundRequestId.remove(connectionId);
      case MessageTypes.pairComplete:
        final token = message.payload['sessionToken'] as String? ?? '';
        final peerId = _connectionToPeerId[connectionId];
        if (peerId == null || token.isEmpty) return;
        _cancelPairingTimeout(connectionId);

        final link = _linksByPeerId[peerId] ??
            PeerConnection(
              peerId: peerId,
              displayName:
                  _discovery.peerById(peerId)?.displayName ?? peerId,
            );
        link.sessionToken = token;
        link.authenticated = true;
        if (isOutbound) {
          link.outboundConnectionId = connectionId;
        } else {
          link.inboundConnectionId = connectionId;
        }
        _linksByPeerId[peerId] = link;

        final peer = _discovery.peerById(peerId);
        if (peer != null) {
          _discovery.markPeerConnected(peer);
        }
        // TOFU: pin the server cert we saw when we initiated this connection.
        if (isOutbound && link.pendingCertFingerprint != null) {
          final fingerprint = link.pendingCertFingerprint!;
          final isNew = !_trustStore.hasPin(peerId);
          unawaited(_trustStore.pin(peerId, fingerprint));
          _connectionLog.add(
            '${isNew ? 'Pinned' : 'Verified'} ${link.displayName} security code '
            '${shortFingerprint(fingerprint)}',
            peerId: peerId,
            peerName: link.displayName,
          );
        }
        _connectionLog.add(
          'Pairing complete with ${link.displayName}',
          peerId: peerId,
          peerName: link.displayName,
        );
        _sendDocSnapshot(connectionId);
        _startHeartbeat(peerId);
    }
  }
}
