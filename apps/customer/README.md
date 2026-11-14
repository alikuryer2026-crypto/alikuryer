# Alikuryer customer app

Original Flutter starter, no reused templates.

## Setup
Install Flutter SDK and run in this directory:
```sh
flutter create --project-name alikuryer_customer --platforms android,ios,web .
flutter pub get
flutter run --dart-define=SUPABASE_URL=https://tuncowhplrzqaohiisnc.supabase.co --dart-define=SUPABASE_PUBLISHABLE_KEY=YOUR_PUBLISHABLE_KEY
```
The project URL is public. Use the publishable key from your Supabase dashboard.
Do not use a secret or service_role key in Flutter.

This is an initial scaffold; authentication, catalog, cart and checkout are not yet implemented.
