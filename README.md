# Drift 🌙

Fall asleep, keep the streak. A one-loop sleep habit app: log tonight's
sleep, watch the moon fill in, don't break the chain.

## Architecture (day-one build)

Deliberately backend-free so there's nothing to configure before testers
can install it:

- **State**: `SharedPreferences` only — streak, longest streak, total logs,
  bedtime. No Firebase project, no auth, no security rules to write.
- **Reminders**: `flutter_local_notifications`, scheduled entirely on-device.
  No FCM/server needed.
- **Design system**: same token structure as the studio's other apps
  (`GlassCard`, `PrimaryButton`, `StatChip`, `showCelebration`) — just a new
  night/moonlight palette in `lib/theme/app_theme.dart`, so every widget in
  `lib/widgets/` is a verbatim drop-in.
- **Core loop**: `lib/services/sleep_service.dart` — `logTonight()` is the
  only method that matters. One tap → streak increments → celebration.

If the streak hook validates with your 12 testers, swap `SleepService` for a
Firestore-backed version later (same public API) to get cross-device sync
and remote analytics — nothing else in the app needs to change.

## Getting this running locally

This was built without the Flutter SDK available (source only), so the
`android/` and `ios/` platform folders aren't generated yet. One-time setup:

```bash
git clone https://github.com/Akindiormi/Drift.git
cd Drift

# Generate platform folders without touching the existing lib/ and pubspec.yaml
flutter create --platforms=android,ios --project-name drift --org com.earnpalsolutions .

flutter pub get
flutter run
```

`flutter create` on top of an existing project only adds the missing
`android/`/`ios/` folders — it won't overwrite `lib/main.dart` or
`pubspec.yaml` since those already exist.

## What's intentionally missing (add after today's test)

- Sign-in / accounts
- Cross-device sync
- Sleep duration/quality input (currently a single daily tap — duration math
  needs real usage data to feel meaningful, see the reasoning in chat)
- Analytics
