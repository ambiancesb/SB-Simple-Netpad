# Store freemium setup

One Flutter binary unlocks **Netpad Pro** (`pro` entitlement) via a one-time product id `netpad_pro`.

App package / bundle id (all store platforms): **`com.spencerbeaumier.sbnetpad`**

Free tier caps (enforced in app):

| Cap | Free | Pro |
|-----|------|-----|
| Local note creation | **3** notes | Unlimited |
| Simultaneous connected peers | **3** peers | Unlimited |

Synced notes received from peers may push the note count above 3 on free; the cap only blocks **creating** additional local notes (and importing a file as a new note). Peer cap counts **authenticated** sessions only.

## Products

| Store | Product id | Type |
|-------|------------|------|
| Apple App Store (iOS + macOS) | `netpad_pro` | Non-consumable |
| Google Play | `netpad_pro` | One-time / managed product |
| Microsoft Store | `netpad_pro` | Durable add-on |

Use the **same** product id on every store so RevenueCat / in-app copy stay aligned.

## Free vs Pro (shipping matrix)

| Free | Pro |
|------|-----|
| Editing, discovery, pairing, sync | Unlimited notes (free create capped at 3) |
| Up to 3 connected peers | Unlimited connected peers |
| Default skin + light/dark | Extra skins |
| Find/replace, share/export | Version history |
| Manual reconnect | Trusted peer auto-sync |
| | Voice dictation |

## RevenueCat (Apple + Google)

1. Create a RevenueCat project and apps for iOS, Android, and macOS.
2. Create entitlement **`pro`** and attach each store product to it.
3. Create offering **`default`** containing the Pro package (this is what the SDK looks up).
4. Pass public SDK keys at build time (never commit them):

```bash
flutter run \
  --dart-define=REVENUECAT_APPLE_API_KEY=appl_xxx \
  --dart-define=REVENUECAT_GOOGLE_API_KEY=goog_xxx
```

CI / release builds should inject the same `--dart-define` values (or equivalent Flutter flavor / env wiring).

### Android App Bundle

```bash
flutter build appbundle --release \
  --dart-define=REVENUECAT_GOOGLE_API_KEY=goog_xxx
```

Output: `build/app/outputs/bundle/release/app-release.aab`

Release signing uses `android/key.properties` + `android/upload-keystore.jks` (both gitignored). Back those up securely — losing the upload key blocks Play updates unless you use Play App Signing recovery.

### Store Console ↔ RevenueCat checklist

**Apple (App Store Connect)**

1. Create Non-Consumable IAP `netpad_pro` for the iOS app (and macOS if sold separately).
2. Attach pricing, localization, and review screenshots for the IAP.
3. In RevenueCat: link App Store Connect API key / shared secret as required by RC docs.
4. Map product `netpad_pro` → entitlement `pro` → offering `default`.

**Google Play Console**

1. Create a one-time (managed) product `netpad_pro`.
2. Activate the product and set base plans / pricing for each country.
3. In RevenueCat: upload the Play service account JSON with billing permission.
4. Map product `netpad_pro` → entitlement `pro` → offering `default`.

Until products are **approved / active** in the store and linked in RevenueCat, the paywall shows a generic “Buy Pro” label (no localized price) or purchase fails.

## Microsoft Store

RevenueCat does not support Windows. Pro is checked through WinRT `StoreContext` (`windows/runner/store_plugin.cpp`).

- Package the Windows build as **MSIX** with a Partner Center identity (sideload / Inno Setup builds cannot purchase).
- Create durable add-on `netpad_pro` and publish it with the app.
- Purchases and license checks only work inside the Store-signed MSIX.

## Listing copy & review notes

Disclose freemium clearly in each store listing so review does not treat caps as a surprise paywall:

Suggested short description snippet:

> Free: up to 3 notes and 3 connected LAN peers. Unlock Netpad Pro once for unlimited notes and peers, skins, version history, trusted auto-sync, and voice dictation.

Suggested “What’s New” / privacy / monetization notes:

- Core editing and same-subnet LAN sync work without purchase.
- Pro is a **one-time** unlock, not a subscription.
- Restore purchases is available in Settings and on the paywall.
- Linux builds stay on the free tier (no store billing).

For Apple review, have a demo account / LAN pair of devices ready if they ask how sync works; freemium gates are local and do not require a login.

## EULA (custom license for stores)

The store build ships under an **End User License Agreement**, not an open-source license.

| Artifact | Location |
|----------|----------|
| Site home | https://ambiancesb.github.io/SB-Simple-Netpad/ |
| Repo EULA | [`LICENSE`](../LICENSE) |
| Hosted EULA | https://ambiancesb.github.io/SB-Simple-Netpad/eula.html |
| Privacy | https://ambiancesb.github.io/SB-Simple-Netpad/privacy.html |

**Apple App Store Connect**

1. App Information → License Agreement → choose **Custom EULA** (or “Apply a custom EULA”).
2. Paste the full text from `LICENSE` / `docs/eula.html`, or point reviewers at the hosted URL if the console asks for a link.
3. Keep Privacy Policy URL set to the hosted privacy page.

**Google Play Console**

1. Store listing → Privacy policy → privacy URL above.
2. There is no separate “custom EULA” field like Apple’s; include a Terms / EULA link in the store description or in-app About (the app already links to the hosted EULA).

**Microsoft Partner Center**

1. Product → Properties / Store listings → add Privacy policy URL.
2. Add the EULA URL in listing notes or support documentation as required for your category.

Push `docs/eula.html` to the branch that feeds GitHub Pages before submitting builds that reference the URL.

## Debug override

```bash
flutter run --dart-define=NETPAD_PRO_OVERRIDE=true
```

Forces Pro without talking to a store (useful for UI testing). In VS Code / Cursor, use the **SB Simple Netpad (Pro unlock)** launch config.

In **debug builds only**, Settings also has **Unlock Pro (debug)** — a toggle that persists locally and is stripped from release.

## Code touchpoints

| Concern | Location |
|---------|----------|
| Cap values | `lib/services/entitlements/entitlement_constants.dart` |
| Gate logic | `lib/services/entitlements/pro_features.dart` |
| Paywall UI | `lib/features/entitlements/pro_gate.dart`, `paywall_sheet.dart` |
| Peer hard stop | `SyncRepository.connectAndRequestPair` / inbound accept |
| Apple/Google billing | `revenue_cat_backend.dart` + `purchases_flutter` |
| Windows billing | `windows_store_backend.dart` + `windows/runner/store_plugin.cpp` |
