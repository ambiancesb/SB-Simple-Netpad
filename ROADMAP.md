# SB Simple Netpad — Roadmap

Pragmatic phases from MVP toward a daily-use LAN notepad.

| Phase | Status | Focus |
|-------|--------|--------|
| **1** | Done | Manual IP connect, persist note to disk, rebroadcast on device rename |
| **2** | Done | Session token enforcement, connection log, pairing verification code |
| **3** | Planned | Save/share files, incremental sync or CRDT, network-change listener |
| **4** | Planned | TLS / pinned peers, optional shared “room” ID |

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

- [ ] **Save to file** — Export the note to a user-chosen path (e.g. `.txt`) via the platform save/open dialog; optional “Save as” from the editor menu.
- [ ] **Share note** — Send the current note (or exported file) through the OS share sheet on mobile and a desktop share/export action (email, Drive, adjacent apps, etc.).
- [ ] **Open from file** — Load text from an existing file into the editor (with prompt if it would replace the live synced note).
- [ ] **Incremental sync** (insert/delete ranges) or small CRDT instead of full-document replace.
- [ ] **Network change listener** — Restart discovery/broadcast when interfaces change (not only periodic refresh).
- [ ] Optional cursor / presence (who is connected).
- [ ] Explicit **session / room ID** in TXT records for predictable groups.

---

## Phase 4 — Security and structure

**Goal:** Safer on untrusted LANs and clearer multi-peer semantics.

- [ ] **TLS** or Noise handshake; pin key at pair time.
- [ ] Optional named **room** so not every instance on the LAN merges into one document.
- [ ] Queue edits offline; merge on reconnect with user prompt if diverged.

---

## Out of scope (for now)

- Web platform
- Cloud relay / WAN
- Rich document formats (Markdown preview, Office, PDF) beyond plain text export

---

## References

- Product overview: [README.md](README.md)
- Entry point: [lib/main.dart](lib/main.dart)
