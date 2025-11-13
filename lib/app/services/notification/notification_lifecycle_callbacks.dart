import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../app/data/notification/mappers/push_notification_mapper.dart';
import '../../../app/domain/entities/push_notification.dart';
import '../../../app/services/storage/local_storage_service.dart';
import '../../../features/notifications/data/datasources/local/notification_local_data_source.dart';
import '../../../features/notifications/data/repositories/notification_repository.dart';
import '../../../features/notifications/presentation/views/screen/notification_detail_screen.dart';
import 'local_notification_display.dart';

/// Notification Lifecycle Callbacks
/// All top-level functions to handle FCM notification scenarios
/// These callbacks act as Use Cases in Clean Architecture

/// Ensure NotificationRepository is initialized (lazy initialization)
/// Works in both main isolate and background isolate
Future<NotificationRepository> _ensureRepositoryInitialized() async {
  if (!Get.isRegistered<NotificationRepository>()) {
    // Initialize dependencies chain
    // SharedPreferences.getInstance() is already a singleton - no need for GetX
    if (!Get.isRegistered<LocalStorageService>()) {
      final prefs = await SharedPreferences.getInstance();
      Get.put(LocalStorageService(prefs: prefs));
    }

    if (!Get.isRegistered<NotificationLocalDataSource>()) {
      final storage = Get.find<LocalStorageService>();
      Get.put(NotificationLocalDataSource(storageService: storage));
    }

    if (!Get.isRegistered<NotificationRepository>()) {
      final dataSource = Get.find<NotificationLocalDataSource>();
      Get.put(NotificationRepository(
        localDataSource: dataSource,
      ));
    }
  }

  return Get.find<NotificationRepository>();
}

Future<void> _navigateToNotificationDetail(
  NotificationRepository repository,
  RemoteMessage message,
) async {
  final notification = await _resolveNotificationEntity(repository, message);

  // Wait until navigator is ready before pushing a screen (important on cold start)
  var attempts = 0;
  while (Get.key.currentState == null && attempts < 60) {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    attempts++;
  }

  if (Get.key.currentState == null) {
    print('Navigator not ready, skipping navigation to NotificationDetailScreen.');
    return;
  }

  Get.to(
    () => NotificationDetailScreen(notification: notification),
    preventDuplicates: true,
  );
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
  print('=== SCENARIO 1: Foreground Message Received ===');
  print('Message ID: ${message.messageId}');
  print('Title: ${message.notification?.title}');
  print('Body: ${message.notification?.body}');
  print('Data: ${message.data}');
  print('===============================================');

  // Ensure repository is initialized
  final repository = await _ensureRepositoryInitialized();

  // Save to local storage
  final notification = PushNotificationMapper.fromRemoteMessage(message);
  final dto = PushNotificationMapper.toDto(notification);
  await repository.appendNotification(dto);

  // Show local notification
  unawaited(displayLocalNotification(message, force: true));
}

/// Scenario 2: Notification Tapped (Background)
/// Fires when user taps notification while app is in background
Future<void> onMessageOpenedApp(RemoteMessage message) async {
  print('=== SCENARIO 2: Notification Tapped (Background) ===');
  print('Message ID: ${message.messageId}');
  print('Title: ${message.notification?.title}');
  print('Body: ${message.notification?.body}');
  print('Data: ${message.data}');
  print('===================================================');

  // Ensure repository is initialized
  final repository = await _ensureRepositoryInitialized();

  // Mark notification as read if exists
  final notificationId = message.messageId;
  if (notificationId != null) {
    await repository.markNotificationReadById(notificationId);
  }

  await _navigateToNotificationDetail(repository, message);
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

  // Ensure repository is initialized (works in background isolate)
  final repository = await _ensureRepositoryInitialized();

  // Save to local storage
  final notification = PushNotificationMapper.fromRemoteMessage(message);
  final dto = PushNotificationMapper.toDto(notification);
  await repository.appendNotification(dto);

  // Display local notification
  await displayLocalNotification(message);
}

/// Scenario 4: App Opened from Terminated State
/// Fires when user taps notification to open app from completely closed state
Future<void> onInitialMessage(RemoteMessage message) async {
  print('=== SCENARIO 4: App Opened from Terminated State ===');
  print('Message ID: ${message.messageId}');
  print('Title: ${message.notification?.title}');
  print('Body: ${message.notification?.body}');
  print('Data: ${message.data}');
  print('====================================================');

  // Ensure repository is initialized
  final repository = await _ensureRepositoryInitialized();

  // Mark notification as read if exists
  final notificationId = message.messageId;
  if (notificationId != null) {
    await repository.markNotificationReadById(notificationId);
  }

  await _navigateToNotificationDetail(repository, message);
}
