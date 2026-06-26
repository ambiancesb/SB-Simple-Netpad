# SB Simple Netpad — Roadmap

Pragmatic phases from MVP toward a daily-use LAN notepad.

| Phase | Status | Focus |
|-------|--------|--------|
| **1** | Done | Manual IP connect, persist note to disk, rebroadcast on device rename |
| **2** | Done | Session token enforcement, connection log, pairing verification code |
| **3** | Done | Save/open/share files, network-change listener, room ID, cursor presence (CRDT deferred) |
| **4** | Planned | TLS / pinned peers, optional shared “room” ID |
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

- [ ] **TLS** or Noise handshake; pin key at pair time.
- [ ] **WSS upgrade milestone** — Ship plain ws -> wss as a standalone step before full Noise/pinning, since unencrypted ws:// is the current hard blocker for untrusted networks.
- [ ] **Revoke / block peer** — Drop a previously paired peer (and refuse re-pair) without restarting the app.
- [ ] Optional named **room** so not every instance on the LAN merges into one document.
- [ ] Queue edits offline; merge on reconnect with user prompt if diverged.

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
