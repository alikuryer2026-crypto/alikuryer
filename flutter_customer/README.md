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
