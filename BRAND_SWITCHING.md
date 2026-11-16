# Switching between RailWire and KFON

Follow these steps in order to switch the app from **RailWire** to **KFON**.
To switch back, do the same steps with the RailWire values.

---

## Step 1: Set the brand

File: `lib/core/constant/app_brand.dart`

```dart
static const String brand = String.fromEnvironment(
  'BRAND',
  defaultValue: 'kfon',      // KFON
  // defaultValue: 'railwire', // RailWire
);
```

The brand setting controls:

- **Tenant:** KFON always uses tenant `KFON`. It skips the circle selection screen and hides the circle card on Login.
- **App name:** the name shown in text, such as "Welcome to …" and the About screen.
- **KFON contact details:** the contact number, copyright and links.

Instead of editing the file, you can also pass the brand on the command line:
`flutter run --dart-define=BRAND=kfon`

---

## Step 2: Change the logo

File: `lib/core/constant/app_assets.dart`

The logos switch automatically with the brand from Step 1. To use a
different logo image, replace the file at the path below. Keep the same
file name.

| Where it shows | Constant | RailWire file | KFON file |
|---|---|---|---|
| Login / OTP / Forgot & New Password header (white) | `kWhitLogoAsset` | `assets/images/railwire_white.png` | `assets/images/kfon/kfon_white.png` |
| Home header (white) | `kHomeLogoAsset` | `assets/images/railwire_logo_home.png` | `assets/images/kfon/kfon_white.png` |
| Dialogs (coloured) | `kLogoAsset` | `assets/images/railwire_logo.png` | `assets/images/kfon/kfon_logo.jpg` |
| Intro screens (round mark) | `introRoundLogo` | `assets/images/intro_round_logo.png` | `assets/images/kfon/kfon_round.png` |

---

## Step 3: Change the colour

File: `lib/core/constant/constant_colors.dart`

The primary colour switches automatically with the brand from Step 1:

| Brand | Primary colour |
|---|---|
| RailWire | `#26307A` (navy) |
| KFON | `#8D0247` (maroon) |

To change a brand's colour, edit the value in `primaryFor()`:

```dart
static const Color _kfonPrimary = Color(0xFF8D0247);   // KFON
// RailWire: const Color(0xFF26307A) inside primaryFor()
```

Buttons, tabs, chips, backgrounds and recoloured SVG artwork all follow this
colour.

---

## Step 4: Change the API URL

File: `assets/env/.env.dev`

Keep one `BASE_URL` line active. Comment out the others with `#`:

```
# BASE_URL=<RailWire base URL>
BASE_URL=<KFON base URL>
```

Also check `lib/core/constant/api_urls.dart`: `isRailwire` must stay `false`
for both brands. Set it to `true` only for the old RailWire PHP APIs.

---

## Step 5: Splash screen and app name

The native splash shows before any Dart code runs, so it can't follow Step 1
at runtime. Each brand has its own config file:

| Brand | Config file | Colour | Logo |
|---|---|---|---|
| RailWire | `flutter_native_splash-railwire.yaml` | `#26307A` | `assets/images/splash_logo*.png` |
| KFON | `flutter_native_splash-kfon.yaml` | `#8D0247` | `assets/images/kfon/kfon_splash_logo*.png` |

Android and iOS builds regenerate the splash automatically for the brand
from Step 1 (or `--dart-define=BRAND`), and only when it changed. For web, or
to regenerate by hand:

```
tool/apply_brand.sh          # uses the brand set in Step 1
tool/apply_brand.sh kfon     # or name the brand
```

iOS caches launch screens, so reinstall the app on a device after a switch.

If you change a brand colour in Step 3, change it in that brand's splash
config too.

---

## Step 6: Full restart and build

Hot reload doesn't apply these changes. Stop the app, then:

```
flutter clean
flutter pub get
flutter run                 # or: flutter build apk / flutter build ipa
```

---

## Notes

- **App name under the icon** follows the brand automatically, the same way
  as the splash (Step 5): "RailWire Subscriber" or "KFON Subscriber".
  It's written to `android/app/src/main/res/values/strings.xml`,
  `ios/Runner/Info.plist` and `web/`. Change the names in `tool/apply_brand.sh`.
- **App icon and app ID** are still RailWire for both brands:
  - App ID: `com.railtel.railwire.subscriber`
  - App icon: `ios/Runner/Assets.xcassets/AppIcon.appiconset/` and `android/app/src/main/res/mipmap-*/`

  A KFON build therefore replaces the RailWire app on a test phone.
- When you switch brands on the same phone, reinstall the app. Saved login
  and tenant data can otherwise carry over.
- Before you commit, switch back to RailWire (Steps 1, 4 and 5), so the
  RailWire build doesn't ship with KFON settings.
