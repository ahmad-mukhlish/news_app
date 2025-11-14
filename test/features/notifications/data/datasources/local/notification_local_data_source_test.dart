import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:news_app/app/data/notification/dto/push_notification_dto.dart';
import 'package:news_app/app/services/storage/local_storage_service.dart';
import 'package:news_app/features/notifications/data/datasources/local/notification_local_data_source.dart';

import 'notification_local_data_source_test.mocks.dart';

@GenerateMocks([LocalStorageService])
void main() {
  late NotificationLocalDataSource dataSource;
  late MockLocalStorageService mockStorageService;

  setUp(() {
    mockStorageService = MockLocalStorageService();
    dataSource =
        NotificationLocalDataSource(storageService: mockStorageService);
  });

  group('NotificationLocalDataSource', () {
    group('getAll', () {
      test('should return empty list when storage returns empty list', () async {
        when(mockStorageService.getNotifications())
            .thenReturn([]);

        final result = await dataSource.getAll();

        expect(result, isEmpty);
        verify(mockStorageService.getNotifications()).called(1);
      });

      test('should return list of DTOs when storage has notifications',
          () async {
        final notifications = [
          PushNotificationDto(
            id: '1',
            title: 'Notification 1',
            body: 'Body 1',
            receivedAt: '2024-01-01T10:00:00Z',
            isRead: false,
          ),
          PushNotificationDto(
            id: '2',
            title: 'Notification 2',
            body: 'Body 2',
            receivedAt: '2024-01-02T10:00:00Z',
            isRead: true,
          ),
        ];

        when(mockStorageService.getNotifications())
            .thenReturn(notifications);

        final result = await dataSource.getAll();

        expect(result.length, 2);
        expect(result[0].id, '1');
        expect(result[0].title, 'Notification 1');
        expect(result[0].isRead, false);
        expect(result[1].id, '2');
        expect(result[1].title, 'Notification 2');
        expect(result[1].isRead, true);
        verify(mockStorageService.getNotifications()).called(1);
      });

      test('should handle DTOs with null fields', () async {
        final notifications = [
          PushNotificationDto(
            id: 'null-test',
            title: null,
            body: null,
            receivedAt: null,
            data: null,
            imageUrl: null,
            isRead: null,
          ),
        ];

        when(mockStorageService.getNotifications())
            .thenReturn(notifications);

        final result = await dataSource.getAll();

        expect(result.length, 1);
        expect(result[0].id, 'null-test');
        expect(result[0].title, null);
        expect(result[0].body, null);
        verify(mockStorageService.getNotifications()).called(1);
      });

      test('should handle DTOs with data field', () async {
        final notifications = [
          PushNotificationDto(
            id: 'with-data',
            title: 'Has Data',
            body: 'Body',
            data: {'custom': 'value', 'number': 42},
          ),
        ];

        when(mockStorageService.getNotifications())
            .thenReturn(notifications);

        final result = await dataSource.getAll();

        expect(result.length, 1);
        expect(result[0].data, isNotNull);
        expect(result[0].data!['custom'], 'value');
        expect(result[0].data!['number'], 42);
        verify(mockStorageService.getNotifications()).called(1);
      });
    });

    group('saveAll', () {
      test('should save notifications to storage', () async {
        final notifications = [
          PushNotificationDto(
            id: '1',
            title: 'Notification 1',
            body: 'Body 1',
            receivedAt: '2024-01-01T10:00:00Z',
            isRead: false,
          ),
          PushNotificationDto(
            id: '2',
            title: 'Notification 2',
            body: 'Body 2',
            receivedAt: '2024-01-02T10:00:00Z',
            isRead: true,
          ),
        ];

        when(mockStorageService.saveNotifications(any))
            .thenAnswer((_) async => {});

        await dataSource.saveAll(notifications);

        final captured =
            verify(mockStorageService.saveNotifications(captureAny))
                .captured;
        expect(captured.length, 1);

        final savedList = captured[0] as List<PushNotificationDto>;
        expect(savedList.length, 2);
        expect(savedList[0].id, '1');
        expect(savedList[0].title, 'Notification 1');
        expect(savedList[1].id, '2');
        expect(savedList[1].isRead, true);
      });

      test('should save empty list', () async {
        when(mockStorageService.saveNotifications(any))
            .thenAnswer((_) async => {});

        await dataSource.saveAll([]);

        verify(mockStorageService.saveNotifications([])).called(1);
      });

      test('should save notifications with data field', () async {
        final notifications = [
          PushNotificationDto(
            id: 'with-data',
            title: 'Test',
            body: 'Body',
            data: {'key': 'value', 'count': 5},
          ),
        ];

        when(mockStorageService.saveNotifications(any))
            .thenAnswer((_) async => {});

        await dataSource.saveAll(notifications);

        final captured =
            verify(mockStorageService.saveNotifications(captureAny))
                .captured;
        final savedList = captured[0] as List<PushNotificationDto>;

        expect(savedList[0].data, isNotNull);
        expect(savedList[0].data!['key'], 'value');
        expect(savedList[0].data!['count'], 5);
      });

      test('should save notifications with null fields', () async {
        final notifications = [
          PushNotificationDto(
            id: 'null-fields',
            title: null,
            body: null,
            imageUrl: null,
          ),
        ];

        when(mockStorageService.saveNotifications(any))
            .thenAnswer((_) async => {});

        await dataSource.saveAll(notifications);

        final captured =
            verify(mockStorageService.saveNotifications(captureAny))
                .captured;
        final savedList = captured[0] as List<PushNotificationDto>;

        expect(savedList[0].id, 'null-fields');
        expect(savedList[0].title, null);
        expect(savedList[0].body, null);
      });
    });

    group('getById', () {
      test('should return notification when ID exists', () async {
        final notifications = [
          PushNotificationDto(
            id: 'found-id',
            title: 'Found Notification',
            body: 'Found Body',
            isRead: false,
          ),
          PushNotificationDto(
            id: 'another-id',
            title: 'Another Notification',
            body: 'Another Body',
            isRead: true,
          ),
        ];

        when(mockStorageService.getNotifications())
            .thenReturn(notifications);

        final result = await dataSource.getById('found-id');

        expect(result, isNotNull);
        expect(result!.id, 'found-id');
        expect(result.title, 'Found Notification');
        expect(result.body, 'Found Body');
        expect(result.isRead, false);
        verify(mockStorageService.getNotifications()).called(1);
      });

      test('should return null when ID does not exist', () async {
        final notifications = [
          PushNotificationDto(
            id: 'existing-id',
            title: 'Existing',
            body: 'Body',
          ),
        ];

        when(mockStorageService.getNotifications())
            .thenReturn(notifications);

        final result = await dataSource.getById('non-existent-id');

        expect(result, isNull);
        verify(mockStorageService.getNotifications()).called(1);
      });

      test('should return null when storage is empty', () async {
        when(mockStorageService.getNotifications())
            .thenReturn([]);

        final result = await dataSource.getById('any-id');

        expect(result, isNull);
        verify(mockStorageService.getNotifications()).called(1);
      });

      test('should find notification in list with multiple items', () async {
        final notifications = [
          PushNotificationDto(id: '1', title: 'First'),
          PushNotificationDto(id: '2', title: 'Second'),
          PushNotificationDto(id: '3', title: 'Third'),
          PushNotificationDto(id: 'target', title: 'Target Notification'),
          PushNotificationDto(id: '4', title: 'Fourth'),
        ];

        when(mockStorageService.getNotifications())
            .thenReturn(notifications);

        final result = await dataSource.getById('target');

        expect(result, isNotNull);
        expect(result!.id, 'target');
        expect(result.title, 'Target Notification');
        verify(mockStorageService.getNotifications()).called(1);
      });
    });

    group('error handling', () {
      test('getAll should propagate storage service errors', () async {
        when(mockStorageService.getNotifications())
            .thenThrow(Exception('Storage error'));

        expect(
          () => dataSource.getAll(),
          throwsException,
        );
      });

      test('saveAll should propagate storage service errors', () async {
        when(mockStorageService.saveNotifications(any))
            .thenThrow(Exception('Storage error'));

        final notifications = [
          PushNotificationDto(id: '1', title: 'Test'),
        ];

        expect(
          () => dataSource.saveAll(notifications),
          throwsException,
        );
      });
    });
  });
}
