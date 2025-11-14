import '../../../../../app/data/notification/dto/push_notification_dto.dart';
import '../../../../../app/services/storage/local_storage_service.dart';

class NotificationLocalDataSource {
  final LocalStorageService _storageService;

  NotificationLocalDataSource({required LocalStorageService storageService})
      : _storageService = storageService;

  Future<List<PushNotificationDto>> getAll() async {
    return _storageService.getNotifications();
  }

  Future<void> saveAll(List<PushNotificationDto> notifications) async {
    await _storageService.saveNotifications(notifications);
  }

  Future<PushNotificationDto?> getById(String id) async {
    final notifications = await getAll();
    try {
      return notifications.firstWhere((n) => n.id == id);
    } catch (e) {
      return null;
    }
  }
}
