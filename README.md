# SB Simple Netpad

A cross-platform LAN notepad built with Flutter. Instances on the same subnet discover each other, require mutual approval before connecting, and share note text with multi-peer relay sync.

**Status:** Beta — phases 1–9 of the roadmap are complete and the app is suitable for daily LAN use. Protocol and storage formats may still change before 1.0.

**Platforms:** Android, iOS, Windows, macOS, Linux (not web).

## Features

- Line-numbered plain-text editor ([`code_text_field`](https://pub.dev/packages/code_text_field))
- mDNS/Bonjour discovery via [`bonsoir`](https://pub.dev/packages/bonsoir) (`_sbnetpad._tcp`)
- Mutual pairing: the target device must tap **Accept** before sync starts
- Multi-peer: connect to several devices; edits relay through intermediaries to reach peers without a direct pairing
- **Multiple named notes**: manage many notes from the Notes drawer; each syncs independently and propagates create/rename/delete to peers
- **Version history**: per-note local snapshots you can restore after a remote edit overwrites your text
- **Search**: find within a note (next/prev) and search across all notes
- File workflows: **Save**, **Open** (as a new note), and **Share** the note from the File menu
- **Rooms**: peers only discover each other when they share the same session/room ID
- **Local network only**: sync is limited to peers on your device's active subnet(s); cellular-only devices pause discovery until Wi‑Fi is available
- **Cursor presence**: see which note each connected peer is editing, and where
- **Live conflict prompts**: simultaneous edits at the same revision ask which version to keep
- **Heartbeat**: unresponsive peers are disconnected automatically

## Requirements

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (stable, Dart 3.10+). The repo pins `bonsoir` 6.x for compatibility with Dart 3.10; upgrade to `bonsoir` 7.x after moving to Dart 3.11+.
- **Android Studio:** open this repository root (not `android/` alone), install the Flutter and Dart plugins, then run `flutter pub get` before the first Gradle sync.
- **Linux desktop build** (Flutter + CMake):

  ```bash
  sudo apt install -y clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev build-essential
  ```

  Linux builds require `clang++` on PATH (`sudo apt install -y clang`). Notes are stored via `shared_preferences` (not `path_provider`, which pulls Android JNI and breaks Linux desktop builds).

  If you see `Could not find the compiler specified in CXX: clang++`, either install `clang` (command above) or clear the variable and use GCC:

  ```bash
  unset CXX CC
  flutter run -d linux
  ```

- **Linux:** D-Bus and Avahi for discovery and advertising (required for finding peers):

  ```bash
  sudo apt install -y dbus avahi-daemon avahi-utils libnss-mdns
  sudo systemctl enable --now dbus avahi-daemon
  ```

  If the app logs `system_bus_socket` or peers never appear, confirm both services are running:

  ```bash
  systemctl is-active dbus avahi-daemon
  ```

  Manual **Connect by IP** still works when mDNS is unavailable. On Linux, if D-Bus is missing the app automatically falls back to direct mDNS (no Avahi required).

  If peers show as **Resolving…** or never appear:

  - Confirm both machines are on the same subnet (Wi‑Fi guest networks often block mDNS).
  - Check Avahi: `avahi-browse -rt _sbnetpad._tcp`
  - Allow UDP port **5353** (mDNS) and the app TCP port in the firewall.
  - Restart the app after network changes; discovery re-resolves every 12 seconds.

- **Desktop:** allow incoming connections on the app’s TCP port when the OS firewall prompts you
- **Windows desktop build:** requires Visual Studio with the **Desktop development with C++** workload (CMake + MSVC). Mobile dictation uses [`speech_to_text`](https://pub.dev/packages/speech_to_text), which builds on Windows without extra tools. Do **not** add [`flutter_tts`](https://pub.dev/packages/flutter_tts) unless you also install [NuGet CLI](https://www.nuget.org/downloads) (`winget install Microsoft.NuGet`) — that package’s Windows plugin requires `nuget.exe` even if you only use text-to-speech on Android/iOS.

## Build and run

```bash
flutter pub get
flutter run -d linux    # or windows, macos, android, ios
```

## Windows beta installer

To build a beta installer for testers (64-bit Windows 10+):

```powershell
.\scripts\build-windows-installer.ps1
```

This runs `flutter build windows --release` and writes artifacts to `dist/`:

| Output | Description |
|--------|-------------|
| `SB-Simple-Netpad-<version>-beta-windows-x64.zip` | Portable package — extract and run `Setup.cmd` |
| `SB-Simple-Netpad-<version>-beta-windows-x64-setup.exe` | Single-file installer (requires [Inno Setup 6+](https://jrsoftware.org/isinfo.php) on the build machine) |

The installer places the app under `%LOCALAPPDATA%\Programs\SB Simple Netpad`, adds a Start Menu shortcut, and registers an uninstall entry. Testers should allow Windows Firewall access on first launch so LAN peers can connect.

Use two or more devices on the same LAN (physical devices recommended for Android).

## Phase 1 features

- **Auto-save** — Your note is saved locally (via `shared_preferences`) and restored on launch.
- **Connect by IP** — In the peers drawer, use **Connect by IP** when mDNS discovery fails.
- **This device** — Copy your `IP:port` from the peers drawer to share with others.
- **Device rename** — Updates Bonsoir immediately (no restart).
- **Basic copy/paste** — Native text selection and clipboard actions are supported in the editor.

### Editor shortcuts

- **Desktop:** `Ctrl/Cmd + C`, `Ctrl/Cmd + V`, `Ctrl/Cmd + X`, `Ctrl/Cmd + A`
- **Mobile:** long-press to use selection toolbar Copy/Paste/Cut/Select All

## Phase 2 features

- **Session tokens** — Post-pair sync and disconnect messages carry the session token issued during pairing.
- **Connection log** — The peers drawer shows session-only connection and sync events, with a clear button.
- **Pairing verification code** — Incoming pairing requests show a short code to compare between devices before accepting.

## Phase 3 features

- **Save to file** — File menu → *Save to file…* writes the note to a chosen `.txt`/`.md` path.
- **Open file** — File menu → *Open file…* imports a text file into a **new** note (Phase 5); the new note syncs to connected peers like any other create.
- **Share note** — File menu → *Share note* opens the OS share sheet; on platforms without one (e.g. Linux) it falls back to copying to the clipboard.
- **Session / room ID** — Set in **Settings**. Only peers advertising the same room are discovered, so multiple groups can coexist on one LAN. Peers without a room are treated as the `default` room.
- **Cursor presence** — Connected peers report their cursor line/column, shown under each peer in the drawer.
- **Network change listener** — Discovery and broadcast restart automatically when network interfaces change (Wi‑Fi/VPN switches), not just on the periodic refresh.

On **Linux**, native file dialogs require `zenity` (GNOME) or `kdialog` (KDE):

```bash
sudo apt install -y zenity
```

> The note sync model is still full-document replace per note; incremental/CRDT sync remains deferred.

Phases 1–5 are complete. See [ROADMAP.md](ROADMAP.md) for Phase 6 and beyond.

## How pairing works

1. Open the **Peers** drawer (devices icon).
2. Under **Nearby**, tap **Connect** on a discovered instance.
3. On the other device, compare the verification code and accept the **Connection request** dialog.
4. After acceptance, both sides exchange a **document catalog** (every note’s id, title, and order), per-note snapshots, and then stream debounced updates.

**Trusted reconnect (Phase 9):** the first pair still requires **Accept**. Later reconnects to that device can proceed automatically when the stored auto-sync token and certificate pin match. Manage trusted devices in the peers drawer (**Trusted devices** section): toggle auto-sync per peer or **Revoke** to require Accept again (keeps the cert pin). **Block** remains stronger — it unpins and refuses all future pairing.

Rejected requests never receive document data.

## Sync behavior

- Each **note** has its own monotonic **revision**; edits send the full note text (debounced ~300 ms) tagged with `docId` and title.
- Newer revisions win per note; equal revisions tie-break by instance ID.
- Creating, renaming, reordering, or deleting a note propagates via `doc_create`, `doc_rename`, `doc_reorder`, and `doc_delete` so every peer’s Notes drawer stays aligned.
- When a peer receives an update, it may **relay** it to other connected peers (except the sender), so a device paired only with a hub still receives edits from the hub’s other connections.
- **Divergence on reconnect** (Phase 4) is evaluated per note: if your copy and a peer’s copy of the same note changed while disconnected, one device prompts you to keep yours or use theirs.

## Project layout

Main entry: [`lib/main.dart`](lib/main.dart).

Key Phase 5 modules:

| Area | Path |
|------|------|
| Workspace / multi-note | [`lib/data/repositories/workspace_repository.dart`](lib/data/repositories/workspace_repository.dart) |
| Per-note text + history | [`lib/data/repositories/document_repository.dart`](lib/data/repositories/document_repository.dart) |
| Notes drawer + search | [`lib/features/notes/notes_drawer.dart`](lib/features/notes/notes_drawer.dart) |
| Version history UI | [`lib/features/notes/version_history_sheet.dart`](lib/features/notes/version_history_sheet.dart) |
| Phase 5 tests | [`test/phase5_test.dart`](test/phase5_test.dart) |

## Phase 4 features (security)

- **Encrypted transport** — Peers communicate over `wss://` (TLS). Each device generates a persisted self-signed certificate on first launch.
- **Certificate pinning (TOFU)** — The first time you connect to a peer, its certificate fingerprint is pinned. If that fingerprint ever changes, the connection is refused (possible impersonation). The accepting device shows its own security code in the pairing dialog so you can compare.
- **Block / unblock peers** — From the peers drawer, block a device to disconnect it, forget its pinned certificate, and refuse future requests (both directions) until you unblock it. The blocklist persists across restarts.
- **Reconnect divergence prompt** — If your note and a peer's note changed differently while disconnected, on reconnect one device prompts you to keep yours or use theirs, and both devices converge on the choice.

## Phase 5 features (multiple documents) — complete

- **Multiple named notes** — Open the **Notes** drawer (top-left). Create with **+**, tap a note to switch, and use the per-note menu to **Rename**, view **Version history**, or **Delete**. The app bar shows the active note's title. Creating, renaming, and deleting a note propagates to every connected peer.
- **Per-note sync** — Each note carries a `docId` and title in its sync messages, so peers reconcile each note independently. On pairing, a `doc_catalog` lists every note name and order, then snapshots fill in content; live `doc_create` / `doc_rename` / `doc_reorder` / `doc_delete` messages keep the notes menu aligned while connected. Drag the handle beside a note to reorder (syncs to peers).
- **Version history** — Snapshots are captured automatically before a remote edit replaces your text, before a file import, and on throttled edit checkpoints (up to 50 per note). Restore any version from File → *Version history…* or the note's menu.
- **Search** — The toolbar search icon opens an in-note find bar with match count and next/previous navigation. The Notes drawer search box matches across all note titles and bodies and shows snippets.
- **Per-note presence** — The peers drawer shows which note each connected peer is editing, along with their cursor line/column.

> Notes are persisted in `shared_preferences` under a document index; a single note from Phases 1–4 is migrated automatically on first launch.

### Verifying Phase 5

```bash
flutter test test/phase5_test.dart   # workspace, history, catalog/order sync, search
flutter test                       # full suite
```

## Phase 6 features (sync robustness) — complete

- **Live conflict resolution** — If you and a peer edit the same note at the same revision simultaneously, one device (chosen deterministically) shows a dialog with previews of both versions. Choose **Keep mine** or **Use theirs**; both devices converge.
- **Protocol v2** — Pairing requires matching protocol version (`protocolVersion` in the pair handshake). Running mismatched builds refuses the connection; check the connection log for details.
- **Heartbeat** — Connected peers exchange `ping`/`pong` every 15 seconds. A peer that stops responding for 45 seconds is disconnected automatically.

```bash
flutter test test/phase6_test.dart   # protocol v2, live-conflict detection, heartbeat constants
```

## Threat model

SB Simple Netpad is a **peer-to-peer local-network notepad**. Notes live on your devices only — there is no central server, cloud account, or remote API. Security assumptions follow from that scope.

### Network policy

Netpad enforces three rules at the transport layer:

| Rule | What it means |
|------|----------------|
| **Active local subnet only** | Inbound and outbound connections must fall on a subnet derived from this device's current interfaces (for example the same `192.168.1.0/24` Wi‑Fi segment). Other private ranges — even other `192.168.x.x` subnets — are refused. VPN overlays (for example Tailscale) are allowed only on the subnet of the active VPN interface. |
| **Wi‑Fi first** | On cellular-only devices, peer sync is fully paused: no mDNS, no listening port, no periodic scans. Connect to Wi‑Fi or a personal hotspot first. A phone hotspot **is** a local network and works normally. |
| **Passive discovery only** | Netpad never scans IP ranges or probes random devices. It only listens for `_sbnetpad._tcp` mDNS announcements on the active LAN, and only advertises its own presence there. |
| **Netpad instances only** | Only clients that complete the Netpad pairing handshake (`pair_request` with matching protocol version) stay connected. Other inbound sockets are closed after a short timeout. |

**Connect by IP** remains available on the same subnet when mDNS fails (guest Wi‑Fi isolation, some VPNs). It still validates that the resolved address is on an active local subnet before dialing.

### In scope

| Assumption | Implication |
|------------|-------------|
| Same local network | Discovery (mDNS) and sync require devices on the same subnet or otherwise reachable on a private LAN. Cross-internet sync is not supported unless you provide a private overlay (for example Tailscale) whose addresses fall in the allowed ranges. |
| Mutual pairing | The **first** connection to a new peer requires tapping **Accept**. Trusted peers with a valid auto-sync token reconnect without the dialog. Unpaired connections cannot read or write notes. |
| Untrusted LAN peers | Other devices on the network might try to pair or interfere. Controls below apply to **peers on your LAN**, not anonymous internet hosts. |

### What we protect against

- **Non-local connections** — Inbound sockets from outside the active subnet are rejected; outbound dials to other subnets or public addresses are refused before pairing.
- **Cellular-only sync** — Peer sync is fully off on cellular data: no mDNS, no listen port, no subnet scanning. Discovery resumes when you join Wi‑Fi or a hotspot.
- **Unpaired access** — Rejected pairing requests never receive document data; post-pair messages require a session token.
- **Non-Netpad clients** — Inbound WebSockets that never send a valid `pair_request` are closed automatically.
- **Impersonation after first trust** — TLS (`wss://`) plus certificate pinning (TOFU): if a peer’s certificate fingerprint changes, the connection is refused.
- **Blocked devices** — Blocklist persists; blocked peers are disconnected and cannot reconnect until unblocked. Revoking auto-sync only forgets the reconnect token; the cert pin remains.
- **Trusted reconnect abuse** — Auto-sync requires a token issued at pair time plus a matching cert pin. Wrong token falls back to manual Accept; cert mismatch on a trusted reconnect is refused.
- **Spoofed disconnect** — `peer_disconnect` is honored only when the payload names the sender’s own peer id (multi-peer hub hardening).
- **Protocol mismatch** — Pairing requires matching protocol version; mismatched builds refuse the connection.
- **Stale peers** — Heartbeat disconnects unresponsive links automatically.

### Out of scope

These are intentional limits, not oversights:

- **No cloud or server storage** — Notes are not uploaded to a service you do not control. Backup, sync across the internet, and multi-site availability are your responsibility (e.g. Save to file, OS backup).
- **No internet attacker model** — Non-local addresses are refused at the socket layer; remote adversaries cannot reach the sync port through this app alone.
- **No multi-tenant isolation** — Room IDs filter discovery for convenience so groups on one LAN do not merge accidentally; they are **not** an authentication boundary. **Connect by IP** can still reach a peer on the same LAN if you know its address.
- **No CA-backed identity** — Certificates are self-signed per device. The first connection to a new peer is TOFU; compare the security code in the pairing dialog on untrusted networks.
- **Trusted paired peers** — Once you accept a peer, it can send sync traffic like any collaborator. A malicious paired peer could disrupt sync (e.g. overwrite notes, relay spam) — the same class of risk as sharing a folder with someone on the LAN. Pair only with devices you trust.

### Transport note

Traffic is encrypted with TLS (`wss://`) and peers are certificate-pinned on first use (TOFU). Because certificates are self-signed, the very first connection is trusted on first use — compare the security code shown in the pairing dialog if you are on an untrusted network. There is no central CA; trust is established per-device at pair time.

## Changelog

Project history is tracked in [`CHANGELOG.md`](CHANGELOG.md).

## Website

Project site (GitHub Pages from `docs/`):
[https://ambiancesb.github.io/SB-Simple-Netpad/](https://ambiancesb.github.io/SB-Simple-Netpad/)

## License

SB Simple Netpad is proprietary software distributed under an
[End User License Agreement (EULA)](LICENSE).

Hosted copy for store listings:
[https://ambiancesb.github.io/SB-Simple-Netpad/eula.html](https://ambiancesb.github.io/SB-Simple-Netpad/eula.html)

The shipped app is freemium: core editing and LAN sync are free (unlimited local notes, up to **3 synced notes** and **3 connected peers**); **Netpad Standard** is a one-time in-app purchase via the Apple App Store, Google Play, or Microsoft Store (RevenueCat on Apple/Google; Microsoft Store durable add-on on Windows). Linux builds stay on the free tier. Store console setup notes are in [`docs/STORE_FREEMIUM.md`](docs/STORE_FREEMIUM.md).
