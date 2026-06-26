# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project currently tracks versions informally.

## [Unreleased]

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
