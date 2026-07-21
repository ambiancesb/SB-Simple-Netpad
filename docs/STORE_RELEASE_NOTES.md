# Store release notes

Copy/adapt these into each store console “What’s New” field when uploading
**1.1.0**. Keep store text short; link to the app site or privacy URL for detail.

## Version

- App version: **1.1.0**
- Build / versionCode: **4** (`pubspec.yaml` → `1.1.0+4`)

## Suggested What’s New (English)

SB Simple Netpad 1.1.0 is ready for the stores.

- Stability fixes for peer discovery, sync reconnect, and trusted devices
- Fixes for iOS/macOS startup and Keychain/TLS identity handling
- Clearer free vs Netpad Standard limits and paywall / store links
- Localization fixes (including Portuguese) and About version branding

Free: unlimited local notes, up to 3 synced notes, 3 LAN peers, and 500 characters
per note. Netpad Standard is a one-time unlock for unlimited sync, peers, and
note length, plus skins, version history, trusted auto-sync, and voice dictation.

## Reviewer notes (paste into App Review / Play notes as needed)

- Core editing and same-subnet LAN sync work without purchase.
- Netpad Standard is a **one-time** non-consumable / durable unlock — not a subscription.
- Restore purchases is available in Settings and on the paywall.
- Peer sync requires Local Network / nearby Wi‑Fi permission and devices on the same Wi‑Fi (or hotspot).
- Demo: open the app on two devices on the same LAN, Accept pairing, edit a synced note.
- IAP product id: `netpad_pro` (display name Netpad Standard). RevenueCat entitlement: `pro`.

## Checklist before upload

See also [`STORE_FREEMIUM.md`](STORE_FREEMIUM.md).

- [ ] Release builds inject RevenueCat / store `--dart-define` keys (never commit secrets)
- [ ] `APPLE_APP_STORE_ID` set once the Apple listing id exists
- [ ] Screenshots and listing copy disclose freemium caps (including 500-character free limit)
- [ ] Privacy policy + custom EULA URLs set in each store console
- [ ] IAP / durable add-on `netpad_pro` active and linked in RevenueCat (Apple/Google)
- [ ] Microsoft Store MSIX + durable add-on published together (sideload builds cannot purchase)
- [ ] `flutter test` green on the release commit
- [ ] Smoke: free limits → paywall; purchase/restore on at least one store sandbox account
- [ ] Smoke: two-device LAN pair → sync → reconnect with trusted auto-sync (Standard)
