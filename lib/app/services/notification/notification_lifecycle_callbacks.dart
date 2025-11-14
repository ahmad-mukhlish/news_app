import 'dart:async';
import 'dart:developer' as developer;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../../../app/data/notification/mappers/push_notification_mapper.dart';
import '../../../app/domain/entities/push_notification.dart';
import '../../../features/notifications/data/repositories/notification_repository.dart';
import '../../helper/common_methods/navigation_methods.dart';
import 'local_notification_display.dart';
import 'notification_repository_provider.dart';

typedef LocalNotificationDisplayer = Future<void> Function(
  RemoteMessage message, {
  bool force,
});

@visibleForTesting
LocalNotificationDisplayer displayNotification = displayLocalNotification;

@visibleForTesting
void setDisplayNotificationDisplayer(LocalNotificationDisplayer displayer) {
  displayNotification = displayer;
}

@visibleForTesting
void resetDisplayNotificationDisplayer() {
  displayNotification = displayLocalNotification;
}

/// Notification Lifecycle Callbacks
/// All top-level functions to handle FCM notification scenarios
/// These callbacks act as Use Cases in Clean Architecture

/// Ensure NotificationRepository is initialized (lazy initialization)
/// Works in both main isolate and background isolate
Future<NotificationRepository> _ensureRepositoryInitialized() async {
  return ensureNotificationRepositoryInitialized();
}

Future<PushNotification> _resolveNotificationEntity(
  NotificationRepository repository,
  RemoteMessage message,
) async {
  final notificationId = message.messageId;

  if (notificationId != null) {
    final pushNotifDto = await repository.getNotificationById(notificationId);
    if (pushNotifDto != null) {
      return PushNotificationMapper.toEntity(pushNotifDto);
    }
  }

  return PushNotificationMapper.fromRemoteMessage(message);
}

/// Scenario 1: Foreground Message Received
/// Fires when notification arrives while app is open and visible
Future<void> onForegroundMessage(RemoteMessage message) async {
  developer.log('=== SCENARIO 1: Foreground Message Received ===');
  developer.log('Message ID: ${message.messageId}');
  developer.log('Title: ${message.notification?.title}');
  developer.log('Body: ${message.notification?.body}');
  developer.log('Data: ${message.data}');
  developer.log('===============================================');

  // Ensure repository is initialized
  final repository = await _ensureRepositoryInitialized();

  // Save to local storage
  final dto = PushNotificationMapper.dtoFromRemoteMessage(message);
  await repository.appendNotification(dto);

  // Show local notification
  unawaited(displayNotification(message, force: true));
}

/// Scenario 2: Notification Tapped (Background)
/// Fires when user taps notification while app is in background
Future<void> onMessageOpenedApp(RemoteMessage message) async {
  developer.log('=== SCENARIO 2: Notification Tapped (Background) ===');
  developer.log('Message ID: ${message.messageId}');
  developer.log('Title: ${message.notification?.title}');
  developer.log('Body: ${message.notification?.body}');
  developer.log('Data: ${message.data}');
  developer.log('===================================================');

  // Ensure repository is initialized
  final repository = await _ensureRepositoryInitialized();

  // Mark notification as read if exists
  final notificationId = message.messageId;
  if (notificationId != null) {
    await repository.markNotificationReadById(notificationId);
  }

  final notification = await _resolveNotificationEntity(repository, message);

  await navigateToNotificationDetail(
    notification: notification,
    ensureNavigatorReady: true,
  );
}

/// Scenario 3: Background Message Received
/// Fires when notification arrives while app is in background/terminated
/// NOTE: Must be top-level function for Firebase background handler
@pragma('vm:entry-point')
Future<void> onBackgroundMessage(RemoteMessage message) async {
  developer.log('=== SCENARIO 3: Background Message Received ===');
  developer.log('Message ID: ${message.messageId}');
  developer.log('Title: ${message.notification?.title}');
  developer.log('Body: ${message.notification?.body}');
  developer.log('Data: ${message.data}');
  developer.log('=============================================');

  // Ensure repository is initialized (works in background isolate)
  final repository = await _ensureRepositoryInitialized();

  // Save to local storage
  final dto = PushNotificationMapper.dtoFromRemoteMessage(message);
  await repository.appendNotification(dto);

  // Display local notification
  await displayNotification(message);
}

/// Scenario 4: App Opened from Terminated State
/// Fires when user taps notification to open app from completely closed state
Future<void> onInitialMessage(RemoteMessage message) async {
  developer.log('=== SCENARIO 4: App Opened from Terminated State ===');
  developer.log('Message ID: ${message.messageId}');
  developer.log('Title: ${message.notification?.title}');
  developer.log('Body: ${message.notification?.body}');
  developer.log('Data: ${message.data}');
  developer.log('====================================================');

  // Ensure repository is initialized
  final repository = await _ensureRepositoryInitialized();

  // Mark notification as read if exists
  final notificationId = message.messageId;
  if (notificationId != null) {
    await repository.markNotificationReadById(notificationId);
  }

  final notification = await _resolveNotificationEntity(repository, message);

  await navigateToNotificationDetail(
    notification: notification,
    ensureNavigatorReady: true,
  );
}
