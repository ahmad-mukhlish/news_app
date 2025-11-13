import 'package:get/get.dart';

import '../../../../app/data/notification/dto/push_notification_dto.dart';
import '../../../../app/data/notification/mappers/push_notification_mapper.dart';
import '../../../../app/domain/entities/push_notification.dart';
import '../datasources/local/notification_local_data_source.dart';

class NotificationRepository {
  final NotificationLocalDataSource _localDataSource;
  final RxList<PushNotification> notifications = <PushNotification>[].obs;

  NotificationRepository({
    required NotificationLocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;

  Future<void> appendNotification(PushNotificationDto pushNotifDto) async {
    final pushNotifDtos = await _localDataSource.getAll();
    pushNotifDtos.insert(0, pushNotifDto);
    await _localDataSource.saveAll(pushNotifDtos);
    _syncInMemoryNotifications(pushNotifDtos);
  }

  Future<List<PushNotificationDto>> getAllNotifications() async {
    final pushNotifDtos = await _localDataSource.getAll();
    _syncInMemoryNotifications(pushNotifDtos);
    return pushNotifDtos;
  }

  Future<PushNotificationDto?> getNotificationById(String id) async {
    return await _localDataSource.getById(id);
  }

  Future<int> getUnreadNotificationCount() async {
    final pushNotifDtos = await _localDataSource.getAll();
    return pushNotifDtos
        .where((pushNotifDto) => pushNotifDto.isRead != true)
        .length;
  }

  Future<void> markNotificationReadById(String id) async {
    final pushNotifDtos = await _localDataSource.getAll();
    final updatedNotifications = pushNotifDtos.map((pushNotifDto) {
      if (pushNotifDto.id == id) {
        return PushNotificationDto(
          id: pushNotifDto.id,
          title: pushNotifDto.title,
          body: pushNotifDto.body,
          receivedAt: pushNotifDto.receivedAt,
          data: pushNotifDto.data,
          imageUrl: pushNotifDto.imageUrl,
          isRead: true,
        );
      }
      return pushNotifDto;
    }).toList();
    await _localDataSource.saveAll(updatedNotifications);
    _syncInMemoryNotifications(updatedNotifications);
  }

  Future<void> markAllNotificationsRead() async {
    final pushNotifDtos = await _localDataSource.getAll();
    final updatedNotifications = pushNotifDtos.map((pushNotifDto) {
      return PushNotificationDto(
        id: pushNotifDto.id,
        title: pushNotifDto.title,
        body: pushNotifDto.body,
        receivedAt: pushNotifDto.receivedAt,
        data: pushNotifDto.data,
        imageUrl: pushNotifDto.imageUrl,
        isRead: true,
      );
    }).toList();
    await _localDataSource.saveAll(updatedNotifications);
    _syncInMemoryNotifications(updatedNotifications);
  }

  void _syncInMemoryNotifications(List<PushNotificationDto> pushNotifDtos) {
    notifications.assignAll(PushNotificationMapper.toEntityList(pushNotifDtos));
  }
}
