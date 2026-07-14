part of 'sync_repository.dart';

extension SyncRepositoryTrust on SyncRepository {
  /// Sends a mid-session trust offer to an authenticated peer.
  ///
  /// Returns false when Standard is unavailable, the peer is already trusted,
  /// not connected, or an offer is already pending.
  bool offerTrust(String peerId) {
    if (!_isStandard()) return false;
    if (_trustStore.canAutoSync(peerId)) return false;
    if (_pendingOutboundTrustOffer.containsKey(peerId)) return false;

    final link = _linksByPeerId[peerId];
    if (link == null || !link.authenticated) return false;

    final connectionId = _authenticatedConnectionId(peerId);
    if (connectionId == null) return false;

    final requestId = const Uuid().v4();
    _pendingOutboundTrustOffer[peerId] = requestId;

    _sendOnConnection(
      connectionId,
      ProtocolMessage(
        type: MessageTypes.trustOffer,
        payload: {
          'requestId': requestId,
          'fromId': instanceId,
          'fromName': _displayName,
        },
      ),
    );

    _connectionLog.add(
      'Trust offer sent to ${link.displayName}',
      peerId: peerId,
      peerName: link.displayName,
    );
    notifyPeersChanged();
    return true;
  }

  void respondToTrustOffer({
    required String connectionId,
    required String requestId,
    required String fromId,
    required String fromName,
    required bool accepted,
  }) {
    final pending = _pendingInboundTrustOffer[fromId];
    if (pending != requestId) return;
    _pendingInboundTrustOffer.remove(fromId);

    final sendOn = _authenticatedConnectionId(fromId) ?? connectionId;

    if (!accepted) {
      _sendOnConnection(
        sendOn,
        ProtocolMessage(
          type: MessageTypes.trustResponse,
          payload: {
            'requestId': requestId,
            'accepted': false,
          },
        ),
      );
      _connectionLog.add(
        'Declined trust offer from $fromName',
        peerId: fromId,
        peerName: fromName,
      );
      return;
    }

    if (!_isStandard()) {
      _sendOnConnection(
        sendOn,
        ProtocolMessage(
          type: MessageTypes.trustResponse,
          payload: {
            'requestId': requestId,
            'accepted': false,
            'reason': 'not_standard',
          },
        ),
      );
      _connectionLog.add(
        'Could not accept trust from $fromName (Standard required)',
        peerId: fromId,
        peerName: fromName,
      );
      return;
    }

    _completeTrustAsIssuer(
      connectionId: sendOn,
      requestId: requestId,
      peerId: fromId,
      peerName: fromName,
    );
  }

  void _handleTrustMessage(String connectionId, ProtocolMessage message) {
    switch (message.type) {
      case MessageTypes.trustOffer:
        _handleTrustOffer(connectionId, message);
      case MessageTypes.trustResponse:
        _handleTrustResponse(connectionId, message);
    }
  }

  void _handleTrustOffer(String connectionId, ProtocolMessage message) {
    final requestId = message.payload['requestId'] as String? ?? '';
    final fromId = message.payload['fromId'] as String? ?? '';
    final fromName = message.payload['fromName'] as String? ??
        _linksByPeerId[fromId]?.displayName ??
        'Unknown';
    if (requestId.isEmpty || fromId.isEmpty) return;

    final senderPeerId = _connectionToPeerId[connectionId];
    if (senderPeerId != null && senderPeerId != fromId) {
      _connectionLog.add(
        'Rejected trust offer: fromId mismatch',
        peerId: senderPeerId,
        peerName: _linksByPeerId[senderPeerId]?.displayName,
      );
      return;
    }

    if (_trustStore.isBlocked(fromId)) {
      _sendOnConnection(
        connectionId,
        ProtocolMessage(
          type: MessageTypes.trustResponse,
          payload: {
            'requestId': requestId,
            'accepted': false,
            'reason': 'blocked',
          },
        ),
      );
      return;
    }

    // Already trusted — reaffirm with the existing token (no dialog).
    if (_trustStore.canAutoSync(fromId)) {
      final token = _trustStore.autoSyncToken(fromId);
      if (token != null && token.isNotEmpty) {
        _sendOnConnection(
          connectionId,
          ProtocolMessage(
            type: MessageTypes.trustResponse,
            payload: {
              'requestId': requestId,
              'accepted': true,
              'autoSyncToken': token,
            },
          ),
        );
      }
      return;
    }

    final outboundPending = _pendingOutboundTrustOffer.containsKey(fromId);
    if (outboundPending) {
      final action = simultaneousTrustAction(
        localInstanceId: instanceId,
        remoteInstanceId: fromId,
      );
      if (action == SimultaneousTrustAction.completeAsIssuer) {
        if (!_isStandard()) {
          _pendingOutboundTrustOffer.remove(fromId);
          _sendOnConnection(
            connectionId,
            ProtocolMessage(
              type: MessageTypes.trustResponse,
              payload: {
                'requestId': requestId,
                'accepted': false,
                'reason': 'not_standard',
              },
            ),
          );
          onTrustOfferResolved?.call(fromId, false);
          notifyPeersChanged();
          return;
        }
        _pendingOutboundTrustOffer.remove(fromId);
        _completeTrustAsIssuer(
          connectionId: connectionId,
          requestId: requestId,
          peerId: fromId,
          peerName: fromName,
        );
        onTrustOfferResolved?.call(fromId, true);
        notifyPeersChanged();
        return;
      }
      // Loser keeps outbound pending and waits for trust_response.
      return;
    }

    _pendingInboundTrustOffer[fromId] = requestId;
    onIncomingTrustOffer?.call(fromId, fromName, requestId, connectionId);
  }

