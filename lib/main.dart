import 'package:flutter/material.dart';
import 'package:netpad/app.dart';
import 'package:netpad/data/repositories/connection_log_repository.dart';
import 'package:netpad/data/repositories/discovery_repository.dart';
import 'package:netpad/data/repositories/pairing_repository.dart';
import 'package:netpad/data/repositories/sync_repository.dart';
import 'package:netpad/data/repositories/trust_store.dart';
import 'package:netpad/data/repositories/workspace_repository.dart';
import 'package:netpad/services/android_networking.dart';
import 'package:netpad/services/app_preferences.dart';
import 'package:netpad/services/instance_config.dart';
import 'package:netpad/services/local_server.dart';
import 'package:netpad/services/note_storage_service.dart';
import 'package:netpad/services/tls_identity.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final noteStorage = NoteStorageService(prefs);
  final config = InstanceConfig(prefs);
  final preferences = AppPreferences(prefs);
  await preferences.load();
  final instanceId = config.instanceId;
  final displayName = config.displayName;

  // Generated once and persisted; first launch is slightly slower.
  final tlsIdentity = await TlsIdentity.loadOrCreate(prefs);
  final trustStore = TrustStore(prefs);

  final localServer = LocalServer(securityContext: tlsIdentity.serverContext);
  final connectionLog = ConnectionLogRepository();
  final discovery = DiscoveryRepository(
    instanceId: instanceId,
    displayName: displayName,
    roomId: config.roomId,
    localServer: localServer,
  );

  final workspace = WorkspaceRepository(
    instanceId: instanceId,
    storage: noteStorage,
  );
  await workspace.load();

  final sync = SyncRepository(
    instanceId: instanceId,
    displayName: displayName,
    localServer: localServer,
    discovery: discovery,
    workspace: workspace,
    connectionLog: connectionLog,
    trustStore: trustStore,
    tlsIdentity: tlsIdentity,
  );

  workspace.onDocUpdate = sync.broadcastDocUpdate;
  workspace.onDocCreate = sync.broadcastDocCreate;
  workspace.onDocRename = sync.broadcastDocRename;
  workspace.onOrderChanged = sync.broadcastDocReorder;
  workspace.onPresence = sync.broadcastPresence;
  workspace.onDocDeleted = sync.broadcastDocDelete;

  final pairing = PairingRepository(
    sync: sync,
    discovery: discovery,
    connectionLog: connectionLog,
    trustStore: trustStore,
  );

  await AndroidNetworking.initialize(discovery);
  await discovery.start();
  pairing.startTrustedReconnectWatcher();

  runApp(
    NetpadApp(
      config: config,
      preferences: preferences,
      tlsIdentity: tlsIdentity,
      trustStore: trustStore,
      connectionLog: connectionLog,
      discovery: discovery,
      workspace: workspace,
      sync: sync,
      pairing: pairing,
    ),
  );
}
