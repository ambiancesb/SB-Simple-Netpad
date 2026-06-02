import 'package:flutter/material.dart';
import 'package:netpad/app.dart';
import 'package:netpad/data/repositories/connection_log_repository.dart';
import 'package:netpad/data/repositories/discovery_repository.dart';
import 'package:netpad/data/repositories/document_repository.dart';
import 'package:netpad/data/repositories/pairing_repository.dart';
import 'package:netpad/data/repositories/sync_repository.dart';
import 'package:netpad/services/instance_config.dart';
import 'package:netpad/services/local_server.dart';
import 'package:netpad/services/note_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final noteStorage = NoteStorageService(prefs);
  final config = InstanceConfig(prefs);
  final instanceId = config.instanceId;
  final displayName = config.displayName;

  final localServer = LocalServer();
  final connectionLog = ConnectionLogRepository();
  final discovery = DiscoveryRepository(
    instanceId: instanceId,
    displayName: displayName,
    localServer: localServer,
  );

  late final SyncRepository sync;
  final document = DocumentRepository(
    instanceId: instanceId,
    storage: noteStorage,
    onLocalEditReady: (revision, text, originId) {
      sync.broadcastDocUpdate(revision, text, originId);
    },
  );

  sync = SyncRepository(
    instanceId: instanceId,
    displayName: displayName,
    localServer: localServer,
    discovery: discovery,
    document: document,
    connectionLog: connectionLog,
  );

  final pairing = PairingRepository(
    sync: sync,
    discovery: discovery,
    connectionLog: connectionLog,
  );

  final saved = await noteStorage.load();
  if (saved != null) {
    document.loadSaved(saved);
  }

  await discovery.start();

  runApp(
    NetpadApp(
      config: config,
      connectionLog: connectionLog,
      discovery: discovery,
      document: document,
      sync: sync,
      pairing: pairing,
    ),
  );
}
