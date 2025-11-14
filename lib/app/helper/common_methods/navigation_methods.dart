import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/push_notification.dart';
import '../../../features/main/presentation/get/main_controller.dart';
import '../../../features/notifications/presentation/get/notifications_binding.dart';
import '../../../features/notifications/presentation/get/notifications_controller.dart';
import '../../../features/notifications/presentation/views/screen/notification_detail_screen.dart';

/// Pushes the notification detail screen while handling optional read state
/// updates and navigator readiness checks.
///
/// [notification] is the item to display, which will be marked as read via
/// [onMarkAsRead] if provided. When [ensureNavigatorReady] is true, the method
/// waits for a navigator before attempting navigation (needed for background
/// callbacks).
typedef GoToNotificationDetailFn = Future<void> Function({
  required PushNotification notification,
  bool ensureNavigatorReady,
  Future<void> Function(String notificationId)? onMarkAsRead,
});

@visibleForTesting
GoToNotificationDetailFn goToNotificationDetail = _goToNotificationDetail;

@visibleForTesting
void resetGoToNotificationDetail() {
  goToNotificationDetail = _goToNotificationDetail;
}

Future<void> _goToNotificationDetail({
  required PushNotification notification,
  bool ensureNavigatorReady = false,
  Future<void> Function(String notificationId)? onMarkAsRead,
}) async {
  final controllerReady = await _ensureNotificationsController();
  if (!controllerReady) {
    developer.log('NotificationsController unavailable, aborting navigation.');
    return;
  }

  var updatedNotification = notification;

  // Allow caller to mark the notification as read prior to navigation.
  if (onMarkAsRead != null && !notification.isRead) {
    await onMarkAsRead(notification.id);
    updatedNotification = notification.copyWith(isRead: true);
  }

  if (ensureNavigatorReady) {
    // Background callbacks can fire before GetMaterialApp has attached a
    // Navigator to Get.key. Poll a few times to wait for it instead of crashing.
    var attempts = 0;
    while (Get.key.currentState == null && attempts < 60) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      attempts++;
    }

    // Bail out if the navigator is still unavailable after our retries.
    if (Get.key.currentState == null) {
      developer.log(
        'Navigator not ready, skipping navigation to NotificationDetailScreen.',
      );
      return;
    }
  }

  final formattedDate =
      DateFormat('MMM d, yyyy • h:mm a').format(updatedNotification.receivedAt);

  _ensureNotificationsTabSelected();

  Get.to(
    () => NotificationDetailScreen(
      notification: updatedNotification,
      formattedDate: formattedDate,
    ),
    preventDuplicates: true,
  );
}

Future<bool> _ensureNotificationsController() async {
  if (Get.isRegistered<NotificationsController>()) {
    return true;
  }

  NotificationsBinding().dependencies();

  var attempts = 0;
  while (!Get.isRegistered<NotificationsController>() && attempts < 60) {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    attempts++;
  }

  return Get.isRegistered<NotificationsController>();
}

void _ensureNotificationsTabSelected() {
  if (Get.isRegistered<MainController>()) {
    final controller = Get.find<MainController>();
    controller.goToNotificationsTab();
  }
}
