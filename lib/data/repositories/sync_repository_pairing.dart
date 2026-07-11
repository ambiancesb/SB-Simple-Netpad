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
    if (!_isPro() &&
        authenticatedPeerCount >= EntitlementConstants.freePeerLimit) {
      throw StateError(
        'Free includes up to ${EntitlementConstants.freePeerLimit} connected '
        'peers. Unlock Pro for unlimited peers.',
      );
    }
    await LocalNetwork.refreshActiveSubnets();
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
    final resolvedAddr = InternetAddress.tryParse(LocalNetwork.stripZoneId(host));
    if (resolvedAddr == null || !LocalNetwork.isLanReachable(resolvedAddr)) {
      throw StateError(
        'Refused to connect to ${peer.displayName}: '
        '$host is not on your active local subnet. '
        'Netpad only syncs with devices on the same network segment.',
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
      if (kDebugMode) {
        debugPrint(
          'WSS connect failed to ${uri.toString()}: $e',
        );
      }
      if (pinMismatch) {
        throw StateError(
          'Certificate for ${peer.displayName} does not match the pinned one. '
          'Possible impersonation — connection refused.',
        );
      }
      rethrow;
    }

    // Inbound auto-accept may have finished while this outbound dial was in flight.
    final activeLink = _linksByPeerId[peer.id];
    if (activeLink?.authenticated == true) {
      httpClient.close(force: true);
      unawaited(socket.close());
      markPeerConnectedFromLink(
        peer.id,
        displayName: peer.displayName,
      );
      return;
    }

    final connectionId = 'out_${peer.id}';
    _pendingOutboundRequestId[connectionId] = requestId;

    final canAutoSync = _isPro() && _trustStore.canAutoSync(peer.id);
    final autoSyncToken =
        canAutoSync ? _trustStore.autoSyncToken(peer.id) : null;
    final trustedReconnect = shouldSendAutoSyncToken(
      canAutoSync: canAutoSync,
      autoSyncToken: autoSyncToken,
    );

    final link = _linksByPeerId[peer.id] ??
        PeerConnection(peerId: peer.id, displayName: peer.displayName);
    link.outboundConnectionId = connectionId;
    link.outboundSocket = socket;
    link.outboundHttpClient = httpClient;
    link.pendingCertFingerprint = capturedFingerprint;
    link.trustedOutboundReconnect = trustedReconnect;
    link.remoteHost = host;
    link.remotePort = refreshed.port;
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
        payload: buildPairRequestPayload(
          requestId: requestId,
          fromId: instanceId,
          fromName: _displayName,
          certFingerprint: _tlsIdentity.fingerprint,
          autoSyncToken: autoSyncToken,
        ),
      ),
    );
    _startPairingTimeout(connectionId, peer.id, peer.displayName);

    final verificationCode = peer.isManual
        ? null
        : PairingVerificationCode.generate(instanceId, peer.id);
    _connectionLog.add(
      trustedReconnect
          ? 'Reconnecting to ${peer.displayName} (trusted)'
          : verificationCode == null
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
      if (!_isPro() &&
          authenticatedPeerCount >= EntitlementConstants.freePeerLimit) {
        _refuseInboundPairRequest(
          connectionId: connectionId,
          requestId: requestId,
          fromId: fromId,
          fromName: fromName,
          logMessage:
              'Refused $fromName: free peer limit '
              '(${EntitlementConstants.freePeerLimit}) reached',
          reason: 'peer_limit',
        );
        return;
      }
      _completePairingAsAcceptor(
        connectionId: connectionId,
        requestId: requestId,
        fromId: fromId,
        fromName: fromName,
        autoAccepted: false,
      );
    } else {
      _refuseInboundPairRequest(
        connectionId: connectionId,
        requestId: requestId,
        fromId: fromId,
        fromName: fromName,
        logMessage: 'Rejected pairing with $fromName',
      );
    }
  }

  void _completePairingAsAcceptor({
    required String connectionId,
    required String requestId,
    required String fromId,
    required String fromName,
    required bool autoAccepted,
  }) {
    final token = const Uuid().v4();
    final autoSyncToken = generateAutoSyncToken();
    final link = _linksByPeerId[fromId] ??
        PeerConnection(peerId: fromId, displayName: fromName);
    link.inboundConnectionId = connectionId;
    link.sessionToken = token;
    link.authenticated = true;
    _linksByPeerId[fromId] = link;
    _connectionToPeerId[connectionId] = fromId;
    _cancelPairingTimeoutForPeer(fromId);
    tearDownPeerOutbound(link);

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
        payload: {
          'sessionToken': token,
          'autoSyncToken': autoSyncToken,
        },
      ),
    );

    _pinRemotePeerIfNeeded(fromId, fromName, link.remoteCertFingerprint);
    unawaited(
      _trustStore.setTrustedPeer(
        peerId: fromId,
        displayName: fromName,
        autoSyncToken: autoSyncToken,
      ),
    );

    markPeerConnectedFromLink(
      fromId,
      displayName: fromName,
      inboundConnectionId: connectionId,
    );
    _connectionLog.add(
      autoAccepted
          ? 'Auto-reconnected to $fromName'
          : 'Accepted pairing with $fromName',
      peerId: fromId,
      peerName: fromName,
    );
    _sendDocSnapshot(connectionId);
    _startHeartbeat(fromId);
    notifyPeersChanged();
  }

  void _refuseInboundPairRequest({
    required String connectionId,
    required String requestId,
    required String fromId,
    required String fromName,
    required String logMessage,
    String? reason,
  }) {
    _sendOnConnection(
      connectionId,
      ProtocolMessage(
        type: MessageTypes.pairResponse,
        payload: {
          'requestId': requestId,
          'accepted': false,
          if (reason != null) 'reason': reason,
        },
      ),
    );
    _connectionLog.add(
      logMessage,
      peerId: fromId,
      peerName: fromName,
    );
    unawaited(_server.closeConnection(connectionId));
  }

  bool _tryAutoAcceptPairRequest({
    required String connectionId,
    required String requestId,
    required String fromId,
    required String fromName,
    required int peerProtocol,
    required String? remoteCertFingerprint,
    required String? pendingAutoSyncToken,
  }) {
    if (shouldRefuseTrustedReconnect(
      requestToken: pendingAutoSyncToken,
      pinnedFingerprint: _trustStore.pinnedFingerprint(fromId),
      requestFingerprint: remoteCertFingerprint,
    )) {
      _refuseInboundPairRequest(
        connectionId: connectionId,
        requestId: requestId,
        fromId: fromId,
        fromName: fromName,
        logMessage:
            'Trusted reconnect refused for $fromName: certificate mismatch '
            '(pin may be stale — use Block then re-pair, or Revoke and connect manually)',
        reason: 'cert_mismatch',
      );
      return true;
    }

    if (!canAutoAcceptPairRequest(
      isBlocked: _trustStore.isBlocked(fromId),
      peerProtocol: peerProtocol,
      alreadyConnected: _linksByPeerId[fromId]?.authenticated == true,
      canAutoSync: _isPro() && _trustStore.canAutoSync(fromId),
      storedToken: _trustStore.autoSyncToken(fromId),
      requestToken: pendingAutoSyncToken,
      pinnedFingerprint: _trustStore.pinnedFingerprint(fromId),
      requestFingerprint: remoteCertFingerprint,
    )) {
      return false;
    }

    _completePairingAsAcceptor(
      connectionId: connectionId,
      requestId: requestId,
      fromId: fromId,
      fromName: fromName,
      autoAccepted: true,
    );
    return true;
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
        _cancelPrePairTimeout(connectionId);
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
        final inboundLink = _linksByPeerId[fromId] ??
            PeerConnection(peerId: fromId, displayName: fromName);
        inboundLink.remoteCertFingerprint =
            message.payload['certFingerprint'] as String?;
        inboundLink.pendingAutoSyncToken =
            message.payload['autoSyncToken'] as String?;
        _linksByPeerId[fromId] = inboundLink;
        if (_tryAutoAcceptPairRequest(
          connectionId: connectionId,
          requestId: requestId,
          fromId: fromId,
          fromName: fromName,
          peerProtocol: peerProtocol,
          remoteCertFingerprint: inboundLink.remoteCertFingerprint,
          pendingAutoSyncToken: inboundLink.pendingAutoSyncToken,
        )) {
          return;
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
          final reason = message.payload['reason'] as String?;
          if (accepted) {
            _connectionLog.add(
              'Pairing accepted by $peerName',
              peerId: peerId,
              peerName: peerName,
            );
            onPairRequestResolved?.call(peerId, true);
            _startPairingTimeout(connectionId, peerId, peerName);
          } else if (reason == 'already_connected' &&
              _linksByPeerId[peerId]?.authenticated == true) {
            _cleanupConnection(connectionId);
            markPeerConnectedFromLink(peerId);
            onPairRequestResolved?.call(peerId, true);
          } else {
            _connectionLog.add(
              'Pairing rejected by $peerName'
              '${reason != null ? ' ($reason)' : ''}',
              peerId: peerId,
              peerName: peerName,
            );
            onPairRequestResolved?.call(peerId, false);
            _cleanupConnection(connectionId);
          }
        }
        _pendingOutboundRequestId.remove(connectionId);
      case MessageTypes.pairComplete:
        final token = message.payload['sessionToken'] as String? ?? '';
        final autoSyncToken = message.payload['autoSyncToken'] as String? ?? '';
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

        markPeerConnectedFromLink(peerId);
        // TOFU: pin the server cert we saw when we initiated this connection.
        if (isOutbound && link.pendingCertFingerprint != null) {
          _pinRemotePeerIfNeeded(
            peerId,
            link.displayName,
            link.pendingCertFingerprint,
          );
        }
        if (autoSyncToken.isNotEmpty) {
          unawaited(
            _trustStore.setTrustedPeer(
              peerId: peerId,
              displayName: link.displayName,
              autoSyncToken: autoSyncToken,
            ),
          );
        }
        final completeLabel = isOutbound && link.trustedOutboundReconnect
            ? 'Auto-reconnected to ${link.displayName}'
            : 'Pairing complete with ${link.displayName}';
        _connectionLog.add(
          completeLabel,
          peerId: peerId,
          peerName: link.displayName,
        );
        _sendDocSnapshot(connectionId);
        _startHeartbeat(peerId);
    }
  }

  void _pinRemotePeerIfNeeded(
    String peerId,
    String peerName,
    String? fingerprint,
  ) {
    if (fingerprint == null || fingerprint.isEmpty) return;
    final isNew = !_trustStore.hasPin(peerId);
    unawaited(_trustStore.pin(peerId, fingerprint));
    _connectionLog.add(
      '${isNew ? 'Pinned' : 'Verified'} $peerName security code '
      '${shortFingerprint(fingerprint)}',
      peerId: peerId,
      peerName: peerName,
    );
  }
}
