import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';

import '../../../domain/entities/push_notification.dart';
import '../dto/push_notification_dto.dart';

class PushNotificationMapper {
  /// Convert DTO to Entity
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

  /// Convert Entity to DTO
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

  /// Convert list of DTOs to list of Entities
  static List<PushNotification> toEntityList(List<PushNotificationDto> dtoList) {
    return dtoList.map((dto) => toEntity(dto)).toList();
  }

  /// Convert list of Entities to list of DTOs
  static List<PushNotificationDto> toDtoList(List<PushNotification> entityList) {
    return entityList.map((entity) => toDto(entity)).toList();
  }

  /// Convert Firebase RemoteMessage to Entity
  static PushNotification fromRemoteMessage(RemoteMessage message) {
    // Extract image URL from various sources
    final imageUrl = message.notification?.android?.imageUrl ??
        message.notification?.apple?.imageUrl ??
        message.data['imageUrl'];
    final dataTitle = message.data['title']?.toString();
    final dataBody = message.data['body']?.toString();

    return PushNotification(
      id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: message.notification?.title ?? dataTitle ?? 'No Title',
      body: message.notification?.body ?? dataBody ?? 'No Body',
      receivedAt: DateTime.now(),
      data: message.data.isNotEmpty ? message.data : null,
      imageUrl: imageUrl,
      isRead: false,
    );
  }

  /// Convert Firebase RemoteMessage directly to DTO (useful for persistence)
  static PushNotificationDto dtoFromRemoteMessage(RemoteMessage message) {
    return toDto(fromRemoteMessage(message));
  }

  /// Deserialize JSON string to list of DTOs
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

  /// Serialize list of DTOs to JSON string
  static String dtoListToJsonString(List<PushNotificationDto> dtos) {
    final jsonList = dtos.map((dto) => dto.toJson()).toList();
    return jsonEncode(jsonList);
  }
}
