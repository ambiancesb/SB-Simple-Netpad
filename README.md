# SB Simple Netpad

A cross-platform LAN notepad built with Flutter. Instances on the same subnet discover each other, require mutual approval before connecting, and share note text with multi-peer relay sync.

**Platforms:** Android, iOS, Windows, macOS, Linux (not web).

## Features

- Line-numbered plain-text editor ([`code_text_field`](https://pub.dev/packages/code_text_field))
- mDNS/Bonjour discovery via [`bonsoir`](https://pub.dev/packages/bonsoir) (`_sbnetpad._tcp`)
- Mutual pairing: the target device must tap **Accept** before sync starts
- Multi-peer: connect to several devices; edits relay through intermediaries to reach peers without a direct pairing

## Requirements

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (stable)
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

## Security note

v1 uses unencrypted `ws://` on the local network. Do not use on untrusted networks.

## Changelog

Project history is tracked in [`CHANGELOG.md`](CHANGELOG.md).

## License

All rights reserved for now. See [`LICENSE`](LICENSE).
