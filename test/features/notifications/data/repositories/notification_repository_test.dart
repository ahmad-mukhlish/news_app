import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:news_app/app/data/notification/dto/push_notification_dto.dart';
import 'package:news_app/features/notifications/data/datasources/local/notification_local_data_source.dart';
import 'package:news_app/features/notifications/data/repositories/notification_repository.dart';

import 'notification_repository_test.mocks.dart';

@GenerateMocks([NotificationLocalDataSource])
void main() {
  late NotificationRepository repository;
  late MockNotificationLocalDataSource mockLocalDataSource;

  setUp(() {
    mockLocalDataSource = MockNotificationLocalDataSource();
    repository =
        NotificationRepository(localDataSource: mockLocalDataSource);
  });

  group('NotificationRepository', () {
    group('appendNotification', () {
      test('should insert notification at the beginning of the list', () async {
        final existingNotifications = [
          PushNotificationDto(
            id: 'existing-1',
            title: 'Existing 1',
            body: 'Body 1',
            isRead: false,
          ),
          PushNotificationDto(
            id: 'existing-2',
            title: 'Existing 2',
            body: 'Body 2',
            isRead: true,
          ),
        ];

        final newNotification = PushNotificationDto(
          id: 'new-1',
          title: 'New Notification',
          body: 'New Body',
          isRead: false,
        );

        when(mockLocalDataSource.getAll())
            .thenAnswer((_) async => existingNotifications);
        when(mockLocalDataSource.saveAll(any)).thenAnswer((_) async => {});

        await repository.appendNotification(newNotification);

        final captured =
            verify(mockLocalDataSource.saveAll(captureAny)).captured;
        final savedList = captured[0] as List<PushNotificationDto>;

        expect(savedList.length, 3);
        expect(savedList[0].id, 'new-1');
        expect(savedList[1].id, 'existing-1');
        expect(savedList[2].id, 'existing-2');
        verify(mockLocalDataSource.getAll()).called(1);
      });

      test('should add first notification to empty list', () async {
        final newNotification = PushNotificationDto(
          id: 'first',
          title: 'First Notification',
          body: 'First Body',
        );

        when(mockLocalDataSource.getAll()).thenAnswer((_) async => []);
        when(mockLocalDataSource.saveAll(any)).thenAnswer((_) async => {});

        await repository.appendNotification(newNotification);

        final captured =
            verify(mockLocalDataSource.saveAll(captureAny)).captured;
        final savedList = captured[0] as List<PushNotificationDto>;

        expect(savedList.length, 1);
        expect(savedList[0].id, 'first');
      });

      test('should sync in-memory notifications after appending', () async {
        final existingNotifications = [
          PushNotificationDto(
            id: 'existing',
            title: 'Existing',
            body: 'Body',
          ),
        ];

        final newNotification = PushNotificationDto(
          id: 'new',
          title: 'New',
          body: 'Body',
        );

        when(mockLocalDataSource.getAll())
            .thenAnswer((_) async => existingNotifications);
        when(mockLocalDataSource.saveAll(any)).thenAnswer((_) async => {});

        await repository.appendNotification(newNotification);

        expect(repository.notifications.length, 2);
        expect(repository.notifications[0].id, 'new');
        expect(repository.notifications[1].id, 'existing');
      });
    });

    group('getAllNotifications', () {
      test('should return all notifications from data source', () async {
        final mockNotifications = [
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
        ];

        when(mockLocalDataSource.getAll())
            .thenAnswer((_) async => mockNotifications);

        final result = await repository.getAllNotifications();

        expect(result.length, 2);
        expect(result[0].id, '1');
        expect(result[1].id, '2');
        verify(mockLocalDataSource.getAll()).called(1);
      });

      test('should return empty list when no notifications exist', () async {
        when(mockLocalDataSource.getAll()).thenAnswer((_) async => []);

        final result = await repository.getAllNotifications();

        expect(result, isEmpty);
        verify(mockLocalDataSource.getAll()).called(1);
      });

      test('should sync in-memory notifications after getting all', () async {
        final mockNotifications = [
          PushNotificationDto(
            id: '1',
            title: 'Notification 1',
            body: 'Body 1',
          ),
        ];

        when(mockLocalDataSource.getAll())
            .thenAnswer((_) async => mockNotifications);

        await repository.getAllNotifications();

        expect(repository.notifications.length, 1);
        expect(repository.notifications[0].id, '1');
        expect(repository.notifications[0].title, 'Notification 1');
      });

      test('should handle notifications with all fields', () async {
        final mockNotifications = [
          PushNotificationDto(
            id: 'full',
            title: 'Full Notification',
            body: 'Full Body',
            receivedAt: '2024-01-01T10:00:00Z',
            data: {'key': 'value'},
            imageUrl: 'https://example.com/image.jpg',
            isRead: true,
          ),
        ];

        when(mockLocalDataSource.getAll())
            .thenAnswer((_) async => mockNotifications);

        final result = await repository.getAllNotifications();

        expect(result[0].id, 'full');
        expect(result[0].title, 'Full Notification');
        expect(result[0].data!['key'], 'value');
        expect(result[0].imageUrl, 'https://example.com/image.jpg');
        expect(result[0].isRead, true);
      });
    });

    group('getNotificationById', () {
      test('should return notification when ID exists', () async {
        final mockNotification = PushNotificationDto(
          id: 'found',
          title: 'Found Notification',
          body: 'Found Body',
        );

        when(mockLocalDataSource.getById('found'))
            .thenAnswer((_) async => mockNotification);

        final result = await repository.getNotificationById('found');

        expect(result, isNotNull);
        expect(result!.id, 'found');
        expect(result.title, 'Found Notification');
        verify(mockLocalDataSource.getById('found')).called(1);
      });

      test('should return null when ID does not exist', () async {
        when(mockLocalDataSource.getById('not-found'))
            .thenAnswer((_) async => null);

        final result = await repository.getNotificationById('not-found');

        expect(result, isNull);
        verify(mockLocalDataSource.getById('not-found')).called(1);
      });
    });

    group('getUnreadNotificationCount', () {
      test('should return count of unread notifications', () async {
        final mockNotifications = [
          PushNotificationDto(id: '1', isRead: false),
          PushNotificationDto(id: '2', isRead: true),
          PushNotificationDto(id: '3', isRead: false),
          PushNotificationDto(id: '4', isRead: false),
          PushNotificationDto(id: '5', isRead: true),
        ];

        when(mockLocalDataSource.getAll())
            .thenAnswer((_) async => mockNotifications);

        final result = await repository.getUnreadNotificationCount();

        expect(result, 3);
        verify(mockLocalDataSource.getAll()).called(1);
      });

      test('should return 0 when all notifications are read', () async {
        final mockNotifications = [
          PushNotificationDto(id: '1', isRead: true),
          PushNotificationDto(id: '2', isRead: true),
        ];

        when(mockLocalDataSource.getAll())
            .thenAnswer((_) async => mockNotifications);

        final result = await repository.getUnreadNotificationCount();

        expect(result, 0);
      });

      test('should return 0 when no notifications exist', () async {
        when(mockLocalDataSource.getAll()).thenAnswer((_) async => []);

        final result = await repository.getUnreadNotificationCount();

        expect(result, 0);
      });

      test('should treat null isRead as unread', () async {
        final mockNotifications = [
          PushNotificationDto(id: '1', isRead: null),
          PushNotificationDto(id: '2', isRead: false),
          PushNotificationDto(id: '3', isRead: true),
        ];

        when(mockLocalDataSource.getAll())
            .thenAnswer((_) async => mockNotifications);

        final result = await repository.getUnreadNotificationCount();

        expect(result, 2);
      });

      test('should return all when all notifications are unread', () async {
        final mockNotifications = [
          PushNotificationDto(id: '1', isRead: false),
          PushNotificationDto(id: '2', isRead: false),
          PushNotificationDto(id: '3', isRead: false),
        ];

        when(mockLocalDataSource.getAll())
            .thenAnswer((_) async => mockNotifications);

        final result = await repository.getUnreadNotificationCount();

        expect(result, 3);
      });
    });

    group('markNotificationReadById', () {
      test('should mark specific notification as read', () async {
        final mockNotifications = [
          PushNotificationDto(
            id: '1',
            title: 'Notification 1',
            body: 'Body 1',
            isRead: false,
          ),
          PushNotificationDto(
            id: '2',
            title: 'Notification 2',
            body: 'Body 2',
            isRead: false,
          ),
        ];

        when(mockLocalDataSource.getAll())
            .thenAnswer((_) async => mockNotifications);
        when(mockLocalDataSource.saveAll(any)).thenAnswer((_) async => {});

        await repository.markNotificationReadById('1');

        final captured =
            verify(mockLocalDataSource.saveAll(captureAny)).captured;
        final savedList = captured[0] as List<PushNotificationDto>;

        expect(savedList[0].id, '1');
        expect(savedList[0].isRead, true);
        expect(savedList[1].id, '2');
        expect(savedList[1].isRead, false);
      });

      test('should preserve all fields when marking as read', () async {
        final mockNotifications = [
          PushNotificationDto(
            id: 'preserve',
            title: 'Preserve Title',
            body: 'Preserve Body',
            receivedAt: '2024-01-01T10:00:00Z',
            data: {'key': 'value'},
            imageUrl: 'https://example.com/image.jpg',
            isRead: false,
          ),
        ];

        when(mockLocalDataSource.getAll())
            .thenAnswer((_) async => mockNotifications);
        when(mockLocalDataSource.saveAll(any)).thenAnswer((_) async => {});

        await repository.markNotificationReadById('preserve');

        final captured =
            verify(mockLocalDataSource.saveAll(captureAny)).captured;
        final savedList = captured[0] as List<PushNotificationDto>;

        expect(savedList[0].id, 'preserve');
        expect(savedList[0].title, 'Preserve Title');
        expect(savedList[0].body, 'Preserve Body');
        expect(savedList[0].receivedAt, '2024-01-01T10:00:00Z');
        expect(savedList[0].data!['key'], 'value');
        expect(savedList[0].imageUrl, 'https://example.com/image.jpg');
        expect(savedList[0].isRead, true);
      });

      test('should not affect other notifications', () async {
        final mockNotifications = [
          PushNotificationDto(id: '1', isRead: false),
          PushNotificationDto(id: '2', isRead: true),
          PushNotificationDto(id: '3', isRead: false),
        ];

        when(mockLocalDataSource.getAll())
            .thenAnswer((_) async => mockNotifications);
        when(mockLocalDataSource.saveAll(any)).thenAnswer((_) async => {});

        await repository.markNotificationReadById('3');

        final captured =
            verify(mockLocalDataSource.saveAll(captureAny)).captured;
        final savedList = captured[0] as List<PushNotificationDto>;

        expect(savedList[0].isRead, false);
        expect(savedList[1].isRead, true);
        expect(savedList[2].isRead, true);
      });

      test('should sync in-memory notifications after marking as read',
          () async {
        final mockNotifications = [
          PushNotificationDto(
            id: '1',
            title: 'Notification 1',
            body: 'Body 1',
            isRead: false,
          ),
        ];

        when(mockLocalDataSource.getAll())
            .thenAnswer((_) async => mockNotifications);
        when(mockLocalDataSource.saveAll(any)).thenAnswer((_) async => {});

        await repository.markNotificationReadById('1');

        expect(repository.notifications.length, 1);
        expect(repository.notifications[0].isRead, true);
      });
    });

    group('markAllNotificationsRead', () {
      test('should mark all notifications as read', () async {
        final mockNotifications = [
          PushNotificationDto(
            id: '1',
            title: 'Notification 1',
            body: 'Body 1',
            isRead: false,
          ),
          PushNotificationDto(
            id: '2',
            title: 'Notification 2',
            body: 'Body 2',
            isRead: false,
          ),
          PushNotificationDto(
            id: '3',
            title: 'Notification 3',
            body: 'Body 3',
            isRead: true,
          ),
        ];

        when(mockLocalDataSource.getAll())
            .thenAnswer((_) async => mockNotifications);
        when(mockLocalDataSource.saveAll(any)).thenAnswer((_) async => {});

        await repository.markAllNotificationsRead();

        final captured =
            verify(mockLocalDataSource.saveAll(captureAny)).captured;
        final savedList = captured[0] as List<PushNotificationDto>;

        expect(savedList.length, 3);
        expect(savedList[0].isRead, true);
        expect(savedList[1].isRead, true);
        expect(savedList[2].isRead, true);
      });

      test('should preserve all fields when marking all as read', () async {
        final mockNotifications = [
          PushNotificationDto(
            id: 'full',
            title: 'Full Title',
            body: 'Full Body',
            receivedAt: '2024-01-01T10:00:00Z',
            data: {'key': 'value'},
            imageUrl: 'https://example.com/image.jpg',
            isRead: false,
          ),
        ];

        when(mockLocalDataSource.getAll())
            .thenAnswer((_) async => mockNotifications);
        when(mockLocalDataSource.saveAll(any)).thenAnswer((_) async => {});

        await repository.markAllNotificationsRead();

        final captured =
            verify(mockLocalDataSource.saveAll(captureAny)).captured;
        final savedList = captured[0] as List<PushNotificationDto>;

        expect(savedList[0].id, 'full');
        expect(savedList[0].title, 'Full Title');
        expect(savedList[0].body, 'Full Body');
        expect(savedList[0].data!['key'], 'value');
        expect(savedList[0].imageUrl, 'https://example.com/image.jpg');
        expect(savedList[0].isRead, true);
      });

      test('should handle empty list', () async {
        when(mockLocalDataSource.getAll()).thenAnswer((_) async => []);
        when(mockLocalDataSource.saveAll(any)).thenAnswer((_) async => {});

        await repository.markAllNotificationsRead();

        final captured =
            verify(mockLocalDataSource.saveAll(captureAny)).captured;
        final savedList = captured[0] as List<PushNotificationDto>;

        expect(savedList, isEmpty);
      });

      test('should sync in-memory notifications after marking all as read',
          () async {
        final mockNotifications = [
          PushNotificationDto(
            id: '1',
            title: 'Notification 1',
            body: 'Body 1',
            isRead: false,
          ),
          PushNotificationDto(
            id: '2',
            title: 'Notification 2',
            body: 'Body 2',
            isRead: false,
          ),
        ];

        when(mockLocalDataSource.getAll())
            .thenAnswer((_) async => mockNotifications);
        when(mockLocalDataSource.saveAll(any)).thenAnswer((_) async => {});

        await repository.markAllNotificationsRead();

        expect(repository.notifications.length, 2);
        expect(repository.notifications[0].isRead, true);
        expect(repository.notifications[1].isRead, true);
      });
    });

    group('error handling', () {
      test('appendNotification should propagate data source errors', () async {
        when(mockLocalDataSource.getAll())
            .thenThrow(Exception('Storage error'));

        final notification = PushNotificationDto(id: '1', title: 'Test');

        expect(
          () => repository.appendNotification(notification),
          throwsException,
        );
      });

      test('getAllNotifications should propagate data source errors', () async {
        when(mockLocalDataSource.getAll())
            .thenThrow(Exception('Storage error'));

        expect(
          () => repository.getAllNotifications(),
          throwsException,
        );
      });

      test('getUnreadNotificationCount should propagate data source errors',
          () async {
        when(mockLocalDataSource.getAll())
            .thenThrow(Exception('Storage error'));

        expect(
          () => repository.getUnreadNotificationCount(),
          throwsException,
        );
      });

      test('markNotificationReadById should propagate data source errors',
          () async {
        when(mockLocalDataSource.getAll())
            .thenThrow(Exception('Storage error'));

        expect(
          () => repository.markNotificationReadById('1'),
          throwsException,
        );
      });

      test('markAllNotificationsRead should propagate data source errors',
          () async {
        when(mockLocalDataSource.getAll())
            .thenThrow(Exception('Storage error'));

        expect(
          () => repository.markAllNotificationsRead(),
          throwsException,
        );
      });
    });
  });
}
