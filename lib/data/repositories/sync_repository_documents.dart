part of 'sync_repository.dart';

extension SyncRepositoryDocuments on SyncRepository {
  void broadcastDocUpdate(
    String docId,
    String title,
    int revision,
    String text,
    String originId,
  ) {
    final message = ProtocolMessage(
      type: MessageTypes.docUpdate,
      payload: {
        'docId': docId,
        'title': title,
        'revision': revision,
        'text': text,
        'originId': originId,
      },
    );
    _fanOut(message, exceptConnectionId: null, exceptPeerId: instanceId);
  }

  void broadcastDocCreate(
    String docId,
    String title,
    int revision,
    String originId,
  ) {
    final message = ProtocolMessage(
      type: MessageTypes.docCreate,
      payload: {
        'docId': docId,
        'title': title,
        'revision': revision,
        'originId': originId,
      },
    );
    _fanOut(message, exceptConnectionId: null, exceptPeerId: instanceId);
  }

  void broadcastDocRename(
    String docId,
    String title,
    int revision,
    String originId,
  ) {
    final message = ProtocolMessage(
      type: MessageTypes.docRename,
      payload: {
        'docId': docId,
        'title': title,
        'revision': revision,
        'originId': originId,
      },
    );
    _fanOut(message, exceptConnectionId: null, exceptPeerId: instanceId);
  }

  void broadcastDocReorder(
    List<String> order,
    int orderRevision,
    String originId,
  ) {
    final message = ProtocolMessage(
      type: MessageTypes.docReorder,
      payload: {
        'originId': originId,
        'orderRevision': orderRevision,
        'order': order,
      },
    );
    _fanOut(message, exceptConnectionId: null, exceptPeerId: instanceId);
  }

  void broadcastDocDelete(String docId, String originId) {
    final message = ProtocolMessage(
      type: MessageTypes.docDelete,
      payload: {'docId': docId, 'originId': originId},
    );
    _fanOut(message, exceptConnectionId: null, exceptPeerId: instanceId);
  }

  void broadcastPresence(String docId, int line, int column) {
    if (_linksByPeerId.isEmpty) return;
    final message = ProtocolMessage(
      type: MessageTypes.presence,
      payload: {
        'peerId': instanceId,
        'name': _displayName,
        'docId': docId,
        'line': line,
        'column': column,
      },
    );
    _fanOut(message, exceptConnectionId: null, exceptPeerId: instanceId);
  }

  void disconnectPeer(String peerId, {bool announce = true}) {
    final link = _linksByPeerId[peerId];
    if (link == null) return;

    _stopHeartbeat(link);
    final message = ProtocolMessage(
      type: MessageTypes.peerDisconnect,
      payload: {'peerId': instanceId},
    );

    final inboundId = link.inboundConnectionId;
    final outboundId = link.outboundConnectionId;

    // Announce on one channel only. Reciprocal disconnects must not announce
    // again — the initiator already tore down and would log a false token reject.
    if (announce) {
      if (inboundId != null) {
        _sendOnConnection(inboundId, message);
      } else if (outboundId != null && link.outboundSocket != null) {
        _sendOnConnection(outboundId, message);
      }
    }

    if (inboundId != null) {
      unawaited(_server.closeConnection(inboundId));
    }
    if (link.outboundSocket != null) {
      tearDownPeerOutbound(link);
    }

    if (inboundId != null) {
      _connectionToPeerId.remove(inboundId);
    }
    if (outboundId != null) {
      _connectionToPeerId.remove(outboundId);
    }

    _linksByPeerId.remove(peerId);
    _presence.remove(peerId);
    _discovery.markPeerDisconnected(peerId);
    _cancelTrustStateForPeer(peerId);
    _connectionLog.add(
      'Disconnected from ${link.displayName}',
      peerId: peerId,
      peerName: link.displayName,
    );
    notifyPeersChanged();
  }

  void _handlePresence(ProtocolMessage message) {
    final peerId = message.payload['peerId'] as String? ?? '';
    if (peerId.isEmpty || peerId == instanceId) return;
    final line = message.payload['line'] as int? ?? 1;
    final column = message.payload['column'] as int? ?? 1;
    final docId = message.payload['docId'] as String?;
    final docTitle = docId == null
        ? null
        : _workspace.documentById(docId)?.title;
    _presence[peerId] = PeerPresence(
      line: line,
      column: column,
      updatedAt: DateTime.now(),
      docId: docId,
      docTitle: docTitle,
    );
    notifyPeersChanged();
  }

  void _logTokenRejected(String connectionId, String type) {
    final peerId = _connectionToPeerId[connectionId];
    _connectionLog.add(
      'Rejected $type: invalid session token',
      peerId: peerId,
      peerName: peerId == null ? null : _linksByPeerId[peerId]?.displayName,
    );
  }

