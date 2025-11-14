import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/app/data/notification/dto/push_notification_dto.dart';
import 'package:news_app/app/data/notification/mappers/push_notification_mapper.dart';
import 'package:news_app/app/domain/entities/push_notification.dart';

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
        final dto = PushNotificationDto(
          id: 'test-id',
          isRead: null,
        );

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
        final dtoList = <PushNotificationDto>[];

        final result = PushNotificationMapper.toEntityList(dtoList);

        expect(result, isEmpty);
      });

      test('should map multiple DTOs to entities correctly', () {
        final dtoList = [
          PushNotificationDto(
            id: '1',
            title: 'Notification 1',
            body: 'Body 1',
          ),
          PushNotificationDto(
            id: '2',
            title: 'Notification 2',
            body: 'Body 2',
          ),
          PushNotificationDto(
            id: '3',
            title: 'Notification 3',
            body: 'Body 3',
          ),
        ];

        final result = PushNotificationMapper.toEntityList(dtoList);

        expect(result.length, 3);
        expect(result[0].id, '1');
        expect(result[0].title, 'Notification 1');
        expect(result[1].id, '2');
        expect(result[1].title, 'Notification 2');
        expect(result[2].id, '3');
        expect(result[2].title, 'Notification 3');
      });
    });

    group('toDtoList', () {
      test('should return empty list for empty input', () {
        final entityList = <PushNotification>[];

        final result = PushNotificationMapper.toDtoList(entityList);

        expect(result, isEmpty);
      });

      test('should map multiple entities to DTOs correctly', () {
        final now = DateTime.now();
        final entityList = [
          PushNotification(
            id: 'e1',
            title: 'Entity 1',
            body: 'Body 1',
            receivedAt: now,
          ),
          PushNotification(
            id: 'e2',
            title: 'Entity 2',
            body: 'Body 2',
            receivedAt: now,
          ),
        ];

        final result = PushNotificationMapper.toDtoList(entityList);

        expect(result.length, 2);
        expect(result[0].id, 'e1');
        expect(result[0].title, 'Entity 1');
        expect(result[1].id, 'e2');
        expect(result[1].title, 'Entity 2');
      });
    });

    group('fromRemoteMessage', () {
      test('should convert RemoteMessage with full notification data', () {
        final remoteMessage = RemoteMessage(
          messageId: 'msg-123',
          notification: const RemoteNotification(
            title: 'Firebase Title',
            body: 'Firebase Body',
          ),
          data: {'custom': 'data', 'value': '123'},
        );

        final result = PushNotificationMapper.fromRemoteMessage(remoteMessage);

        expect(result.id, 'msg-123');
        expect(result.title, 'Firebase Title');
        expect(result.body, 'Firebase Body');
        expect(result.receivedAt, isA<DateTime>());
        expect(result.data, {'custom': 'data', 'value': '123'});
        expect(result.isRead, false);
      });

      test('should use default values when notification is null', () {
        final remoteMessage = RemoteMessage(
          messageId: 'msg-456',
          data: {},
        );

        final result = PushNotificationMapper.fromRemoteMessage(remoteMessage);

        expect(result.id, 'msg-456');
        expect(result.title, 'No Title');
        expect(result.body, 'No Body');
        expect(result.data, null);
      });

      test('should generate ID from timestamp when messageId is null', () {
        final remoteMessage = RemoteMessage(
          messageId: null,
          notification: const RemoteNotification(
            title: 'Test',
            body: 'Test',
          ),
        );

        final result = PushNotificationMapper.fromRemoteMessage(remoteMessage);

        expect(result.id, isNotEmpty);
        expect(int.tryParse(result.id), isNotNull);
      });

      test('should extract imageUrl from data field', () {
        final remoteMessage = RemoteMessage(
          messageId: 'img-msg',
          notification: const RemoteNotification(
            title: 'Image Notification',
            body: 'Has image',
          ),
          data: {'imageUrl': 'https://example.com/from-data.jpg'},
        );

        final result = PushNotificationMapper.fromRemoteMessage(remoteMessage);

        expect(result.imageUrl, 'https://example.com/from-data.jpg');
      });

      test('should handle empty data map', () {
        final remoteMessage = RemoteMessage(
          messageId: 'empty-data',
          notification: const RemoteNotification(
            title: 'No Data',
            body: 'Empty',
          ),
          data: {},
        );

        final result = PushNotificationMapper.fromRemoteMessage(remoteMessage);

        expect(result.data, null);
      });

      test('should preserve non-empty data map', () {
        final remoteMessage = RemoteMessage(
          messageId: 'with-data',
          notification: const RemoteNotification(
            title: 'Has Data',
            body: 'Data present',
          ),
          data: {'key1': 'value1', 'key2': 'value2'},
        );

        final result = PushNotificationMapper.fromRemoteMessage(remoteMessage);

        expect(result.data, isNotNull);
        expect(result.data!['key1'], 'value1');
        expect(result.data!['key2'], 'value2');
      });
    });

    group('dtoFromRemoteMessage', () {
      test('should convert RemoteMessage to DTO', () {
        final remoteMessage = RemoteMessage(
          messageId: 'dto-msg',
          notification: const RemoteNotification(
            title: 'DTO Test',
            body: 'DTO Body',
          ),
          data: {'test': 'value'},
        );

        final result =
            PushNotificationMapper.dtoFromRemoteMessage(remoteMessage);

        expect(result.id, 'dto-msg');
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
        expect(result[0].title, 'First');
        expect(result[0].isRead, false);
        expect(result[1].id, '2');
        expect(result[1].title, 'Second');
        expect(result[1].isRead, true);
      });

      test('should return empty list for empty string', () {
        final result = PushNotificationMapper.dtoListFromJsonString('');

        expect(result, isEmpty);
      });

      test('should return empty list for invalid JSON', () {
        const invalidJson = 'not valid json {]';

        final result = PushNotificationMapper.dtoListFromJsonString(invalidJson);

        expect(result, isEmpty);
      });

      test('should return empty list for malformed JSON', () {
        const malformedJson = '{"incomplete": ';

        final result =
            PushNotificationMapper.dtoListFromJsonString(malformedJson);

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
        expect(result[0].body, null);
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
        expect(result[0].data, isNotNull);
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

        expect(result, isNotEmpty);
        expect(result, contains('"id":"json-1"'));
        expect(result, contains('"title":"First Notification"'));
        expect(result, contains('"id":"json-2"'));
        expect(result, contains('"isRead":true'));
      });

      test('should handle empty list', () {
        final result = PushNotificationMapper.dtoListToJsonString([]);

        expect(result, '[]');
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

        expect(result, contains('"data"'));
        expect(result, contains('"key":"value"'));
        expect(result, contains('"count":5'));
      });

      test('should handle null values in DTO', () {
        final dtoList = [
          PushNotificationDto(
            id: 'null-fields',
            title: null,
            body: null,
            imageUrl: null,
          ),
        ];

        final result = PushNotificationMapper.dtoListToJsonString(dtoList);

        expect(result, contains('"id":"null-fields"'));
        expect(result, contains('"title":null'));
        expect(result, contains('"body":null'));
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

        // Serialize to JSON
        final jsonString =
            PushNotificationMapper.dtoListToJsonString(originalDtoList);

        // Deserialize back to DTO list
        final deserializedDtoList =
            PushNotificationMapper.dtoListFromJsonString(jsonString);

        expect(deserializedDtoList.length, originalDtoList.length);
        expect(deserializedDtoList[0].id, originalDtoList[0].id);
        expect(deserializedDtoList[0].title, originalDtoList[0].title);
        expect(deserializedDtoList[0].body, originalDtoList[0].body);
        expect(deserializedDtoList[0].receivedAt, originalDtoList[0].receivedAt);
        expect(deserializedDtoList[0].imageUrl, originalDtoList[0].imageUrl);
        expect(deserializedDtoList[0].isRead, originalDtoList[0].isRead);
        expect(deserializedDtoList[0].data!['custom'], 'value');
        expect(deserializedDtoList[0].data!['number'], 42);
      });
    });

    group('fromRemoteMessage', () {
      test('falls back to data payload when notification is missing', () {
        final message = RemoteMessage.fromMap({
          'messageId': 'message-1',
          'sentTime': DateTime.now().millisecondsSinceEpoch,
          'data': {'title': 'Data Title', 'body': 'Data Body'},
        });

        final result = PushNotificationMapper.fromRemoteMessage(message);

        expect(result.id, 'message-1');
        expect(result.title, 'Data Title');
        expect(result.body, 'Data Body');
      });
    });
  });
}
