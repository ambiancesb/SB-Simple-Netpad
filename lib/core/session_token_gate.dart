import 'package:netpad/core/models/protocol_message.dart';

/// Whether [type] must carry a matching authenticated [sessionToken].
bool messageTypeRequiresSessionToken(String type) {
  return type == MessageTypes.docSnapshot ||
      type == MessageTypes.docUpdate ||
      type == MessageTypes.docCreate ||
      type == MessageTypes.docRename ||
      type == MessageTypes.docCatalog ||
      type == MessageTypes.docReorder ||
      type == MessageTypes.docDelete ||
      type == MessageTypes.peerDisconnect ||
      type == MessageTypes.presence ||
      type == MessageTypes.ping ||
      type == MessageTypes.pong ||
      type == MessageTypes.trustOffer ||
      type == MessageTypes.trustResponse;
}
