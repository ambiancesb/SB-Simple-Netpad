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
- **Linux:** Avahi for discovery and advertising:

  ```bash
  sudo apt install -y avahi-daemon avahi-utils libnss-mdns
  ```

- **Desktop:** allow incoming connections on the app’s TCP port when the OS firewall prompts you

## Build and run

```bash
cd netpad
flutter pub get
flutter run -d linux    # or windows, macos, android, ios
```

Use two or more devices on the same LAN (physical devices recommended for Android).

## How pairing works

1. Open the **Peers** drawer (devices icon).
2. Under **Nearby**, tap **Connect** on a discovered instance.
3. On the other device, accept the **Connection request** dialog.
4. After acceptance, both sides exchange a document snapshot and stream debounced updates.

Rejected requests never receive document data.

## Sync behavior

- Each edit bumps a monotonic **revision**; the full document text is sent (debounced ~300 ms).
- Newer revisions win; equal revisions tie-break by instance ID.
- When a peer receives an update, it may **relay** it to other connected peers (except the sender), so a device paired only with a hub still receives edits from the hub’s other connections.

## Project layout

Flutter app lives in [`netpad/`](netpad/). Main entry: [`netpad/lib/main.dart`](netpad/lib/main.dart).

## Security note

v1 uses unencrypted `ws://` on the local network. Do not use on untrusted networks.
