# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project currently tracks versions informally.

## [Unreleased]

### Changed
- Project status is now **beta** — all roadmap phases through Phase 9 are complete.

### Added
- **Windows beta installer** — `scripts/build-windows-installer.ps1` builds a release bundle and packages `dist/SB-Simple-Netpad-<version>-beta-windows-x64.zip` (extract and run `Setup.cmd`). Optional single-file `.exe` when [Inno Setup 6+](https://jrsoftware.org/isinfo.php) is installed on the build machine.
- **Trusted peers and auto-sync (Phase 9)** — After the first manual **Accept**, both devices store a persistent auto-sync token alongside the cert pin. Reconnects skip the pairing dialog when token and fingerprint match; trusted peers auto-reconnect when discovered on the LAN. **Trusted devices** section in the peers drawer: per-peer auto-sync toggle and **Revoke** (distinct from **Block**). Protocol bumped to **v3**.
- **Phase 9 test suite** — [test/phase9_test.dart](test/phase9_test.dart) covers trusted-peer persistence, auto-accept validation, `peer_disconnect` sender checks, and pair-request payload rules.
- **Local-network enforcement** — Inbound and outbound peer connections must fall on this device's active subnet(s), derived from live interface addresses and netmasks; peers on other private subnets or public IPs are refused. Discovered peers outside the active subnet are hidden.
- **Wi‑Fi-first sync policy** — On cellular-only devices, peer sync is fully paused (no mDNS, no listen port, no scans). A banner explains that Wi‑Fi or a personal hotspot is required.
- **Netpad-only inbound guard** — Inbound WebSockets that never send a valid `pair_request` are closed after 8 seconds.
- **Per-note sync toggle** — Each note in the Notes drawer has a switch to mark it synced or local-only. Local-only notes stay on device: excluded from peer catalog/snapshots, edits are not broadcast, and inbound peer updates for that note are ignored. Visual “Local only” hint with a muted cloud-off icon.
- **Phase 8 test suite** — [test/phase8_test.dart](test/phase8_test.dart) covers sync flags, outbound/inbound guards, multi-peer relay targets, and reconnect divergence convergence.
- **Live edit conflict dialog** — When two peers edit the same note at the same revision, one device prompts with text previews to keep yours or use theirs (replaces silent tie-break snackbar).
- **Protocol version negotiation** — Pair handshake carries `protocolVersion`; peers must match exactly (`v3`). Older builds are refused with a connection-log entry.
- **Heartbeat** — `ping`/`pong` on authenticated links every 15s; peers that stop responding for 45s are disconnected automatically.

### Changed
- **Threat model** — README documents enforced local-network, Wi‑Fi-first, Netpad-only, and trusted-peer auto-sync policies.
- Wire protocol bumped to **v3** (`kProtocolVersion`); all messages encode `v: 3`. `pair_complete` includes `autoSyncToken`.
- **Android LAN discovery** — Wi‑Fi is no longer mistaken for cellular-only when mobile data is also active; `ConnectivityManager` confirms Wi‑Fi/Ethernet before pausing sync; subnet checks fall back when interface enumeration lags; Android 13+ requests `NEARBY_WIFI_DEVICES`; multicast lock and connectivity callbacks restart discovery promptly after cold start.
- **10.x LAN segment matching** — Devices on the same `10.x.x.x/16` (common on large Wi‑Fi with mDNS reflectors) can connect even when assigned different `/24` subnets; home `192.168.x.x` networks still require the same `/24`.
- **Trusted auto-reconnect** — Failed outbound reconnect no longer tears down an active inbound session; `already_connected` is treated as success; reconnect backoff after connection refused (111) or duplicate attempts.

### Removed
- Silent "revision conflict resolved" snackbar — live conflicts now always prompt on the deterministic device.

## [1.2.0] - 2026-06-30

Phase 5 complete: multiple documents, per-note history, and search.

### Added
- **Multiple named notes** — Manage many notes from a left Notes drawer (create / rename / delete). Each note has its own id, title, revision, and editor; notes sync per-document and creating/renaming/deleting propagates to peers via `doc_create`, `doc_rename`, `doc_delete`, and a `doc_catalog` exchange on pair.
- **Note history / versioning** — Each note keeps a bounded local snapshot ring, captured before remote edits clobber local text and before file imports/restores. Restore any version from the per-note Version history sheet.
- **Search** — In-note find bar (match count with next/previous navigation) and cross-note search in the Notes drawer (matches titles and bodies, with snippets).
- **Note order sync** — Drag-to-reorder in the Notes drawer; order propagates via `doc_reorder` and is included in the `doc_catalog` exchange on pair.
- **Per-note presence** — A peer's cursor now reports which note they are editing, shown in the peers drawer.
- **Phase 5 test suite** — [test/phase5_test.dart](test/phase5_test.dart) (14 tests) covers history, workspace CRUD, catalog/order merge, and cross-note search.

### Changed
- Storage reworked from a single note to a multi-document layout (`docs_index` + per-note keys in `shared_preferences`); a legacy single note is migrated automatically on first launch.
- "Open file" now imports into a **new** note instead of replacing the active one.

### Fixed
- Avoided a `code_text_field` range crash when a remote update grew a note by exactly one character while the editor selection was uninitialised.

## [1.1.1] - 2026-06-15

Phase 4 complete: TLS transport, certificate pinning, peer blocking, and reconnect divergence.

### Added
- **TLS transport** — each device generates a persisted self-signed certificate; all peer traffic upgraded from `ws://` to `wss://` (`basic_utils`/`pointycastle` for cert generation, `crypto` for fingerprints).
- **Certificate pinning (TOFU)** — peer certificate fingerprints are pinned on first connect and verified afterwards; a mismatch refuses the connection. The accepting device shows its security code in the pairing dialog.
- **Block / unblock peers** — disconnects, forgets the pinned certificate, and refuses re-pair in both directions; persisted blocklist with a Blocked section in the peers drawer.
- **Reconnect divergence prompt** — detects when a reconnecting peer's note diverged from the local one and prompts to keep mine / use theirs, converging both devices.

### Changed
- Bumped `path_provider_android` override to 2.2.23 (last pre-JNI release that still targets the modern Android v2 embedding) so both Android and Linux builds work; added a `path_provider_foundation` 2.4.1 override to avoid the `objective_c` build hook on Linux.

## [1.1.0] - 2026-06-04

### Added
- **Save to file** — Export the current note to a user-chosen path via the native save dialog (desktop).
- **Open from file** — Load a text file into the editor, with confirmation before replacing a live synced note.
- **Share note** — Send the current note through the OS share sheet / share dialog.
- Initial Flutter app scaffold for Android, iOS, Windows, macOS, and Linux.
- Line-numbered plain-text editor using `code_text_field`.
- Local network discovery and broadcast using Bonsoir (`_sbnetpad._tcp`).
- Pairing flow with explicit Accept/Reject confirmation on target device.
- Multi-peer sync with revision-based conflict handling and update relay.
- Peers drawer with discovered/connected peers and connection status indicators.
- Manual "Connect by IP" fallback workflow.
- "This device" address banner with copy-to-clipboard support.
- Auto-save and restore for note text and revision state.
- Device rename flow that rebroadcasts discovery metadata without restart.
- Session token enforcement for post-pair sync and disconnect messages.
- Session-only connection log in the peers drawer.
- Display-only pairing verification codes.
- Basic copy/paste support via native selection and editor keyboard shortcuts.
- Linux troubleshooting notes and dependency setup script.
- Project roadmap in `ROADMAP.md`.
- File menu with **Save to file**, **Open file**, and **Share note** actions (`file_picker` + `share_plus`).
- Open-from-file prompts before replacing a non-empty note and propagates the change to connected peers.
- **Session / room ID** advertised in TXT records; only peers in the same room are discovered (editable in Settings).
- **Network change listener** (`NetworkMonitor`) that restarts discovery/broadcast when interface addresses change.
- **Cursor presence** — connected peers report their cursor line/column, shown in the peers drawer.
- Combined Settings dialog for device name and room.

### Changed
- Pinned `path_provider_android` to 2.2.23 (pre-JNI) via `dependency_overrides`, since `share_plus` transitively pulls `path_provider` and newer `path_provider_android` uses JNI, which breaks Linux desktop builds.
- Lowered Dart SDK constraint to `^3.10.0` and `bonsoir` to 6.x for Flutter 3.38 / Dart 3.10 toolchains.
- Removed leftover editor debug logging instrumentation and its hardcoded path.
- Committed Android Gradle wrapper scripts and tuned IDE Gradle memory defaults.
- Moved Flutter project contents to repository root.
- Switched note persistence implementation to `shared_preferences` for better Linux build compatibility.
- Hardened Linux CMake compiler selection and fallback behavior.

### Fixed
- Android Studio project load: restore `gradlew`, stop gitignoring wrapper scripts, and remove committed `android/build` artifacts.
- Linux discovery reliability improvements (re-resolve retries, endpoint handling, connect-time refresh).
- Linux build breakages caused by JNI transitive dependencies.
- Android Gradle compatibility issue with `bonsoir_android` Kotlin plugin application.
- Linux desktop build break from `share_plus`'s transitive `path_provider` implementations: pinned `path_provider_android` to 2.2.x (avoids `jni`) and `path_provider_foundation` to 2.4.x (avoids `objective_c` build hooks).
