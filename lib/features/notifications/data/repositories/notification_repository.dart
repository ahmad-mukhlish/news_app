import '../../../../app/data/notification/dto/push_notification_dto.dart';
import '../../../../app/services/storage/local_storage_service.dart';
import '../datasources/local/notification_local_data_source.dart';

class NotificationRepository {
  final NotificationLocalDataSource _localDataSource;
  final LocalStorageService _storageService;

  NotificationRepository({
    required NotificationLocalDataSource localDataSource,
    required LocalStorageService storageService,
  }) : _localDataSource = localDataSource,
       _storageService = storageService;

  Future<void> saveFcmToken(String token) async {
    await _storageService.saveFcmToken(token);
  }

  Future<String?> getFcmToken() async {
    return await _storageService.getFcmToken();
  }

  Future<void> appendNotification(PushNotificationDto notification) async {
    final notifications = await _localDataSource.getAll();
    notifications.insert(0, notification);
    await _localDataSource.saveAll(notifications);
  }

  Future<List<PushNotificationDto>> getAllNotifications() async {
    return await _localDataSource.getAll();
  }

  Future<PushNotificationDto?> getNotificationById(String id) async {
    return await _localDataSource.getById(id);
  }

  Future<int> getUnreadNotificationCount() async {
    final notifications = await _localDataSource.getAll();
    return notifications
        .where((notification) => notification.isRead != true)
        .length;
  }

  Future<void> markNotificationReadById(String id) async {
    final notifications = await _localDataSource.getAll();
    final updatedNotifications = notifications.map((notification) {
      if (notification.id == id) {
        return PushNotificationDto(
          id: notification.id,
          title: notification.title,
          body: notification.body,
          receivedAt: notification.receivedAt,
          data: notification.data,
          imageUrl: notification.imageUrl,
          isRead: true,
        );
      }
      return notification;
    }).toList();
    await _localDataSource.saveAll(updatedNotifications);
  }

  Future<void> markAllNotificationsRead() async {
    final notifications = await _localDataSource.getAll();
    final updatedNotifications = notifications.map((notification) {
      return PushNotificationDto(
        id: notification.id,
        title: notification.title,
        body: notification.body,
        receivedAt: notification.receivedAt,
        data: notification.data,
        imageUrl: notification.imageUrl,
        isRead: true,
      );
    }).toList();
    await _localDataSource.saveAll(updatedNotifications);
  }
}
