# ALIKURYER — approved 16-screen reference (2026-11-17)

The user supplied a 4×4 contact sheet of 16 mobile screens and explicitly requested this visual direction. This document is a build specification, not a claim that all screens are implemented.

## Approved visual system
- Brand ALIKURYER, red/white/black, high-contrast rounded buttons and cards.
- A recurring **original** 3D cartoon courier on a red scooter with insulated delivery box, in Uzbek urban scenery. Do not replace the approved character with generic food stock art. The screenshot is a reference, not a licensed production illustration.
- Compact branded header, white content backgrounds, bright red gradients in banners, rounded food cards and bottom navigation.
- User-facing labels in Uzbek, language selection Uzbek / Russian / English / Simplified Chinese.

## Screens (numbering follows uploaded reference)
01. Welcome splash with large courier hero, red start button.
02. Language selection with four languages.
03. Phone login with +998 and Google/Apple options.
04. Four-digit SMS OTP confirmation.
05. Home with hero promotion, categories, restaurant cards, bottom navigation.
06. Customer cabinet/dashboard with balances, order status and shortcuts.
07. Active order tracking, courier, route, progress and order card.
08. Order tracking detailed map, courier actions, items, total.
09. Customer wallet, points, payment brands and orders.
10. Edit profile/photo and personal data.
11. Address selector with map pin, saved addresses.
12. Cart with quantities, promo code, address, payment, total.
13. Payment method selection and saved cards.
14. Order accepted with progress, map and courier details.
15. Profile overview, stats, settings and order shortcuts.
16. Favorites, restaurants and food list.

## Engineering priorities
1. Build a real 16-screen Flutter navigation skeleton with locally working flows and original styling.
2. Add responsive screen widgets, scrollable layouts, accessible hit targets, and loading/error/empty states.
3. Wire real Supabase auth and catalog only after confirming schema, RLS, redirect URLs and key handling.
4. Do not fake wallet balance, courier live GPS, SMS delivery, Apple/Google sign-in, payments, or a live delivery status.
5. Then add Android build and test automation; do not claim APK before build succeeds.