  /// Handles a document snapshot received at pair/reconnect time. If the local
  /// note has diverged from the peer's, prompt the user (on one deterministic
  /// side) instead of silently merging.
  Future<void> _handleSnapshot(
    ProtocolMessage message,
    String fromConnectionId,
  ) async {
    final revision = message.payload['revision'] as int? ?? 0;
    final text = message.payload['text'] as String? ?? '';
    final originId = message.payload['originId'] as String? ?? '';
    final docId = message.payload['docId'] as String? ?? '';
    final title = message.payload['title'] as String? ?? '';
    if (docId.isEmpty) return;
    if (_workspace.shouldIgnoreInboundSync(docId)) return;
    final document = _workspace.ensureDocument(docId, title: title);
    final localText = document.text;

    final diverged = noteTextsDiverged(localText, text);

    // Only the lexicographically-smaller instance prompts, so both devices
    // converge on one decision instead of fighting.
    final shouldPrompt =
        diverged &&
        onSnapshotDivergence != null &&
        !_divergencePromptActive &&
        isReconnectDivergencePromptDevice(
          localInstanceId: instanceId,
          remoteOriginId: originId,
          localText: localText,
          remoteText: text,
        );

    if (!shouldPrompt) {
      unawaited(_handleDocMessage(message, fromConnectionId));
      return;
    }

    final peerId = _connectionToPeerId[fromConnectionId];
    final peerName = peerId == null
        ? 'peer'
        : (_linksByPeerId[peerId]?.displayName ?? 'peer');

    _divergencePromptActive = true;
    final DivergenceChoice choice;
    try {
      choice = await onSnapshotDivergence!(
        peerName,
        document.title,
        document.revision,
        localText,
        revision,
        text,
      );
    } finally {
      _divergencePromptActive = false;
    }

    if (choice == DivergenceChoice.takeTheirs) {
      document.forceApplyRemote(revision: revision, text: text, title: title);
      _relay(message, fromConnectionId);
      _connectionLog.add(
        'Reconnect divergence: used $peerName\'s version',
        peerId: peerId,
        peerName: peerName,
        revision: revision,
      );
    } else {
      document.bumpAndBroadcast(revision);
      _connectionLog.add(
        'Reconnect divergence: kept local version',
        peerId: peerId,
        peerName: peerName,
      );
    }
  }

  Future<void> _handleDocMessage(
    ProtocolMessage message,
    String fromConnectionId,
  ) async {
    final revision = message.payload['revision'] as int? ?? 0;
    final text = message.payload['text'] as String? ?? '';
    final originId = message.payload['originId'] as String? ?? '';
    final docId = message.payload['docId'] as String? ?? '';
    final title = message.payload['title'] as String? ?? '';
    if (docId.isEmpty) return;
    if (_workspace.shouldIgnoreInboundSync(docId)) return;

    final document = _workspace.documentById(docId);
    final shouldPrompt =
        document != null &&
        document.isLiveEditConflict(
          revision: revision,
          text: text,
          originId: originId,
        ) &&
        onLiveConflict != null &&
        !_liveConflictPromptActive &&
        instanceId.compareTo(originId) < 0;

    if (shouldPrompt) {
      final peerId = _connectionToPeerId[fromConnectionId];
      final peerName = peerId == null
          ? 'peer'
          : (_linksByPeerId[peerId]?.displayName ?? 'peer');

      _liveConflictPromptActive = true;
      final DivergenceChoice choice;
      try {
        choice = await onLiveConflict!(
          peerName,
          document.title,
          revision,
          document.text,
          text,
        );
      } finally {
        _liveConflictPromptActive = false;
      }

      if (choice == DivergenceChoice.takeTheirs) {
        document.forceApplyRemote(
          revision: revision,
          text: text,
          title: title,
        );
        _connectionLog.add(
          'Live conflict: used $peerName\'s version',
          peerId: peerId,
          peerName: peerName,
          revision: revision,
        );
        _relay(message, fromConnectionId);
      } else {
        document.bumpAndBroadcast(revision);
        _connectionLog.add(
          'Live conflict: kept local version',
          peerId: peerId,
          peerName: peerName,
        );
      }
      return;
    }

    final applied = _workspace.receiveRemoteContent(
      docId: docId,
      title: title,
      revision: revision,
      text: text,
      originId: originId,
    );
    if (applied) {
      final peerId = _connectionToPeerId[fromConnectionId];
      final peerName = peerId == null
          ? null
          : _linksByPeerId[peerId]?.displayName;
      _connectionLog.add(
        'Applied ${message.type} revision $revision',
        peerId: peerId,
        peerName: peerName,
        revision: revision,
      );
      _relay(message, fromConnectionId);
    }
  }

