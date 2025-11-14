import '../../../../../app/data/notification/dto/push_notification_dto.dart';
import '../../../../../app/data/notification/mappers/push_notification_mapper.dart';
import '../../../../../app/services/storage/local_storage_service.dart';

class NotificationLocalDataSource {
  final LocalStorageService _storageService;

  NotificationLocalDataSource({required LocalStorageService storageService})
      : _storageService = storageService;

  Future<List<PushNotificationDto>> getAll() async {
    final json = await _storageService.getNotificationsJson();
    return PushNotificationMapper.dtoListFromJsonString(json ?? '');
  }

  Future<void> saveAll(List<PushNotificationDto> notifications) async {
    final jsonString = PushNotificationMapper.dtoListToJsonString(notifications);
    await _storageService.saveNotificationsJson(jsonString);
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
