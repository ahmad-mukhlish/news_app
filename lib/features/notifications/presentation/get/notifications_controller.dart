import 'package:get/get.dart';

import '../../../../app/domain/entities/push_notification.dart';
import '../../data/repositories/notification_repository.dart';
import '../views/screen/notification_detail_screen.dart';

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
      print('Error loading notifications: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _repository.markNotificationReadById(notificationId);
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _repository.markAllNotificationsRead();
    } catch (e) {
      print('Error marking all notifications as read: $e');
    }
  }

  void navigateToDetail(PushNotification notification) {
    Get.to(
      () => NotificationDetailScreen(notification: notification),
      preventDuplicates: true,
    );
  }
}
