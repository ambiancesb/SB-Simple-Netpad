# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project currently tracks versions informally.

## [Unreleased]

### Added
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
- Linux troubleshooting notes and dependency setup script.
- Project roadmap in `ROADMAP.md`.

### Changed
- Moved Flutter project contents to repository root.
- Switched note persistence implementation to `shared_preferences` for better Linux build compatibility.
- Hardened Linux CMake compiler selection and fallback behavior.

### Fixed
- Linux discovery reliability improvements (re-resolve retries, endpoint handling, connect-time refresh).
- Linux build breakages caused by JNI transitive dependencies.
- Android Gradle compatibility issue with `bonsoir_android` Kotlin plugin application.
