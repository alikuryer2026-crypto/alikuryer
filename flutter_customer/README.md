# ALIKURYER Customer — Flutter MVP

Independent Flutter customer application. This is a local interactive prototype, **not a production ordering system**.

## Run

Install Flutter SDK, then:

```sh
cd flutter_customer
flutter create --platforms=android,ios .
flutter pub add flutter_lints --dev
flutter pub get
flutter run
```

Android APK (requires installed Flutter/Android toolchain):

```sh
flutter build apk --release
```

## Current features

- Uzbek customer interface and premium red/black/white design
- Restaurant list, category filtering, search
- Restaurant menu, item details and quantity controls
- Cart with quantity editing and locally saved cart
- Checkout simulation and locally saved order history
- Profile name and address saved locally

## Not connected yet

- Supabase authentication and production database
- Restaurant API and real menu/prices
- Payments, real order dispatch, SMS
- Maps/geolocation and delivery tracking
- Push notifications and actual APK release pipeline

Never embed Supabase service-role secrets in the app.

## Automated Android build

The repository includes `.github/workflows/flutter-customer-apk.yml`. It generates Android scaffolding, runs Flutter analysis and a widget smoke test, then builds a **debug APK**. If GitHub Actions succeeds, download `alikuryer-customer-debug-apk` from that workflow run's Artifacts section. Debug APK is for testing only, not a Play Store release.

This workflow has been committed but its successful execution is **not yet verified**. If it fails, inspect Actions logs before treating an APK as available.

## Approved design reference

See `DESIGN_REFERENCE.md` for the user's 16-screen mockup breakdown. The reference remains the design target, not a claim of pixel-perfect implementation. Real courier hero illustration, localization, Supabase, GPS, SMS and payment providers still require integration.
