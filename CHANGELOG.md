# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html)
for store releases.

## [Unreleased]

## [1.1.0] - 2026-07-21

App store launch release (`1.1.0+4`). Stability and release hygiene on top of the
1.0.0 freemium cut — not a new feature phase.

### Added
- Store “What’s New” template in [`docs/STORE_RELEASE_NOTES.md`](docs/STORE_RELEASE_NOTES.md).

### Changed
- Product version aligned to **1.1.0** (`pubspec.yaml`, About / `AppInfo`); retired
  in-app and docs **Beta / before 1.0** wording for store users.
- Windows sideload installer packaging no longer labels builds as Beta.
- Docs synced for wire **protocol v4**, freemium caps (including **500** characters
  per free note), and store build notes.

### Fixed
- Portuguese (`pt`) localization encoding mojibake in `app_pt.arb` / generated locals.
- Phase 5 tests updated for freemium default (new notes are local-only until sync is enabled).
- Mobile overflow menu and Notes drawer layout issues.
- Apple Keychain / TLS identity handling on iOS; macOS prefs path for local signing.
- Peer discovery, stale peers, and trusted reconnect / auto-token edge cases.
- iOS and macOS black-window startup; macOS CocoaPods install friction.
- Sync remediation after reconnect; speech-to-text / IME voice freemium gating.
- Paywall and store-listing fallback links when IAP is unavailable.

## [1.0.0] - 2026-07-11

First store-ready freemium cut: Phase 1–9 LAN notepad plus in-app purchase unlock.

### Added
- **Netpad Standard** one-time unlock (`netpad_pro` / RevenueCat entitlement `pro`)
  on Apple App Store, Google Play, and Microsoft Store (WinRT durable add-on).
- Free-tier caps: unlimited local notes; **3** synced notes; **3** connected peers;
  **500** characters per note. Standard unlocks unlimited sync/peers/length plus
  skins, version history, trusted auto-sync, and voice dictation.
- Store packaging notes and checklists in [`docs/STORE_FREEMIUM.md`](docs/STORE_FREEMIUM.md).
- Apple packaging: Privacy manifests, export-compliance keys, iOS entitlements,
  macOS Hardened Runtime, productivity category.
- Public site, privacy policy, and EULA on GitHub Pages (`docs/`).
- Multi-language UI localization (ARB / `flutter gen-l10n`).
- **Trusted peers and auto-sync (Phase 9)** — persistent auto-sync token with cert
  pin; Trusted devices UI; protocol **v3** then **v4** wire messages.
- **Per-note sync toggle**, local-subnet enforcement, Wi‑Fi-first sync policy,
  Netpad-only inbound guard, live conflict prompts, heartbeat.
- Windows installer script for sideload / tester packages
  (`scripts/build-windows-installer.ps1`).

### Changed
- Package / bundle id **`com.spencerbeaumier.sbnetpad`** across store platforms.
- Product naming: in-app **Netpad Standard** (legacy store SKU id `netpad_pro`).
- RevenueCat: prefer `REVENUECAT_IOS_API_KEY` / `REVENUECAT_MACOS_API_KEY`
  (legacy `REVENUECAT_APPLE_API_KEY` fallback).

## Pre-store development history

The following milestones used informal `1.x` labels during beta development.
They are retained for context and are **not** store version numbers.

### 2026-06-30 — Multi-document / Phase 5 (was labeled 1.2.0)

Phase 5 complete: multiple documents, per-note history, and search.

#### Added
- **Multiple named notes** — Notes drawer CRUD; sync via `doc_create` / `doc_rename` /
  `doc_delete` / `doc_catalog`.
- **Note history / versioning** — Bounded local snapshot ring; restore from Version history.
- **Search** — In-note find bar and cross-note search with snippets.
- **Note order sync** — Drag-to-reorder via `doc_reorder`.
- **Per-note presence** — Peers drawer shows which note a peer is editing.
- **Phase 5 test suite** — [test/phase5_test.dart](test/phase5_test.dart).

#### Changed
- Storage reworked to multi-document layout; legacy single note migrates on launch.
- "Open file" imports into a **new** note.

#### Fixed
- `code_text_field` range crash when a remote update grew a note by one character.

### 2026-06-15 — TLS / Phase 4 (was labeled 1.1.1)

Phase 4 complete: TLS transport, certificate pinning, peer blocking, reconnect divergence.

#### Added
- **TLS transport** — self-signed certs; `wss://` peer traffic.
- **Certificate pinning (TOFU)** — fingerprint pin on first connect.
- **Block / unblock peers** — persisted blocklist in the peers drawer.
- **Reconnect divergence prompt** — Keep mine / Use theirs.

#### Changed
- `path_provider_android` / `path_provider_foundation` overrides for desktop host builds.

### 2026-06-04 — Early beta scaffold (was labeled 1.1.0)

#### Added
- Flutter scaffold for Android, iOS, Windows, and macOS.
- Line-numbered editor, Bonsoir discovery (`_sbnetpad._tcp`), Accept/Reject pairing.
- Multi-peer sync, peers drawer, Connect by IP, auto-save, rooms, cursor presence.
- Save / Open / Share file workflows; Settings for device name and room.

#### Fixed
- Discovery reliability, Android Gradle / Bonsoir compatibility, desktop JNI transitive breaks.
