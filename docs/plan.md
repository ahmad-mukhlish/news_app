# OneSignal Integration Plan

## Should you delete FCM?

**Yes, on this branch.** OneSignal uses FCM under the hood on Android (you still paste your FCM server key into the OneSignal dashboard), but you do not need the `firebase_messaging` Flutter package or the Firebase SDK in your Dart code. Removing it keeps the branch clean and avoids two push SDKs fighting over the same notification channel.

`firebase_core` can also be removed — it is only used to initialise Firebase Messaging in this project.

---

## Files to delete

| File | Reason |
|------|--------|
| `lib/firebase_options.dart` | Only needed by Firebase SDK init |
| `lib/app/services/notification/notification_repository_provider.dart` | Only needed to re-initialise the repo inside the FCM background isolate — OneSignal has no background isolate |
| `android/app/google-services.json` *(if present)* | Firebase config — OneSignal doesn't need it |
| `ios/Runner/GoogleService-Info.plist` *(if present)* | Firebase config — OneSignal doesn't need it |

---

## Files to modify

### 1. `pubspec.yaml`

**Remove:**
```yaml
firebase_core: ^4.2.1
firebase_messaging: ^16.0.4
```

**Add:**
```yaml
onesignal_flutter: ^5.5.4
```

`flutter_local_notifications` can stay — it's still used to display notifications while the app is in the foreground.

---

### 2. `android/app/build.gradle`

Make sure `compileSdk` and `targetSdk` are **≥ 33**.

~~`manifestPlaceholders`~~ — **not needed** for the Flutter SDK 5.x. The App ID is passed directly in Dart via `OneSignal.initialize()`. No Gradle plugin needed either.

---

### 3. iOS — Xcode capabilities (manual step, no file edit)

In Xcode, select the **Runner** target:
- **Signing & Capabilities → + Capability → Push Notifications**
- **Signing & Capabilities → + Capability → Background Modes → check "Remote notifications"**

---

### 4. iOS — Notification Service Extension (NEW — was missing from original plan)

This is required for **rich notifications** (images) and **confirmed deliveries** (delivery tracking). Without it, image attachments will not appear.

**Steps:**
1. In Xcode: **File → New → Target → Notification Service Extension**
2. Name it **exactly** `OneSignalNotificationServiceExtension`
3. In `ios/Podfile`, add a new target block:

```ruby
target 'OneSignalNotificationServiceExtension' do
  pod 'OneSignalXCFramework', '>= 5.0.0', '< 6.0'
end
```

4. Replace the generated `NotificationService.swift` content with:

```swift
import UserNotifications
import OneSignalExtension

class NotificationService: UNNotificationServiceExtension {
    var contentHandler: ((UNNotificationContent) -> Void)?
    var receivedRequest: UNNotificationRequest!
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest,
                             withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.receivedRequest = request
        self.contentHandler = contentHandler
        self.bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        if let bestAttemptContent = bestAttemptContent {
            OneSignalExtension.didReceiveNotificationExtensionRequest(
                self.receivedRequest,
                with: bestAttemptContent,
                withContentHandler: self.contentHandler
            )
        }
    }

    override func serviceExtensionTimeWillExpire() {
        if let contentHandler = contentHandler, let bestAttemptContent = bestAttemptContent {
            OneSignalExtension.serviceExtensionTimeWillExpireRequest(
                self.receivedRequest,
                with: self.bestAttemptContent
            )
            contentHandler(bestAttemptContent)
        }
    }
}
```

5. Run `pod install` in the `ios/` directory after editing the Podfile.

> **Note on Swift Package Manager:** 5.5.0 added optional SPM support. If you are using `flutter config --enable-swift-package-manager`, you can skip the Podfile step — SPM resolves the extension dependency automatically. For most existing projects, CocoaPods is the default and safer choice.

---

### 5. `ios/Runner/Info.plist`

Add if missing:
```xml
<key>NSUserNotificationsUsageDescription</key>
<string>We send you breaking news alerts.</string>
```

---