  void _handleTrustResponse(String connectionId, ProtocolMessage message) {
    final requestId = message.payload['requestId'] as String? ?? '';
    final accepted = message.payload['accepted'] as bool? ?? false;
    final autoSyncToken = message.payload['autoSyncToken'] as String? ?? '';
    final peerId = _connectionToPeerId[connectionId];
    if (peerId == null || requestId.isEmpty) return;

    final expected = _pendingOutboundTrustOffer[peerId];
    if (expected == null || expected != requestId) {
      // Stale or simultaneous-issuer path may clear pending before this arrives.
      if (!accepted || autoSyncToken.isEmpty) return;
      if (_trustStore.canAutoSync(peerId)) return;
      final link = _linksByPeerId[peerId];
      if (link == null) return;
      unawaited(
        _trustStore.setTrustedPeer(
          peerId: peerId,
          displayName: link.displayName,
          autoSyncToken: autoSyncToken,
        ),
      );
      _pinRemotePeerIfNeeded(
        peerId,
        link.displayName,
        link.remoteCertFingerprint ?? link.pendingCertFingerprint,
      );
      onTrustOfferResolved?.call(peerId, true);
      notifyPeersChanged();
      return;
    }

    _pendingOutboundTrustOffer.remove(peerId);

    if (accepted && autoSyncToken.isNotEmpty) {
      final link = _linksByPeerId[peerId];
      final name = link?.displayName ?? peerId;
      unawaited(
        _trustStore.setTrustedPeer(
          peerId: peerId,
          displayName: name,
          autoSyncToken: autoSyncToken,
        ),
      );
      if (link != null) {
        _pinRemotePeerIfNeeded(
          peerId,
          name,
          link.remoteCertFingerprint ?? link.pendingCertFingerprint,
        );
      }
      _connectionLog.add(
        'Trust confirmed with $name',
        peerId: peerId,
        peerName: name,
      );
      onTrustOfferResolved?.call(peerId, true);
    } else {
      final name = _linksByPeerId[peerId]?.displayName ?? peerId;
      _connectionLog.add(
        'Trust declined by $name',
        peerId: peerId,
        peerName: name,
      );
      onTrustOfferResolved?.call(peerId, false);
    }
    notifyPeersChanged();
  }

  void _completeTrustAsIssuer({
    required String connectionId,
    required String requestId,
    required String peerId,
    required String peerName,
  }) {
    final autoSyncToken = generateAutoSyncToken();
    final link = _linksByPeerId[peerId];
    unawaited(
      _trustStore.setTrustedPeer(
        peerId: peerId,
        displayName: peerName,
        autoSyncToken: autoSyncToken,
      ),
    );
    if (link != null) {
      _pinRemotePeerIfNeeded(
        peerId,
        peerName,
        link.remoteCertFingerprint ?? link.pendingCertFingerprint,
      );
    }

    _sendOnConnection(
      connectionId,
      ProtocolMessage(
        type: MessageTypes.trustResponse,
        payload: {
          'requestId': requestId,
          'accepted': true,
          'autoSyncToken': autoSyncToken,
        },
      ),
    );

    _connectionLog.add(
      'Trusted $peerName for auto-sync',
      peerId: peerId,
      peerName: peerName,
    );
    notifyPeersChanged();
  }

  String? _authenticatedConnectionId(String peerId) {
    final link = _linksByPeerId[peerId];
    if (link == null || !link.authenticated) return null;
    if (link.inboundConnectionId != null) return link.inboundConnectionId;
    if (link.outboundConnectionId != null && link.outboundSocket != null) {
      return link.outboundConnectionId;
    }
    return null;
  }

  void _cancelTrustStateForPeer(String peerId) {
    final hadOutbound = _pendingOutboundTrustOffer.remove(peerId) != null;
    final hadInbound = _pendingInboundTrustOffer.remove(peerId) != null;
    if (hadOutbound || hadInbound) {
      onTrustOfferCancelled?.call(peerId);
      notifyPeersChanged();
    }
  }
}
