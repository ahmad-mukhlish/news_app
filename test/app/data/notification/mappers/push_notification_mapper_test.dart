import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/app/data/notification/dto/push_notification_dto.dart';
import 'package:news_app/app/data/notification/mappers/push_notification_mapper.dart';
import 'package:news_app/app/domain/entities/push_notification.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

OSNotification buildNotification({
  String notificationId = 'notif-123',
  String? title,
  String? body,
  Map<String, dynamic>? additionalData,
  String? bigPicture,
}) {
  return OSNotification({
    'notificationId': notificationId,
    if (title != null) 'title': title,
    if (body != null) 'body': body,
    if (additionalData != null) 'additionalData': additionalData,
    if (bigPicture != null) 'bigPicture': bigPicture,
  });
}

void main() {
  group('PushNotificationMapper', () {
    group('toEntity', () {
      test('should handle all null values from DTO with defaults', () {
        final dto = PushNotificationDto(
          id: null,
          title: null,
          body: null,
          receivedAt: null,
          data: null,
          imageUrl: null,
          isRead: null,
        );

        final result = PushNotificationMapper.toEntity(dto);

        expect(result.id, '');
        expect(result.title, 'No Title');
        expect(result.body, 'No Body');
        expect(result.receivedAt, isA<DateTime>());
        expect(result.data, null);
        expect(result.imageUrl, null);
        expect(result.isRead, false);
      });

      test('should map all valid values correctly', () {
        final now = DateTime.now();
        final dto = PushNotificationDto(
          id: 'test-id-123',
          title: 'Test Notification',
          body: 'This is a test notification',
          receivedAt: now.toIso8601String(),
          data: {'key': 'value', 'count': 42},
          imageUrl: 'https://example.com/image.jpg',
          isRead: true,
        );

        final result = PushNotificationMapper.toEntity(dto);

        expect(result.id, 'test-id-123');
        expect(result.title, 'Test Notification');
        expect(result.body, 'This is a test notification');
        expect(result.receivedAt.year, now.year);
        expect(result.receivedAt.month, now.month);
        expect(result.receivedAt.day, now.day);
        expect(result.data, {'key': 'value', 'count': 42});
        expect(result.imageUrl, 'https://example.com/image.jpg');
        expect(result.isRead, true);
      });

      test('should handle invalid date string by using current date', () {
        final dto = PushNotificationDto(
          id: 'test-id',
          receivedAt: 'invalid-date-format',
        );

        final result = PushNotificationMapper.toEntity(dto);

        expect(result.receivedAt, isA<DateTime>());
        final now = DateTime.now();
        expect(result.receivedAt.year, now.year);
      });

      test('should use default false for isRead when null', () {
        final dto = PushNotificationDto(id: 'test-id', isRead: null);

        final result = PushNotificationMapper.toEntity(dto);

        expect(result.isRead, false);
      });
    });

    group('toDto', () {
      test('should convert entity to DTO correctly', () {
        final now = DateTime.now();
        final entity = PushNotification(
          id: 'entity-id-456',
          title: 'Entity Title',
          body: 'Entity Body',
          receivedAt: now,
          data: {'foo': 'bar'},
          imageUrl: 'https://example.com/entity.png',
          isRead: true,
        );

        final result = PushNotificationMapper.toDto(entity);

        expect(result.id, 'entity-id-456');
        expect(result.title, 'Entity Title');
        expect(result.body, 'Entity Body');
        expect(result.receivedAt, now.toIso8601String());
        expect(result.data, {'foo': 'bar'});
        expect(result.imageUrl, 'https://example.com/entity.png');
        expect(result.isRead, true);
      });

      test('should handle null optional fields', () {
        final entity = PushNotification(
          id: 'simple-id',
          title: 'Simple Title',
          body: 'Simple Body',
          receivedAt: DateTime.now(),
          data: null,
          imageUrl: null,
          isRead: false,
        );

        final result = PushNotificationMapper.toDto(entity);

        expect(result.id, 'simple-id');
        expect(result.data, null);
        expect(result.imageUrl, null);
        expect(result.isRead, false);
      });
    });

    group('toEntityList', () {
      test('should return empty list for empty input', () {
        final result = PushNotificationMapper.toEntityList([]);
        expect(result, isEmpty);
      });

      test('should map multiple DTOs to entities correctly', () {
        final dtoList = [
          PushNotificationDto(id: '1', title: 'Notification 1', body: 'Body 1'),
          PushNotificationDto(id: '2', title: 'Notification 2', body: 'Body 2'),
          PushNotificationDto(id: '3', title: 'Notification 3', body: 'Body 3'),
        ];

        final result = PushNotificationMapper.toEntityList(dtoList);

        expect(result.length, 3);
        expect(result[0].id, '1');
        expect(result[1].id, '2');
        expect(result[2].id, '3');
      });
    });

    group('toDtoList', () {
      test('should return empty list for empty input', () {
        final result = PushNotificationMapper.toDtoList([]);
        expect(result, isEmpty);
      });

      test('should map multiple entities to DTOs correctly', () {
        final now = DateTime.now();
        final entityList = [
          PushNotification(id: 'e1', title: 'Entity 1', body: 'Body 1', receivedAt: now),
          PushNotification(id: 'e2', title: 'Entity 2', body: 'Body 2', receivedAt: now),
        ];

        final result = PushNotificationMapper.toDtoList(entityList);

        expect(result.length, 2);
        expect(result[0].id, 'e1');
        expect(result[1].id, 'e2');
      });
    });

    group('fromOneSignalNotification', () {
      test('should map all fields correctly', () {
        final notification = buildNotification(
          notificationId: 'os-notif-123',
          title: 'OneSignal Title',
          body: 'OneSignal Body',
          additionalData: {'custom': 'data'},
          bigPicture: 'https://example.com/image.jpg',
        );

        final result = PushNotificationMapper.fromOneSignalNotification(notification);

        expect(result.id, 'os-notif-123');
        expect(result.title, 'OneSignal Title');
        expect(result.body, 'OneSignal Body');
        expect(result.receivedAt, isA<DateTime>());
        expect(result.data, {'custom': 'data'});
        expect(result.imageUrl, 'https://example.com/image.jpg');
        expect(result.isRead, false);
      });

      test('should use defaults when title and body are absent', () {
        final notification = buildNotification(notificationId: 'no-content');

        final result = PushNotificationMapper.fromOneSignalNotification(notification);

        expect(result.id, 'no-content');
        expect(result.title, 'No Title');
        expect(result.body, 'No Body');
        expect(result.data, null);
        expect(result.imageUrl, null);
      });

      test('should handle null additionalData and bigPicture', () {
        final notification = buildNotification(
          title: 'Title',
          body: 'Body',
        );

        final result = PushNotificationMapper.fromOneSignalNotification(notification);

        expect(result.data, null);
        expect(result.imageUrl, null);
      });
    });

    group('dtoFromOneSignalNotification', () {
      test('should convert OSNotification to DTO', () {
        final notification = buildNotification(
          notificationId: 'dto-os-notif',
          title: 'DTO Test',
          body: 'DTO Body',
          additionalData: {'test': 'value'},
        );

        final result =
            PushNotificationMapper.dtoFromOneSignalNotification(notification);

        expect(result.id, 'dto-os-notif');
        expect(result.title, 'DTO Test');
        expect(result.body, 'DTO Body');
        expect(result.data, {'test': 'value'});
        expect(result.isRead, false);
      });
    });

    group('dtoListFromJsonString', () {
      test('should deserialize valid JSON array to DTO list', () {
        const json = '''
        [
          {
            "id": "1",
            "title": "First",
            "body": "First body",
            "receivedAt": "2024-01-01T10:00:00Z",
            "isRead": false
          },
          {
            "id": "2",
            "title": "Second",
            "body": "Second body",
            "receivedAt": "2024-01-02T10:00:00Z",
            "isRead": true
          }
        ]
        ''';

        final result = PushNotificationMapper.dtoListFromJsonString(json);

        expect(result.length, 2);
        expect(result[0].id, '1');
        expect(result[0].isRead, false);
        expect(result[1].id, '2');
        expect(result[1].isRead, true);
      });

      test('should return empty list for empty string', () {
        final result = PushNotificationMapper.dtoListFromJsonString('');
        expect(result, isEmpty);
      });

      test('should return empty list for invalid JSON', () {
        final result =
            PushNotificationMapper.dtoListFromJsonString('not valid json {]');
        expect(result, isEmpty);
      });

      test('should handle JSON with null values', () {
        const json = '''
        [
          {
            "id": "null-test",
            "title": null,
            "body": null,
            "receivedAt": null,
            "data": null,
            "imageUrl": null,
            "isRead": null
          }
        ]
        ''';

        final result = PushNotificationMapper.dtoListFromJsonString(json);

        expect(result.length, 1);
        expect(result[0].id, 'null-test');
        expect(result[0].title, null);
      });

      test('should handle JSON with data field', () {
        const json = '''
        [
          {
            "id": "with-data",
            "title": "Has Data",
            "body": "Body",
            "data": {"custom": "value", "number": 42}
          }
        ]
        ''';

        final result = PushNotificationMapper.dtoListFromJsonString(json);

        expect(result.length, 1);
        expect(result[0].data!['custom'], 'value');
        expect(result[0].data!['number'], 42);
      });
    });

    group('dtoListToJsonString', () {
      test('should serialize DTO list to JSON string', () {
        final dtoList = [
          PushNotificationDto(
            id: 'json-1',
            title: 'First Notification',
            body: 'First body',
            receivedAt: '2024-01-01T10:00:00Z',
            isRead: false,
          ),
          PushNotificationDto(
            id: 'json-2',
            title: 'Second Notification',
            body: 'Second body',
            receivedAt: '2024-01-02T10:00:00Z',
            isRead: true,
          ),
        ];

        final result = PushNotificationMapper.dtoListToJsonString(dtoList);

        expect(result, contains('"id":"json-1"'));
        expect(result, contains('"title":"First Notification"'));
        expect(result, contains('"isRead":true'));
      });

      test('should handle empty list', () {
        expect(PushNotificationMapper.dtoListToJsonString([]), '[]');
      });

      test('should serialize DTO with data field', () {
        final dtoList = [
          PushNotificationDto(
            id: 'with-data',
            title: 'Test',
            body: 'Body',
            data: {'key': 'value', 'count': 5},
          ),
        ];

        final result = PushNotificationMapper.dtoListToJsonString(dtoList);

        expect(result, contains('"key":"value"'));
        expect(result, contains('"count":5'));
      });
    });

    group('round-trip serialization', () {
      test('should maintain data integrity through serialization cycle', () {
        final originalDtoList = [
          PushNotificationDto(
            id: 'round-trip-1',
            title: 'Round Trip Test',
            body: 'Test Body',
            receivedAt: '2024-01-15T12:30:00Z',
            data: {'custom': 'value', 'number': 42},
            imageUrl: 'https://example.com/image.jpg',
            isRead: true,
          ),
        ];

        final jsonString =
            PushNotificationMapper.dtoListToJsonString(originalDtoList);
        final deserializedDtoList =
            PushNotificationMapper.dtoListFromJsonString(jsonString);

        expect(deserializedDtoList.length, 1);
        expect(deserializedDtoList[0].id, originalDtoList[0].id);
        expect(deserializedDtoList[0].title, originalDtoList[0].title);
        expect(deserializedDtoList[0].isRead, originalDtoList[0].isRead);
        expect(deserializedDtoList[0].data!['custom'], 'value');
        expect(deserializedDtoList[0].data!['number'], 42);
      });
    });
  });
}