### 6. `ios/Runner/AppDelegate.swift`

No code changes needed.

---

### 7. `lib/app/services/notification/notification_service.dart` — full rewrite

**Fixed vs original plan:**
- `OneSignal.initialize()` is **synchronous** (no `await`)
- `requestPermission(false)` — the boolean is `fallbackToSettings`, use `false` unless you want to redirect denied users to Settings
- Add `OneSignal.Debug.setLogLevel()` before init (useful during development)

```dart
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'notification_lifecycle_callbacks.dart';

class NotificationService {
  static String? _oneSignalId;
  static String? get oneSignalId => _oneSignalId;

  static Future<void> initialize() async {
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose); // remove before production

    OneSignal.initialize('YOUR_ONESIGNAL_APP_ID'); // synchronous, no await

    await OneSignal.Notifications.requestPermission(false);

    NotificationLifecycleCallbacks.register();

    _oneSignalId = await OneSignal.User.getOnesignalId();
    OneSignal.User.pushSubscription.addObserver((state) {
      _oneSignalId = state.current.id;
    });
  }
}
```

---

### 8. `lib/app/services/notification/notification_lifecycle_callbacks.dart` — full rewrite

No `@pragma('vm:entry-point')` top-level function needed — OneSignal's native SDK handles background receipt natively.

```dart
import 'package:onesignal_flutter/onesignal_flutter.dart';
import '../local_notification_display.dart';
// keep your existing navigation + repository imports

class NotificationLifecycleCallbacks {
  static void register() {
    // Foreground: intercept before display
    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      // save to repo using your existing NotificationRepository logic
      event.preventDefault(); // stop OneSignal from showing its own banner
      // then show via flutter_local_notifications:
      // LocalNotificationDisplay.show(...)
    });

    // Tapped (works for foreground, background, and killed-state launches)
    OneSignal.Notifications.addClickListener((event) {
      final data = event.notification.additionalData;
      // mark as read + navigate using your existing logic
    });
  }
}
```

---

### 9. `lib/app/services/notification/local_notification_display.dart`

**No changes needed.** Keep it as-is; it is called from the foreground listener above.

---

### 10. `lib/main.dart`

Remove:
```dart
await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
```

Replace with:
```dart
await NotificationService.initialize();
```

Remove the `firebase_options.dart` import.

---

### 11. `lib/app/data/notification/mappers/push_notification_mapper.dart`

Currently has a `fromRemoteMessage(RemoteMessage msg)` factory. Either:
- **Delete** the factory (it won't be called anymore), or
- **Rename** it to `fromOneSignalNotification(OSNotification n)` and map `n.title`, `n.body`, `n.additionalData`, `n.bigPicture` to your entity.

---

## OneSignal dashboard steps (do these once)

1. Log in → your app → **Settings → Platforms → Google Android (FCM)**  
   Paste your **FCM Server Key** (from Firebase Console → Project Settings → Cloud Messaging).  
   *(OneSignal still delivers via FCM on Android — you just don't use the Flutter SDK.)*
2. Copy your **OneSignal App ID** and replace every `YOUR_ONESIGNAL_APP_ID` placeholder above.
3. For iOS: upload your **APNs Auth Key** or .p12 certificate under **Settings → Platforms → Apple iOS**.

---

## Order of execution

1. Dashboard: add FCM key + APNs cert, copy App ID
2. Delete the files listed in the "Files to delete" section
3. `pubspec.yaml` — swap packages, run `flutter pub get`
4. `android/app/build.gradle` — verify `compileSdk ≥ 33` (no other changes)
5. Xcode — add Push Notifications + Background Modes capabilities
6. Xcode — add `OneSignalNotificationServiceExtension` target + update Podfile, run `pod install`
7. `Info.plist` — add usage description if missing
8. Rewrite `notification_service.dart`
9. Rewrite `notification_lifecycle_callbacks.dart`
10. Update `push_notification_mapper.dart`
11. Update `main.dart`
12. `flutter run` on a **physical device** (simulators don't receive push)
