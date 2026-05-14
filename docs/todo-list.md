# OneSignal Enable Checklist

Legend: ✅ Done · ⬜ To do · ⚠️ Important note

---

## 1 — Dart / Flutter (already done)

| # | Task | Status |
|---|------|--------|
| 1.1 | `onesignal_flutter: ^5.5.4` added to `pubspec.yaml` | ✅ |
| 1.2 | `flutter pub get` ran, package resolved | ✅ |
| 1.3 | `firebase_core` + `firebase_messaging` removed from `pubspec.yaml` | ✅ |
| 1.4 | `notification_service.dart` rewritten with OneSignal | ✅ |
| 1.5 | `notification_lifecycle_callbacks.dart` rewritten (foreground + click listener) | ✅ |
| 1.6 | `local_notification_display.dart` updated (`OSNotification` instead of `RemoteMessage`) | ✅ |
| 1.7 | `push_notification_mapper.dart` updated (`fromOneSignalNotification`) | ✅ |
| 1.8 | `main.dart` — Firebase init removed | ✅ |
| 1.9 | `firebase_options.dart` deleted | ✅ |
| 1.10 | `dart analyze` passes with 0 issues | ✅ |
| 1.11 | OneSignal App ID set in `notification_service.dart:14` | ✅ |

---

## 2 — Android config (already done, one check remaining)

| # | Task | Status |
|---|------|--------|
| 2.1 | `id("com.google.gms.google-services")` plugin removed from `android/app/build.gradle.kts` | ✅ |
| 2.2 | `com.google.gms.google-services` classpath removed from `android/settings.gradle.kts` | ✅ |
| 2.3 | `android/app/google-services.json` deleted | ✅ |
| 2.4 | `minSdk` ≥ 21 confirmed — `flutter.minSdkVersion` resolves to **24** in Flutter 3.41.8 | ✅ |

> ⚠️ **No Application class needed.** Unlike the native Android SDK docs, the Flutter package initialises via `OneSignal.initialize()` in Dart — no Kotlin/Java boilerplate required. `google-services.json` is also not needed; OneSignal manages FCM internally.

---

## 3 — OneSignal Dashboard — Android (FCM)

This is required for Android push to deliver. OneSignal now uses the **FCM v1 API** (Service Account JSON), not the old Server Key.

| # | Task | Status |
|---|------|--------|
| 3.1 | Firebase Console → your project → **⚙️ Project Settings → Service Accounts** tab | ⬜ |
| 3.2 | Click **"Generate new private key"** → **"Generate key"** → a `.json` file downloads | ⬜ |
| 3.3 | OneSignal Dashboard → **Settings → Push & In-App → Google Android (FCM)** | ⬜ |
| 3.4 | Click **"Select file"** and upload the downloaded `.json` file → **Save & Continue** | ⬜ |

> ⚠️ Do **not** commit the downloaded `.json` file to git — it contains private Firebase credentials.

---

## 4 — Android testing

| # | Task | Status |
|---|------|--------|
| 4.1 | Run `flutter run` on a **physical Android device** | ⬜ |
| 4.2 | Check **OneSignal Dashboard → Audience → Subscriptions** — your device should appear after launching the app and granting permission | ⬜ |
| 4.3 | Send a test push: **Dashboard → Messages → New Push → Send Test → pick device** | ⬜ |
| 4.4 | Verify foreground notification appears (shown via `flutter_local_notifications`) | ⬜ |
| 4.5 | Verify background notification tap opens the correct notification detail screen | ⬜ |
| 4.6 | Test on a **release build** (`flutter run --release`) — background tap and killed-state launch must work | ⬜ |

---

## 5 — iOS — Xcode (do this after Android is working)

All steps are inside Xcode unless stated otherwise.

### 5.1 — Runner target capabilities

Open `ios/Runner.xcworkspace` in Xcode.

| # | Step | Status |
|---|------|--------|
| 5.1.1 | Select `Runner` target → **Signing & Capabilities** | ⬜ |
| 5.1.2 | **+ Capability → Push Notifications** | ⬜ |
| 5.1.3 | **+ Capability → Background Modes** → tick **Remote notifications** | ⬜ |
| 5.1.4 | *(Recommended)* **+ Capability → App Groups** → add group `group.com.dhealth.news.newsApp.onesignal` | ⬜ |

### 5.2 — Notification Service Extension

> ⚠️ The Swift file at `ios/OneSignalNotificationServiceExtension/NotificationService.swift` is already written. You just need to create the Xcode target that references it.

