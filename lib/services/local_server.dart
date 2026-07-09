import 'dart:async';
import 'dart:io';

import 'package:netpad/core/local_network.dart';
import 'package:netpad/services/protocol_codec.dart';
import 'package:netpad/core/models/protocol_message.dart';

typedef MessageHandler =
    void Function(String connectionId, ProtocolMessage message);

typedef ConnectionClosedHandler = void Function(String connectionId);

typedef ConnectionOpenedHandler = void Function(String connectionId);

typedef InboundRejectedHandler =
    void Function(String reason, InternetAddress? remoteAddress);

class LocalServer {
  LocalServer({required this.securityContext});

  /// TLS identity used to serve `wss://` (self-signed, pinned by peers).
  final SecurityContext securityContext;

  HttpServer? _server;
  final Map<String, WebSocket> _sockets = {};
  final Map<String, InternetAddress> _remoteAddresses = {};
  int _connCounter = 0;

  MessageHandler? onMessage;
  ConnectionClosedHandler? onConnectionClosed;
  ConnectionOpenedHandler? onConnectionOpened;
  InboundRejectedHandler? onInboundRejected;

  int? get port => _server?.port;

  InternetAddress? remoteAddressFor(String connectionId) =>
      _remoteAddresses[connectionId];

  Future<int> start() async {
    if (_server != null) return _server!.port;
    _server = await HttpServer.bindSecure(
      InternetAddress.anyIPv4,
      0,
      securityContext,
    );
    _server!.listen(_handleRequest);
    return _server!.port;
  }

  Future<void> stop() async {
    for (final socket in _sockets.values) {
      await socket.close();
    }
    _sockets.clear();
    await _server?.close(force: true);
    _server = null;
  }

  void send(String connectionId, ProtocolMessage message) {
    final socket = _sockets[connectionId];
    if (socket != null && socket.readyState == WebSocket.open) {
      socket.add(ProtocolCodec.encode(message));
    }
  }

  void broadcastExcept(String exceptConnectionId, ProtocolMessage message) {
    final encoded = ProtocolCodec.encode(message);
    for (final entry in _sockets.entries) {
      if (entry.key == exceptConnectionId) continue;
      if (entry.value.readyState == WebSocket.open) {
        entry.value.add(encoded);
      }
    }
  }

  void broadcastToAll(ProtocolMessage message) {
    final encoded = ProtocolCodec.encode(message);
    for (final socket in _sockets.values) {
      if (socket.readyState == WebSocket.open) {
        socket.add(encoded);
      }
    }
  }

  Iterable<String> get connectionIds => _sockets.keys;

  Future<void> closeConnection(String connectionId) async {
    _remoteAddresses.remove(connectionId);
    final socket = _sockets.remove(connectionId);
    await socket?.close();
  }

  bool _isLocalClient(HttpRequest request) {
    final remote = request.connectionInfo?.remoteAddress;
    if (remote == null) return true;
    return LocalNetwork.isLanReachable(remote);
  }

  void _rejectInbound(HttpRequest request, String reason) {
    onInboundRejected?.call(reason, request.connectionInfo?.remoteAddress);
    request.response
      ..statusCode = HttpStatus.forbidden
      ..write('forbidden')
      ..close();
  }

  Future<void> _handleRequest(HttpRequest request) async {
    if (!_isLocalClient(request)) {
        _rejectInbound(
        request,
        'Refused connection from outside the active local subnet',
      );
      return;
    }

    if (request.uri.path == '/health' && request.method == 'GET') {
      request.response
        ..statusCode = HttpStatus.ok
        ..write('ok')
        ..close();
      return;
    }

    if (request.uri.path == '/ws' &&
        WebSocketTransformer.isUpgradeRequest(request)) {
      final socket = await WebSocketTransformer.upgrade(request);
      final connectionId = 'in_${++_connCounter}';
      _sockets[connectionId] = socket;
      final remote = request.connectionInfo?.remoteAddress;
      if (remote != null) {
        _remoteAddresses[connectionId] = remote;
      }

      onConnectionOpened?.call(connectionId);

      socket.listen(
        (data) {
          if (data is! String) return;
          final message = ProtocolCodec.decode(data);
          if (message != null) {
            onMessage?.call(connectionId, message);
          }
        },
        onDone: () {
          _sockets.remove(connectionId);
          _remoteAddresses.remove(connectionId);
          onConnectionClosed?.call(connectionId);
        },
        onError: (_) {
          _sockets.remove(connectionId);
          _remoteAddresses.remove(connectionId);
          onConnectionClosed?.call(connectionId);
        },
        cancelOnError: true,
      );
      return;
    }

    request.response
      ..statusCode = HttpStatus.notFound
      ..close();
  }
}
