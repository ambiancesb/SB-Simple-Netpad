# SB Simple Netpad — Roadmap

Pragmatic phases from MVP toward a daily-use LAN notepad.

| Phase | Status | Focus |
|-------|--------|--------|
| **1** | Done | Manual IP connect, persist note to disk, rebroadcast on device rename |
| **2** | Done | Session token enforcement, connection log, pairing verification code |
| **3** | Done | Save/open/share files, network-change listener, room ID, cursor presence (CRDT deferred) |
| **4** | Done | wss/TLS with pinned certs (TOFU), revoke/block peer, reconnect divergence prompt |
| **5** | Done | Multiple documents, note history, search |
| **6** | Done | Conflict UI, protocol version negotiation, heartbeat |
| **7** | Done | UX polish: find/replace, settings, theme, share sheet |
| **8** | In progress | Code health: sync/relay tests (debug cruft removed) |
| **9** | Planned | Trusted peers and auto-sync tokens (reconnect without re-pairing) |

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

- [x] **Multiple named notes** — A [WorkspaceRepository](lib/data/repositories/workspace_repository.dart) owns many notes; every `docSnapshot` / `docUpdate` / `presence` / `docDelete` payload carries a `docId` (+ title). Explicit `doc_create`, `doc_rename`, `doc_catalog`, and `doc_reorder` messages keep note names and drawer order in sync across peers (catalog + order on pair; live reorder via drag handles).
- [x] **Note history / versioning** — Each note keeps a bounded local snapshot ring (`HistoryEntry`), captured before a remote edit clobbers local text, before file open/restore, and on throttled edit checkpoints. Restore from the per-note **Version history** sheet.
- [x] **Search** — In-note find bar (match count + next/prev) and cross-note search in the Notes drawer (matches titles + bodies with snippets).
- [x] **Per-note presence** — Cursor/presence payloads include `docId`; the peers drawer shows which note each peer is editing.
- [x] **Automated verification** — [test/phase5_test.dart](test/phase5_test.dart) covers history capture/restore, workspace CRUD, catalog merge, order sync, and cross-note search (14 tests; run `flutter test test/phase5_test.dart`).

> Sync model remains full-document replace per note; incremental/CRDT sync stays deferred.

---

## Phase 6 — Sync robustness and protocol — Done

**Goal:** Avoid silent data loss and brittle wire compatibility.

- [x] **Conflict resolution UI** — Live same-revision edit collisions prompt "Keep mine / Use theirs" with text previews (deterministic prompt side); reconnect divergence dialog unchanged from Phase 4.
- [x] **Protocol version negotiation** — `protocolVersion` in pair handshake; strict match required (`kProtocolVersion` = 2); incompatible peers refused with a connection-log entry.
- [x] **Heartbeat / dead-peer detection** — `ping`/`pong` every 15s on authenticated links; disconnect after 45s without reply.
- [x] **Automated verification** — [test/phase6_test.dart](test/phase6_test.dart) covers protocol v2 encoding, live-conflict detection, and heartbeat constants.

---

## Phase 7 — UX and platform polish — Done

**Goal:** Make daily editing pleasant across platforms.

- [x] **Editor tools** — Find/replace, word-wrap toggle, adjustable font size (via `code_text_field`).
- [x] **Settings screen** consolidating device name, port, and theme.
- [x] **Dark/light theme** switch.
- [x] **Mobile share sheet** integration (complements the Phase 3 save/share work).
- [x] **Automated verification** — [test/phase7_test.dart](test/phase7_test.dart) covers find/replace helpers and preference persistence.

---

## Phase 8 — Code health and quality

**Goal:** Reduce maintenance risk and harden the sync core.

- [x] **Remove debug logging cruft** — Removed the `#region agent log` blocks and hardcoded debug path from [lib/features/editor/editor_screen.dart](lib/features/editor/editor_screen.dart).
- [ ] **Sync/relay tests** — Cover multi-peer relay and divergence merge end-to-end (phase 1–5 unit tests cover pairing code, connection log, cursor math, TLS/trust, and workspace/history/search).

---

## Phase 9 — Trusted peers and auto-sync

**Goal:** Reconnect and sync with devices you have already paired, without tapping **Accept** every time — while staying LAN-only, peer-to-peer, and revocable. See [Threat model](README.md#threat-model) in the README.

Today, each new TCP link requires manual pairing even when the peer’s certificate is already pinned. Phase 9 adds a **persistent auto-sync token** (distinct from the ephemeral per-connection `sessionToken` issued on Accept).

### Design

| Concept | Lifetime | Purpose |
|---------|----------|---------|
| **Session token** | One connection | Gates post-pair sync messages (unchanged) |
| **Cert pin** | Persistent | TOFU TLS identity (unchanged) |
| **Auto-sync token** | Persistent until revoked | Skips the Accept dialog on reconnect when token + pin match |

**First pair (unchanged UX):** user taps **Accept** → both sides store `autoSyncToken` keyed by `peerId` alongside the cert pin.

**Later reconnect:** outbound `pair_request` includes `autoSyncToken`; inbound side auto-accepts when token matches stored value, cert pin matches, peer is not blocked, and protocol version matches — then issues a fresh session token and runs catalog + sync as today.

**Fallback:** wrong or missing token, cert mismatch, or blocked peer → normal Accept dialog or refusal (no weaker path).

- [ ] **TrustStore: trusted peers** — Persist `peerId → { displayName, autoSyncToken, pairedAt }` in [lib/data/repositories/trust_store.dart](lib/data/repositories/trust_store.dart). Blocklist still wins over auto-sync.
- [ ] **Issue token on Accept** — Generate a random token (32+ bytes) in [lib/data/repositories/sync_repository.dart](lib/data/repositories/sync_repository.dart) when pairing completes; store on both sides via `pair_complete` (protocol v3 bump).
- [ ] **Auto-accept reconnect** — Inbound and outbound paths: if stored token + pin validate, skip the pairing dialog and complete pairing automatically. Optional: rotate token on each successful pair.
- [ ] **Background reconnect** — When a trusted peer appears in discovery (or after network change), initiate connect without user action; show a lightweight “Reconnected to …” notice in the peers drawer / connection log.
- [ ] **Trusted devices UI** — Settings or peers drawer: list trusted peers, per-peer auto-sync toggle, **Revoke** (forget token; require Accept again without necessarily unpinning), distinct from **Block**.
- [ ] **`peer_disconnect` hardening** — Only honor disconnect when payload `peerId` matches the sender (closes LAN peer-abuse gap on multi-peer hubs).
- [ ] **Automated verification** — `test/phase9_test.dart`: token persistence, auto-accept when token + pin match, fallback to manual pair when token wrong or revoked, blocklist overrides auto-sync.

### Deferred (post–Phase 9)

- [ ] **One-time invite token** — Generate a QR or short code in Settings for pairing a new device without mDNS (still requires first Accept or pre-shared invite secret).
- [ ] **Per-device “always ask”** — Trusted but never auto-connect until user taps Connect.

---

## Out of scope (for now)

- Web platform
- Cloud relay / WAN
- Rich document formats (Markdown preview, Office, PDF) beyond plain text export
- Image / attachment sync between peers (notes stay plain text)

---

## References

- Product overview: [README.md](README.md)
- Entry point: [lib/main.dart](lib/main.dart)