| # | Step | Status |
|---|------|--------|
| 5.2.1 | **File → New → Target → Notification Service Extension** | ⬜ |
| 5.2.2 | Product name: **`OneSignalNotificationServiceExtension`** (exact spelling) | ⬜ |
| 5.2.3 | Language: **Swift** | ⬜ |
| 5.2.4 | When prompted "Activate scheme?" → click **Cancel** (not Activate) | ⬜ |
| 5.2.5 | Select the new target → **General** tab → set **Minimum Deployments** to **15.0** (match `Runner`) | ⬜ |
| 5.2.6 | **Signing & Capabilities** → ensure Team is set (same as Runner) | ⬜ |
| 5.2.7 | *(If you added App Groups to Runner)* **+ Capability → App Groups** → same group: `group.com.dhealth.news.newsApp.onesignal` | ⬜ |
| 5.2.8 | In the project file tree, find the auto-generated `NotificationService.swift` inside the extension folder — **delete it** (Move to Trash) | ⬜ |
| 5.2.9 | **File → Add Files to "Runner"** → select `ios/OneSignalNotificationServiceExtension/NotificationService.swift` → ensure target membership is **only** `OneSignalNotificationServiceExtension` | ⬜ |

### 5.3 — Podfile and pod install

| # | Task | Status |
|---|------|--------|
| 5.3.1 | `OneSignalNotificationServiceExtension` target block added to `ios/Podfile` | ✅ |
| 5.3.2 | `NSUserNotificationsUsageDescription` added to `ios/Runner/Info.plist` | ✅ |
| **5.3.3** | **Run `pod install` inside `ios/`** | ⬜ |

```bash
cd ios && pod install && cd ..
```

---

## 6 — Apple Developer Portal (one-time, for iOS push)

| # | Task | Status |
|---|------|--------|
| 6.1 | Log in to [developer.apple.com](https://developer.apple.com) with an **Admin** account | ⬜ |
| 6.2 | **Certificates, Identifiers & Profiles → Keys → "+"** | ⬜ |
| 6.3 | Enable **Apple Push Notifications service (APNs)** → Continue → Register | ⬜ |
| 6.4 | **Download the .p8 file** (you can only download it once) | ⬜ |
| 6.5 | Note your **Key ID** (10-char string shown next to the key name) | ⬜ |
| 6.6 | Note your **Team ID** (10-char string in the top-right corner of your Developer Account) | ⬜ |

> ⚠️ **Use .p8 (Auth Key), not .p12.** `.p8` keys never expire and work across all apps in your account. OneSignal no longer supports `.p12`.

---

## 7 — OneSignal Dashboard — iOS (APNs)

| # | Task | Status |
|---|------|--------|
| 7.1 | **Settings → Push & In-App → Apple iOS (APNs)** | ⬜ |
| 7.2 | Select **".p8 Auth Key"** | ⬜ |
| 7.3 | Upload the `.p8` file downloaded in step 6.4 | ⬜ |
| 7.4 | Enter **Key ID** (from step 6.5) | ⬜ |
| 7.5 | Enter **Team ID** (from step 6.6) — ⚠️ *do not swap Key ID and Team ID, common mistake* | ⬜ |
| 7.6 | Enter **Bundle ID**: `com.dhealth.news.newsApp` | ⬜ |
| 7.7 | Click **Save** | ⬜ |

---

## 8 — iOS testing

| # | Task | Status |
|---|------|--------|
| 8.1 | Run `flutter run` on a **physical iOS device** (simulators do NOT receive push) | ⬜ |
| 8.2 | Check **OneSignal Dashboard → Audience → Subscriptions** — iOS device should appear | ⬜ |
| 8.3 | Send a test push: **Dashboard → Messages → New Push → Send Test → pick device** | ⬜ |
| 8.4 | Verify foreground, background, and killed-state behaviour | ⬜ |
| 8.5 | Test on a **release build** (`flutter run --release`) | ⬜ |

---

## 9 — Optional / Recommended

| # | Task | Note |
|---|------|------|
| 9.1 | Call `OneSignal.login("user_id")` after the user logs in | Enables targeting individual users instead of just devices |
| 9.2 | Call `OneSignal.logout()` on sign-out | Unlinks the external user ID from this device |
| 9.3 | Remove `OneSignal.Debug.setLogLevel(OSLogLevel.verbose)` before production release | It's in `notification_service.dart:11` |
| 9.4 | Verify `compileSdk ≥ 33` in `android/app/build.gradle.kts` for Android 13 notification permission | Currently uses `flutter.compileSdkVersion` — confirm Flutter default is ≥ 33 |

---

## Quick Order of Operations

```
Android first:
  1. Firebase Console → copy FCM Server Key
  2. OneSignal Dashboard → paste FCM Server Key (step 3)
  3. flutter run on physical Android device (step 4)

iOS after Android is verified working:
  4. Xcode → capabilities + extension (step 5)
  5. pod install (step 5.3.3)
  6. Apple Developer Portal → generate .p8 key (step 6)
  7. OneSignal Dashboard → upload APNs key (step 7)
  8. flutter run on physical iOS device (step 8)
```
