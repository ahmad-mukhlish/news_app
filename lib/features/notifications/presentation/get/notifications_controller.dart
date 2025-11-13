import 'package:get/get.dart';

import '../../../../app/data/notification/mappers/push_notification_mapper.dart';
import '../../../../app/domain/entities/push_notification.dart';
import '../../data/repositories/notification_repository.dart';
import '../views/screen/notification_detail_screen.dart';

class NotificationsController extends GetxController {
  final NotificationRepository _repository;

  NotificationsController({required NotificationRepository repository})
      : _repository = repository;

  final RxList<PushNotification> notifications = <PushNotification>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    try {
      isLoading.value = true;
      final dtos = await _repository.getAllNotifications();
      notifications.value = PushNotificationMapper.toEntityList(dtos);
    } catch (e) {
      print('Error loading notifications: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _repository.markNotificationReadById(notificationId);

      // Update local list
      final index = notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        notifications[index] = notifications[index].copyWith(isRead: true);
        notifications.refresh();
      }
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _repository.markAllNotificationsRead();

      // Update local list
      notifications.value = notifications.map((n) => n.copyWith(isRead: true)).toList();
    } catch (e) {
      print('Error marking all notifications as read: $e');
    }
  }

  void navigateToDetail(PushNotification notification) {
    Get.to(
      () => NotificationDetailScreen(notification: notification),
      preventDuplicates: true,
    )?.then((_) {
      // Reload notifications when coming back from detail
      loadNotifications();
    });
  }
}
