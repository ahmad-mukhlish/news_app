import 'dart:convert';

import 'package:onesignal_flutter/onesignal_flutter.dart';

import '../../../domain/entities/push_notification.dart';
import '../dto/push_notification_dto.dart';

class PushNotificationMapper {
  static PushNotification toEntity(PushNotificationDto dto) {
    return PushNotification(
      id: dto.id ?? '',
      title: dto.title ?? 'No Title',
      body: dto.body ?? 'No Body',
      receivedAt: dto.receivedAt != null
          ? DateTime.tryParse(dto.receivedAt!) ?? DateTime.now()
          : DateTime.now(),
      data: dto.data,
      imageUrl: dto.imageUrl,
      isRead: dto.isRead ?? false,
    );
  }

  static PushNotificationDto toDto(PushNotification entity) {
    return PushNotificationDto(
      id: entity.id,
      title: entity.title,
      body: entity.body,
      receivedAt: entity.receivedAt.toIso8601String(),
      data: entity.data,
      imageUrl: entity.imageUrl,
      isRead: entity.isRead,
    );
  }

  static List<PushNotification> toEntityList(List<PushNotificationDto> dtoList) {
    return dtoList.map((dto) => toEntity(dto)).toList();
  }

  static List<PushNotificationDto> toDtoList(List<PushNotification> entityList) {
    return entityList.map((entity) => toDto(entity)).toList();
  }

  static PushNotification fromOneSignalNotification(OSNotification notification) {
    return PushNotification(
      id: notification.notificationId,
      title: notification.title ?? 'No Title',
      body: notification.body ?? 'No Body',
      receivedAt: DateTime.now(),
      data: notification.additionalData,
      imageUrl: notification.bigPicture,
      isRead: false,
    );
  }

  static PushNotificationDto dtoFromOneSignalNotification(OSNotification notification) {
    return toDto(fromOneSignalNotification(notification));
  }

  static List<PushNotificationDto> dtoListFromJsonString(String json) {
    if (json.isEmpty) return [];

    try {
      final List<dynamic> decoded = jsonDecode(json);
      return decoded
          .map((item) =>
              PushNotificationDto.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  static String dtoListToJsonString(List<PushNotificationDto> dtos) {
    final jsonList = dtos.map((dto) => dto.toJson()).toList();
    return jsonEncode(jsonList);
  }
}
