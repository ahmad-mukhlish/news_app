import 'package:firebase_messaging/firebase_messaging.dart';

/// Notification Lifecycle Callbacks
/// All top-level functions to handle FCM notification scenarios

/// Scenario 1: Foreground Message Received
/// Fires when notification arrives while app is open and visible
void onForegroundMessage(RemoteMessage message) {
  print('=== SCENARIO 1: Foreground Message Received ===');
  print('Message ID: ${message.messageId}');
  print('Title: ${message.notification?.title}');
  print('Body: ${message.notification?.body}');
  print('Data: ${message.data}');
  print('===============================================');
  // TODO: Save to local storage
  // TODO: Show local notification (flutter_local_notifications)
}

/// Scenario 2: Notification Tapped (Background)
/// Fires when user taps notification while app is in background
void onMessageOpenedApp(RemoteMessage message) {
  print('=== SCENARIO 2: Notification Tapped (Background) ===');
  print('Message ID: ${message.messageId}');
  print('Title: ${message.notification?.title}');
  print('Body: ${message.notification?.body}');
  print('Data: ${message.data}');
  print('===================================================');
  // TODO: Navigate to specific screen based on data
  // TODO: Mark notification as read
}

/// Scenario 3: Background Message Received
/// Fires when notification arrives while app is in background/terminated
/// NOTE: Must be top-level function for Firebase background handler
@pragma('vm:entry-point')
Future<void> onBackgroundMessage(RemoteMessage message) async {
  print('=== SCENARIO 3: Background Message Received ===');
  print('Message ID: ${message.messageId}');
  print('Title: ${message.notification?.title}');
  print('Body: ${message.notification?.body}');
  print('Data: ${message.data}');
  print('=============================================');
  // TODO: Save to local storage
}

/// Scenario 4: App Opened from Terminated State
/// Fires when user taps notification to open app from completely closed state
void onInitialMessage(RemoteMessage message) {
  print('=== SCENARIO 4: App Opened from Terminated State ===');
  print('Message ID: ${message.messageId}');
  print('Title: ${message.notification?.title}');
  print('Body: ${message.notification?.body}');
  print('Data: ${message.data}');
  print('====================================================');
  // TODO: Navigate to specific screen based on data
  // TODO: Mark notification as read
}
