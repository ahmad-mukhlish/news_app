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
| **1.11** | **Replace `YOUR_ONESIGNAL_APP_ID` in `notification_service.dart:14`** | ⬜ |

---

## 2 — Android (already done, one check remaining)

| # | Task | Status |
|---|------|--------|
| 2.1 | `id("com.google.gms.google-services")` plugin removed from `android/app/build.gradle.kts` | ✅ |
| 2.2 | `com.google.gms.google-services` classpath removed from `android/settings.gradle.kts` | ✅ |
| 2.3 | `android/app/google-services.json` deleted | ✅ |
| **2.4** | **Verify `minSdk` ≥ 21 in `android/app/build.gradle.kts`** (OneSignal minimum; Flutter default is 21, confirm it hasn't been lowered) | ⬜ |

> ⚠️ **No Application class needed.** Unlike the native Android SDK docs, the Flutter package initialises via `OneSignal.initialize()` in Dart — no Kotlin/Java boilerplate required. `google-services.json` is also not needed; OneSignal manages FCM internally.

---

## 3 — iOS — Xcode (manual, must be done in Xcode)

Do these in order. All steps are inside Xcode unless stated otherwise.

### 3.1 — Runner target capabilities

Open `ios/Runner.xcworkspace` in Xcode.

| # | Step | Status |
|---|------|--------|
| 3.1.1 | Select `Runner` target → **Signing & Capabilities** | ⬜ |
| 3.1.2 | **+ Capability → Push Notifications** | ⬜ |
| 3.1.3 | **+ Capability → Background Modes** → tick **Remote notifications** | ⬜ |
| 3.1.4 | *(Recommended)* **+ Capability → App Groups** → add group `group.com.dhealth.news.newsApp.onesignal` | ⬜ |

### 3.2 — Notification Service Extension

> ⚠️ The Swift file at `ios/OneSignalNotificationServiceExtension/NotificationService.swift` is already written. You just need to create the Xcode target that references it.

| # | Step | Status |
|---|------|--------|
| 3.2.1 | **File → New → Target → Notification Service Extension** | ⬜ |
| 3.2.2 | Product name: **`OneSignalNotificationServiceExtension`** (exact spelling) | ⬜ |
| 3.2.3 | Language: **Swift** | ⬜ |
| 3.2.4 | When prompted "Activate scheme?" → click **Cancel** (not Activate) | ⬜ |
| 3.2.5 | Select the new `OneSignalNotificationServiceExtension` target → **General** tab | ⬜ |
| 3.2.6 | Set **Minimum Deployments** to **15.0** (match `Runner` target) | ⬜ |
| 3.2.7 | **Signing & Capabilities** → ensure Team is set (same as Runner) | ⬜ |
| 3.2.8 | *(If you added App Groups to Runner)* **+ Capability → App Groups** → same group: `group.com.dhealth.news.newsApp.onesignal` | ⬜ |
| 3.2.9 | In the project file tree, find the auto-generated `NotificationService.swift` inside the extension folder — **delete it** (Move to Trash) | ⬜ |
| 3.2.10 | **File → Add Files to "Runner"** → select `ios/OneSignalNotificationServiceExtension/NotificationService.swift` → ensure target membership is **only** `OneSignalNotificationServiceExtension` | ⬜ |

### 3.3 — Info.plist (already done)

| # | Task | Status |
|---|------|--------|
| 3.3.1 | `NSUserNotificationsUsageDescription` added to `ios/Runner/Info.plist` | ✅ |

### 3.4 — Podfile and pod install

| # | Task | Status |
|---|------|--------|
| 3.4.1 | `OneSignalNotificationServiceExtension` target block added to `ios/Podfile` | ✅ |
| **3.4.2** | **Run `pod install` inside `ios/`** | ⬜ |

```bash
cd ios && pod install && cd ..
```

---

## 4 — Apple Developer Portal (one-time, for iOS push)

| # | Task | Status |
|---|------|--------|
| 4.1 | Log in to [developer.apple.com](https://developer.apple.com) with an **Admin** account | ⬜ |
| 4.2 | **Certificates, Identifiers & Profiles → Keys → "+"** | ⬜ |
| 4.3 | Enable **Apple Push Notifications service (APNs)** → Continue → Register | ⬜ |
| 4.4 | **Download the .p8 file** (you can only download it once) | ⬜ |
| 4.5 | Note your **Key ID** (10-char string shown next to the key name) | ⬜ |
| 4.6 | Note your **Team ID** (10-char string in the top-right corner of your Developer Account) | ⬜ |

> ⚠️ **Use .p8 (Auth Key), not .p12.** `.p8` keys never expire and work across all apps in your account. OneSignal no longer supports `.p12`.

---

## 5 — OneSignal Dashboard

### 5.1 — Copy App ID

| # | Task | Status |
|---|------|--------|
| 5.1.1 | **Settings → Keys & IDs** → copy your **App ID** (36-char UUID) | ⬜ |
| 5.1.2 | Paste it into `lib/app/services/notification/notification_service.dart:14` | ⬜ |

### 5.2 — iOS (APNs)

| # | Task | Status |
|---|------|--------|
| 5.2.1 | **Settings → Push & In-App → Apple iOS (APNs)** | ⬜ |
| 5.2.2 | Select **".p8 Auth Key"** | ⬜ |
| 5.2.3 | Upload the `.p8` file downloaded in step 4.4 | ⬜ |
| 5.2.4 | Enter **Key ID** (from step 4.5) | ⬜ |
| 5.2.5 | Enter **Team ID** (from step 4.6) — ⚠️ *do not swap Key ID and Team ID, common mistake* | ⬜ |
| 5.2.6 | Enter **Bundle ID**: `com.dhealth.news.newsApp` | ⬜ |
| 5.2.7 | Click **Save** | ⬜ |

### 5.3 — Android (FCM)

| # | Task | Status |
|---|------|--------|
| 5.3.1 | Open Firebase Console → your project → **Project Settings → Cloud Messaging** | ⬜ |
| 5.3.2 | Copy the **Server Key** (also called Server API Key) | ⬜ |
| 5.3.3 | OneSignal Dashboard → **Settings → Push & In-App → Google Android (FCM)** | ⬜ |
| 5.3.4 | Paste the Server Key → **Save** | ⬜ |

> ⚠️ The FCM Server Key from Firebase Console must be pasted into OneSignal dashboard. This is separate from `google-services.json`. Without this, Android push will not deliver.

---

## 6 — Testing

| # | Task | Status |
|---|------|--------|
| 6.1 | Run `flutter run` on a **physical Android device** (push works in debug) | ⬜ |
| 6.2 | Run `flutter run` on a **physical iOS device** (simulators do NOT receive push) | ⬜ |
| 6.3 | Check **OneSignal Dashboard → Audience → Subscriptions** — your device should appear after launching the app and granting permission | ⬜ |
| 6.4 | Send a test push: **Dashboard → Messages → New Push → Send Test → pick device** | ⬜ |
| 6.5 | Verify foreground notification appears (via `flutter_local_notifications`) | ⬜ |
| 6.6 | Verify background notification tap opens the correct notification detail screen | ⬜ |
| 6.7 | Test on a **release build** (`flutter run --release`) — background tap and killed-state launch must work | ⬜ |

---

## 7 — Optional / Recommended

| # | Task | Note |
|---|------|------|
| 7.1 | Call `OneSignal.login("user_id")` after the user logs in | Enables targeting individual users instead of just devices |
| 7.2 | Call `OneSignal.logout()` on sign-out | Unlinks the external user ID from this device |
| 7.3 | Remove `OneSignal.Debug.setLogLevel(OSLogLevel.verbose)` before releasing to production | It's in `notification_service.dart:11` |
| 7.4 | Verify `compileSdk ≥ 33` in `android/app/build.gradle.kts` for Android 13 notification permission support | Currently uses `flutter.compileSdkVersion` — confirm Flutter default is ≥ 33 |

---

## Quick Order of Operations

```
1. Apple Developer Portal → generate .p8 key (step 4)
2. OneSignal Dashboard → configure iOS + Android (step 5)
3. Paste App ID into notification_service.dart (step 1.11)
4. Xcode → capabilities + extension (step 3)
5. pod install (step 3.4.2)
6. flutter run on physical device (step 6)
```
