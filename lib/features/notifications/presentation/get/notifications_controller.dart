import 'dart:developer' as developer;

import 'package:get/get.dart';

import '../../../../app/domain/entities/push_notification.dart';
import '../../../../app/helper/common_methods/routing_methods.dart';
import '../../data/repositories/notification_repository.dart';

class NotificationsController extends GetxController {
  final NotificationRepository _repository;
  final RxList<PushNotification> notifications;

  NotificationsController({required NotificationRepository repository})
      : _repository = repository,
        notifications = repository.notifications;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    try {
      isLoading.value = true;
      await _repository.getAllNotifications();
    } catch (e) {
      developer.log('Error loading notifications: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _repository.markNotificationReadById(notificationId);
    } catch (e) {
      developer.log('Error marking notification as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _repository.markAllNotificationsRead();
    } catch (e) {
      developer.log('Error marking all notifications as read: $e');
    }
  }

  Future<void> navigateToDetail(PushNotification notification) async {
    await navigateToNotificationDetail(
      notification: notification,
      onMarkAsRead: markAsRead,
    );
  }
}
