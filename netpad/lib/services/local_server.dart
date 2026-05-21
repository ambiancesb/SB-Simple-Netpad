import 'dart:async';
import 'dart:io';

import 'package:netpad/services/protocol_codec.dart';
import 'package:netpad/core/models/protocol_message.dart';

typedef MessageHandler = void Function(
  String connectionId,
  ProtocolMessage message,
);

typedef ConnectionClosedHandler = void Function(String connectionId);

class LocalServer {
  HttpServer? _server;
  final Map<String, WebSocket> _sockets = {};
  int _connCounter = 0;

  MessageHandler? onMessage;
  ConnectionClosedHandler? onConnectionClosed;

  int? get port => _server?.port;

  Future<int> start() async {
    if (_server != null) return _server!.port;
    _server = await HttpServer.bind(InternetAddress.anyIPv4, 0);
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

  void broadcastExcept(
    String exceptConnectionId,
    ProtocolMessage message,
  ) {
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
    final socket = _sockets.remove(connectionId);
    await socket?.close();
  }

  Future<void> _handleRequest(HttpRequest request) async {
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
          onConnectionClosed?.call(connectionId);
        },
        onError: (_) {
          _sockets.remove(connectionId);
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
