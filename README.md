# Miilto — Flutter + Firebase MVP

Miilto is a minimal ride-sharing app (MVP) built with Flutter, Firebase (Auth, Firestore, FCM), and Google Maps.

## Features (MVP)
- Email/password auth
- Drivers can create rides (origin/destination, seats)
- Passengers can search rides and request seats
- Firestore transactions to avoid overselling seats
- Per-ride chat (messages subcollection)
- FCM notifications (setup required)

## Quick start
1. Install Flutter (stable) and Android SDK.
2. (Optional) Copy `.env.template` to `.env` and fill keys only if you want
   to provide overrides or local-only keys — this is not required for Firebase.
   The Firebase configuration is provided by the generated `lib/firebase_options.dart`.
   To generate `firebase_options.dart` for your project use the FlutterFire CLI:
   `dart pub global activate flutterfire_cli` and `flutterfire configure`.
3. Add Firebase config files:
   - Android: `android/app/google-services.json`
   - iOS: `ios/Runner/GoogleService-Info.plist`
4. Enable Firebase Auth (Email/Password) and Firestore in the Firebase console.
5. Run:

```bash
flutter pub get
flutter run
```

## Firestore rules
See `firebase_rules/firestore.rules` for starter rules.

## Data model
- users/{uid}
- rides/{rideId}
  - rides/{rideId}/requests/{requestId}
  - rides/{rideId}/messages/{msgId}

## Testing
- Unit tests for models and services are in `test/` (add more as you implement features).

## Next steps
- Add Google Maps place picker & Directions API integration
- Improve security rules and use Cloud Functions for notifications
- Add profile screens, image upload, and better UI
# miiltoo
