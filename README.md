# SB Simple Netpad

A cross-platform LAN notepad built with Flutter. Instances on the same subnet discover each other, require mutual approval before connecting, and share note text with multi-peer relay sync.

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
- **Cursor presence**: see which note each connected peer is editing, and where

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

- **Linux:** Avahi for discovery and advertising (required for finding peers):

  ```bash
  sudo apt install -y avahi-daemon avahi-utils libnss-mdns
  sudo systemctl enable --now avahi-daemon
  ```

  If peers show as **Resolving…** or never appear:

  - Confirm both machines are on the same subnet (Wi‑Fi guest networks often block mDNS).
  - Check Avahi: `avahi-browse -rt _sbnetpad._tcp`
  - Allow UDP port **5353** (mDNS) and the app TCP port in the firewall.
  - Restart the app after network changes; discovery re-resolves every 12 seconds.

- **Desktop:** allow incoming connections on the app’s TCP port when the OS firewall prompts you

## Build and run

```bash
flutter pub get
flutter run -d linux    # or windows, macos, android, ios
```

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
- **Open file** — File menu → *Open file…* loads a text file; if the current note is non-empty it prompts before replacing, then broadcasts to connected peers.
- **Share note** — File menu → *Share note* opens the OS share sheet; on platforms without one (e.g. Linux) it falls back to copying to the clipboard.
- **Session / room ID** — Set in **Settings**. Only peers advertising the same room are discovered, so multiple groups can coexist on one LAN. Peers without a room are treated as the `default` room.
- **Cursor presence** — Connected peers report their cursor line/column, shown under each peer in the drawer.
- **Network change listener** — Discovery and broadcast restart automatically when network interfaces change (Wi‑Fi/VPN switches), not just on the periodic refresh.

On **Linux**, native file dialogs require `zenity` (GNOME) or `kdialog` (KDE):

```bash
sudo apt install -y zenity
```

> The note sync model is still full-document replace; incremental/CRDT sync remains deferred.

See [ROADMAP.md](ROADMAP.md) for planned phases.

## How pairing works

1. Open the **Peers** drawer (devices icon).
2. Under **Nearby**, tap **Connect** on a discovered instance.
3. On the other device, compare the verification code and accept the **Connection request** dialog.
4. After acceptance, both sides exchange a document snapshot and stream debounced updates.

Rejected requests never receive document data.

## Sync behavior

- Each edit bumps a monotonic **revision**; the full document text is sent (debounced ~300 ms).
- Newer revisions win; equal revisions tie-break by instance ID.
- When a peer receives an update, it may **relay** it to other connected peers (except the sender), so a device paired only with a hub still receives edits from the hub’s other connections.

## Project layout

Main entry: [`lib/main.dart`](lib/main.dart).

## Phase 4 features (security)

- **Encrypted transport** — Peers communicate over `wss://` (TLS). Each device generates a persisted self-signed certificate on first launch.
- **Certificate pinning (TOFU)** — The first time you connect to a peer, its certificate fingerprint is pinned. If that fingerprint ever changes, the connection is refused (possible impersonation). The accepting device shows its own security code in the pairing dialog so you can compare.
- **Block / unblock peers** — From the peers drawer, block a device to disconnect it, forget its pinned certificate, and refuse future requests (both directions) until you unblock it. The blocklist persists across restarts.
- **Reconnect divergence prompt** — If your note and a peer's note changed differently while disconnected, on reconnect one device prompts you to keep yours or use theirs, and both devices converge on the choice.

## Phase 5 features (multiple documents)

- **Multiple named notes** — Open the **Notes** drawer (top-left). Create with **+**, tap a note to switch, and use the per-note menu to **Rename**, view **Version history**, or **Delete**. The app bar shows the active note's title. Creating, renaming, and deleting a note propagates to every connected peer.
- **Per-note sync** — Each note carries a `docId` and title in its sync messages, so peers reconcile each note independently. On pairing, a `doc_catalog` lists every note name and order, then snapshots fill in content; live `doc_create` / `doc_rename` / `doc_reorder` / `doc_delete` messages keep the notes menu aligned while connected. Drag the handle beside a note to reorder (syncs to peers).
- **Version history** — Snapshots are captured automatically before a remote edit replaces your text, before a file import, and on throttled edit checkpoints (up to 50 per note). Restore any version from File → *Version history…* or the note's menu.
- **Search** — The toolbar search icon opens an in-note find bar with match count and next/previous navigation. The Notes drawer search box matches across all note titles and bodies and shows snippets.

> Notes are persisted in `shared_preferences` under a document index; a note from earlier versions is migrated automatically on first launch.

## Security note

Traffic is encrypted with TLS (`wss://`) and peers are certificate-pinned on first use (TOFU). Because certificates are self-signed, the very first connection is trusted on first use — compare the security code shown in the pairing dialog if you are on an untrusted network. There is no central CA; trust is established per-device at pair time.

## Changelog

Project history is tracked in [`CHANGELOG.md`](CHANGELOG.md).

## License

All rights reserved for now. See [`LICENSE`](LICENSE).
