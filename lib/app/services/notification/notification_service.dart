import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';

import 'notification_lifecycle_callbacks.dart';

/// Scenario 3: Background message handler (must be top-level function)
/// Fires when notification arrives while app is in background/terminated
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await onBackgroundMessage(message);
}

class NotificationService extends GetxService {
  NotificationService({FirebaseMessaging? messaging})
      : _messaging = messaging ?? FirebaseMessaging.instance;

  final FirebaseMessaging _messaging;

  static NotificationService get to => Get.find<NotificationService>();

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  Future<NotificationService> init() async {
    await _requestPermissions();

    await _getFCMToken();

    // Scenario 1: Subscribe to foreground messages (app is open)
    _subscribeToForegroundMessages();

    // Scenario 2: Subscribe to message opened app (background tap)
    _subscribeToMessageOpenedApp();

    // Scenario 3: Subscribe to background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Scenario 4: Check if app was opened from terminated state
    await _checkInitialMessage();

    print('NotificationService initialized successfully');
    print('FCM Token: $_fcmToken');

    return this;
  }

  /// Request notification permissions (important for iOS)
  Future<void> _requestPermissions() async {
    if (Platform.isIOS) {
      await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
    }

    final settings = await _messaging.getNotificationSettings();
    print('Notification permission status: ${settings.authorizationStatus}');
  }

  /// Get FCM token
  Future<void> _getFCMToken() async {
    try {
      _fcmToken = await _messaging.getToken();

      // Listen to token refresh
      _messaging.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        print('FCM Token refreshed: $newToken');
      });
    } catch (e) {
      print('Error getting FCM token: $e');
    }
  }

  /// Scenario 1: Subscribe to foreground messages
  /// Fires when notification arrives while app is open and visible
  void _subscribeToForegroundMessages() {
    FirebaseMessaging.onMessage.listen(onForegroundMessage);
  }

  /// Scenario 2: Subscribe to message opened app
  /// Fires when user taps notification while app is in background
  void _subscribeToMessageOpenedApp() {
    FirebaseMessaging.onMessageOpenedApp.listen(onMessageOpenedApp);
  }

  /// Scenario 4: Check if app was opened from terminated state
  /// Checks if user tapped notification to open app from completely closed state
  Future<void> _checkInitialMessage() async {
    final message = await _messaging.getInitialMessage();
    if (message != null) {
      await onInitialMessage(message);
    }
  }
}