  void _handleDocCreate(ProtocolMessage message, String fromConnectionId) {
    final docId = message.payload['docId'] as String? ?? '';
    final title = message.payload['title'] as String? ?? '';
    final revision = message.payload['revision'] as int? ?? 0;
    final originId = message.payload['originId'] as String? ?? '';
    if (docId.isEmpty || originId == instanceId) return;
    if (_workspace.shouldIgnoreInboundSync(docId)) return;

    final existed = _workspace.hasDocument(docId);
    _workspace.receiveRemoteCreate(
      docId: docId,
      title: title,
      revision: revision,
      originId: originId,
    );

    final peerId = _connectionToPeerId[fromConnectionId];
    _connectionLog.add(
      existed ? 'Updated note "$title"' : 'Learned new note "$title"',
      peerId: peerId,
      peerName: peerId == null ? null : _linksByPeerId[peerId]?.displayName,
      revision: revision,
    );
    _relay(message, fromConnectionId);
  }

  void _handleDocRename(ProtocolMessage message, String fromConnectionId) {
    final docId = message.payload['docId'] as String? ?? '';
    final title = message.payload['title'] as String? ?? '';
    final revision = message.payload['revision'] as int? ?? 0;
    final originId = message.payload['originId'] as String? ?? '';
    if (docId.isEmpty || originId == instanceId) return;
    if (_workspace.shouldIgnoreInboundSync(docId)) return;

    final before = _workspace.documentById(docId)?.title;
    _workspace.receiveRemoteRename(
      docId: docId,
      title: title,
      revision: revision,
      originId: originId,
    );
    final after = _workspace.documentById(docId)?.title;
    if (before != after) {
      final peerId = _connectionToPeerId[fromConnectionId];
      _connectionLog.add(
        'Renamed note to "$title"',
        peerId: peerId,
        peerName: peerId == null ? null : _linksByPeerId[peerId]?.displayName,
        revision: revision,
      );
      _relay(message, fromConnectionId);
    }
  }

  void _handleDocCatalog(ProtocolMessage message, String fromConnectionId) {
    final originId = message.payload['originId'] as String? ?? '';
    if (originId.isEmpty || originId == instanceId) return;

    final rawNotes = message.payload['notes'] as List<dynamic>? ?? const [];
    final entries = [
      for (final n in rawNotes) Map<String, dynamic>.from(n as Map),
    ];
    final orderRevision = message.payload['orderRevision'] as int? ?? 0;
    final beforeCount = _workspace.documents.length;
    final beforeOrder = _workspace.noteOrder;
    _workspace.mergeCatalog(
      entries,
      originId,
      orderRevision: orderRevision,
    );
    final afterCount = _workspace.documents.length;
    final afterOrder = _workspace.noteOrder;
    if (afterCount > beforeCount || !_ordersEqual(beforeOrder, afterOrder)) {
      final peerId = _connectionToPeerId[fromConnectionId];
      _connectionLog.add(
        afterCount > beforeCount
            ? 'Synced ${afterCount - beforeCount} note(s) from peer catalog'
            : 'Synced note order from peer catalog',
        peerId: peerId,
        peerName: peerId == null ? null : _linksByPeerId[peerId]?.displayName,
      );
    }
    _relay(message, fromConnectionId);
  }

  void _handleDocReorder(ProtocolMessage message, String fromConnectionId) {
    final originId = message.payload['originId'] as String? ?? '';
    if (originId.isEmpty || originId == instanceId) return;

    final orderRevision = message.payload['orderRevision'] as int? ?? 0;
    final rawOrder = message.payload['order'] as List<dynamic>? ?? const [];
    final order = [for (final id in rawOrder) id as String];
    if (_workspace.applyRemoteOrder(order, orderRevision, originId)) {
      final peerId = _connectionToPeerId[fromConnectionId];
      _connectionLog.add(
        'Synced note order from peer',
        peerId: peerId,
        peerName: peerId == null ? null : _linksByPeerId[peerId]?.displayName,
      );
      _relay(message, fromConnectionId);
    }
  }

  bool _ordersEqual(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  void _relay(ProtocolMessage message, String fromConnectionId) {
    for (final connId in relayConnectionTargets(
      links: _syncPeerLinks(),
      connectionToPeerId: _connectionToPeerId,
      fromConnectionId: fromConnectionId,
    )) {
      _sendOnConnection(connId, message);
    }
  }

  void _sendDocSnapshot(String connectionId) {
    _sendOnConnection(
      connectionId,
      ProtocolMessage(
        type: MessageTypes.docCatalog,
        payload: {
          'originId': instanceId,
          'orderRevision': _workspace.orderRevision,
          'notes': _workspace.catalogPayload(),
        },
      ),
    );
    for (final doc in _workspace.documents) {
      if (!_workspace.isSyncEnabled(doc.id)) continue;
      _sendOnConnection(
        connectionId,
        ProtocolMessage(
          type: MessageTypes.docSnapshot,
          payload: doc.snapshotPayload(),
        ),
      );
    }
  }

}
