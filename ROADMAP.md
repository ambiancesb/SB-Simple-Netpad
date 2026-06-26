# SB Simple Netpad — Roadmap

Pragmatic phases from MVP toward a daily-use LAN notepad.

| Phase | Status | Focus |
|-------|--------|--------|
| **1** | Done | Manual IP connect, persist note to disk, rebroadcast on device rename |
| **2** | Done | Session token enforcement, connection log, pairing verification code |
| **3** | Done | Save/open/share files, network-change listener, room ID, cursor presence (CRDT deferred) |
| **4** | Done | wss/TLS with pinned certs (TOFU), revoke/block peer, reconnect divergence prompt |
| **5** | Planned | Multiple documents, note history, search |
| **6** | Planned | Conflict UI, protocol version negotiation, heartbeat |
| **7** | Planned | UX polish: find/replace, settings, theme, share sheet |
| **8** | Planned | Code health: remove debug cruft, sync/relay tests |

---

## Phase 1 — Reliable solo use and fallback connect

**Goal:** The app is useful alone and works when mDNS fails.

- [x] **Manual IP connect** — Enter host + port in the peers drawer when Bonjour discovery does not find peers (guest Wi‑Fi, VPN, etc.).
- [x] **Persist note to disk** — Auto-save via `shared_preferences`; restore on launch (migrates legacy file if present).
- [x] **Rebroadcast on rename** — Changing device name updates Bonsoir immediately (no app restart).
- [x] **Copy this device’s address** — Show LAN IP + port in peers drawer for sharing with others.

---

## Phase 2 — Trust and observability

**Goal:** Safer pairing and easier LAN debugging.

- [x] Enforce `sessionToken` on all post-pair WebSocket messages.
- [x] **Connection log** in peers drawer (connect, disconnect, resolve failures, last sync revision).
- [x] **Pairing code** — Short code derived from `instanceId` shown on both devices during Accept.
- [x] **Basic copy/paste support** — Native selection toolbar + keyboard shortcuts (`Ctrl/Cmd + C/V/X/A`) in the editor.

---

## Phase 3 — Better collaboration

**Goal:** Smoother multi-peer editing, file workflows, and network resilience.

- [x] **Save to file** — Export the note to a user-chosen path (`.txt`/`.md`) via the platform save dialog (File menu).
- [x] **Share note** — Send the current note through the OS share sheet (mobile/desktop), falling back to clipboard where no share sheet exists (e.g. Linux).
- [x] **Open from file** — Load text from a file into the editor; prompts before replacing a non-empty note, then broadcasts the change to connected peers.
- [ ] **Incremental sync** (insert/delete ranges) or small CRDT instead of full-document replace. *(Deferred — kept full-document replace for now.)*
- [x] **Network change listener** — `NetworkMonitor` restarts discovery/broadcast when interface addresses change (not only on the periodic refresh timer).
- [x] Optional cursor / presence — connected peers report cursor line/column, shown in the peers drawer.
- [x] Explicit **session / room ID** in TXT records; only peers in the same room are discovered (editable in Settings).

---

## Phase 4 — Security and structure

**Goal:** Safer on untrusted LANs and clearer multi-peer semantics.

- [x] **TLS** — Each device generates a persisted self-signed certificate and serves `wss://`. Peers pin the certificate fingerprint on first connect (TOFU); a mismatch later refuses the connection. (Noise handshake not pursued — TLS covers the channel.)
- [x] **WSS upgrade milestone** — All peer traffic is now `wss://` instead of `ws://`.
- [x] **Revoke / block peer** — Block from the peers drawer: disconnects, forgets the pinned cert, and refuses re-pair (inbound + outbound) until unblocked. Blocklist persists.
- [x] Optional named **room** so not every instance on the LAN merges into one document. *(Delivered in Phase 3.)*
- [x] Queue edits offline; merge on reconnect with user prompt if diverged — offline edits persist and bump the revision; on reconnect the snapshot exchange detects divergence and prompts (Keep mine / Use theirs) on one deterministic side so both devices converge.

---

## Phase 5 — Multiple documents and content

**Goal:** Move beyond a single shared note.

- [ ] **Multiple named notes / tabs** — Today there is one global note in [lib/data/repositories/document_repository.dart](lib/data/repositories/document_repository.dart); requires a document ID in `docSnapshot` / `docUpdate` payloads.
- [ ] **Note history / versioning** — Local snapshots to recover text clobbered by "newer revision wins".
- [ ] **Search** within and across notes.

---

## Phase 6 — Sync robustness and protocol

**Goal:** Avoid silent data loss and brittle wire compatibility.

- [ ] **Conflict resolution UI** — "Your version vs theirs" instead of silent tie-break by instance ID.
- [ ] **Protocol version negotiation** — Handshake on connect; today `v:1` is hardcoded in [lib/core/constants.dart](lib/core/constants.dart) and [lib/core/models/protocol_message.dart](lib/core/models/protocol_message.dart).
- [ ] **Heartbeat / dead-peer detection** — Prune half-open WebSockets.

---

## Phase 7 — UX and platform polish

**Goal:** Make daily editing pleasant across platforms.

- [ ] **Editor tools** — Find/replace, word-wrap toggle, adjustable font size (via `code_text_field`).
- [ ] **Settings screen** consolidating device name, port, and theme.
- [ ] **Dark/light theme** switch.
- [ ] **Mobile share sheet** integration (complements the Phase 3 save/share work).

---

## Phase 8 — Code health and quality

**Goal:** Reduce maintenance risk and harden the sync core.

- [x] **Remove debug logging cruft** — Removed the `#region agent log` blocks and hardcoded debug path from [lib/features/editor/editor_screen.dart](lib/features/editor/editor_screen.dart).
- [ ] **Sync/relay tests** — Cover the merge and relay logic (currently only pairing code, connection log, and cursor math are tested).

---

## Out of scope (for now)

- Web platform
- Cloud relay / WAN
- Rich document formats (Markdown preview, Office, PDF) beyond plain text export

---

## References

- Product overview: [README.md](README.md)
- Entry point: [lib/main.dart](lib/main.dart)
