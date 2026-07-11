# Store freemium setup

One Flutter binary unlocks **Netpad Pro** (`pro` entitlement) via a one-time product id `netpad_pro`.

## Products

| Store | Product id | Type |
|-------|------------|------|
| Apple App Store (iOS + macOS) | `netpad_pro` | Non-consumable |
| Google Play | `netpad_pro` | One-time / managed product |
| Microsoft Store | `netpad_pro` | Durable add-on |

## RevenueCat (Apple + Google)

1. Create a RevenueCat project and apps for iOS, Android, and macOS.
2. Attach store products to entitlement **`pro`**.
3. Create offering **`default`** containing the Pro package.
4. Pass public SDK keys at build time:

```bash
flutter run \
  --dart-define=REVENUECAT_APPLE_API_KEY=appl_xxx \
  --dart-define=REVENUECAT_GOOGLE_API_KEY=goog_xxx
```

Never commit API keys.

## Microsoft Store

RevenueCat does not support Windows. Pro is checked through WinRT `StoreContext` (`windows/runner/store_plugin.cpp`).

- Package the Windows build as **MSIX** with a Partner Center identity (sideload / Inno Setup builds cannot purchase).
- Create durable add-on `netpad_pro` and publish it with the app.
- Purchases and license checks only work inside the Store-signed MSIX.

## Debug override

```bash
flutter run --dart-define=NETPAD_PRO_OVERRIDE=true
```

Forces Pro without talking to a store (useful for UI testing).

## Free vs Pro

| Free | Pro |
|------|-----|
| Editing, discovery, pairing, sync | Unlimited notes (free capped at 5) |
| Default skin + light/dark | Extra skins |
| Find/replace, share/export | Version history |
| Manual reconnect | Trusted peer auto-sync |
| | Voice dictation |
