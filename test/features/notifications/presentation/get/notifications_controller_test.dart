import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:news_app/app/domain/entities/push_notification.dart';
import 'package:news_app/app/helper/common_methods/navigation_methods.dart'
    as navigation_methods;
import 'package:news_app/features/notifications/data/repositories/notification_repository.dart';
import 'package:news_app/features/notifications/presentation/get/notifications_controller.dart';

import 'notifications_controller_test.mocks.dart';

@GenerateMocks([NotificationRepository])
void main() {
  late NotificationsController controller;
  late MockNotificationRepository mockRepository;
  late RxList<PushNotification> repositoryNotifications;

  setUp(() {
    mockRepository = MockNotificationRepository();
    repositoryNotifications = <PushNotification>[].obs;
    when(mockRepository.notifications).thenReturn(repositoryNotifications);
    controller = NotificationsController(repository: mockRepository);
  });

  group('loadNotifications', () {
    test('sets loading state and fetches notifications', () async {
      when(mockRepository.getAllNotifications()).thenAnswer((_) async {
        expect(controller.isLoading.value, isTrue);
        return [];
      });

      await controller.loadNotifications();

      expect(controller.isLoading.value, isFalse);
      verify(mockRepository.getAllNotifications()).called(1);
    });

    test('resets loading flag when repository throws', () async {
      when(mockRepository.getAllNotifications()).thenThrow(Exception('failure'));

      await controller.loadNotifications();

      expect(controller.isLoading.value, isFalse);
    });
  });

  test('markAsRead delegates to repository', () async {
    when(mockRepository.markNotificationReadById('notif-id'))
        .thenAnswer((_) async {});

    await controller.markAsRead('notif-id');

    verify(mockRepository.markNotificationReadById('notif-id')).called(1);
  });

  test('markAllAsRead delegates to repository', () async {
    when(mockRepository.markAllNotificationsRead()).thenAnswer((_) async {});

    await controller.markAllAsRead();

    verify(mockRepository.markAllNotificationsRead()).called(1);
  });

  test('navigateToDetail calls navigation helper with onMarkAsRead callback', () async {
    final notification = PushNotification(
      id: 'notif-1',
      title: 'Title',
      body: 'Body',
      receivedAt: DateTime(2024, 1, 1),
    );

    var callbackInvoked = false;
    navigation_methods.goToNotificationDetail = ({
      required PushNotification notification,
      bool ensureNavigatorReady = false,
      Future<void> Function(String notificationId)? onMarkAsRead,
    }) async {
      callbackInvoked = true;
      expect(onMarkAsRead, isNotNull);
      await onMarkAsRead!(notification.id);
    };

    when(mockRepository.markNotificationReadById(notification.id))
        .thenAnswer((_) async {});

    await controller.navigateToDetail(notification);

    expect(callbackInvoked, isTrue);
    verify(mockRepository.markNotificationReadById(notification.id)).called(1);
    navigation_methods.resetGoToNotificationDetail();
  });
}
