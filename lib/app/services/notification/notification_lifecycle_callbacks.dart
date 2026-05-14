import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import '../../../app/data/notification/mappers/push_notification_mapper.dart';
import '../../../features/notifications/data/repositories/notification_repository.dart';
import '../../helper/common_methods/navigation_methods.dart';
import 'local_notification_display.dart';
import 'notification_repository_provider.dart';

Future<NotificationRepository> _ensureRepositoryInitialized() async {
  return ensureNotificationRepositoryInitialized();
}

class NotificationLifecycleCallbacks {
  static void register() {
    OneSignal.Notifications.addForegroundWillDisplayListener((event) async {
      await handleForegroundNotification(
        notification: event.notification,
        preventDefault: event.preventDefault,
      );
    });

    OneSignal.Notifications.addClickListener((event) async {
      await handleNotificationClick(event.notification);
    });
  }

  @visibleForTesting
  static Future<void> handleForegroundNotification({
    required OSNotification notification,
    required void Function() preventDefault,
  }) async {
    developer.log('=== Foreground Notification Received ===');
    developer.log('Title: ${notification.title}');
    developer.log('Body: ${notification.body}');

    final repository = await _ensureRepositoryInitialized();
    final dto = PushNotificationMapper.dtoFromOneSignalNotification(notification);
    await repository.appendNotification(dto);

    preventDefault();
    unawaited(displayLocalNotification(notification));
  }

  @visibleForTesting
  static Future<void> handleNotificationClick(OSNotification notification) async {
    developer.log('=== Notification Tapped ===');
    developer.log('Title: ${notification.title}');

    final notificationId = notification.notificationId;
    final repository = await _ensureRepositoryInitialized();

    // Background/killed notifications arrive natively — save to repo on first tap
    var dto = await repository.getNotificationById(notificationId);
    if (dto == null) {
      final newDto = PushNotificationMapper.dtoFromOneSignalNotification(notification);
      await repository.appendNotification(newDto);
      dto = await repository.getNotificationById(notificationId);
    }

    final notifEntity = dto != null
        ? PushNotificationMapper.toEntity(dto)
        : PushNotificationMapper.fromOneSignalNotification(notification);

    await navigateToNotificationDetail(
      notification: notifEntity,
      ensureNavigatorReady: true,
      onMarkAsRead: repository.markNotificationReadById,
    );
  }
}
