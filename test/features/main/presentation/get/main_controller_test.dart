import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:news_app/app/domain/entities/push_notification.dart';
import 'package:news_app/features/main/presentation/get/main_controller.dart';
import 'package:news_app/features/notifications/data/repositories/notification_repository.dart';

import 'main_controller_test.mocks.dart';

@GenerateMocks([NotificationRepository])
void main() {
  late MockNotificationRepository mockNotificationRepository;
  late RxList<PushNotification> notifications;
  late MainController controller;

  setUp(() {
    mockNotificationRepository = MockNotificationRepository();
    notifications = <PushNotification>[].obs;
    when(mockNotificationRepository.notifications).thenReturn(notifications);
    controller = MainController(notificationRepository: mockNotificationRepository);
  });

  group('MainController', () {
    test('changePage updates selected index', () {
      controller.changePage(2);

      expect(controller.selectedIndex.value, 2);
    });

    test('goToNotificationsTab selects notifications tab index', () {
      controller.goToNotificationsTab();

      expect(controller.selectedIndex.value, MainController.notificationsTabIndex);
    });

    test('unreadCount returns number of unread notifications', () {
      final now = DateTime.now();
      notifications.assignAll([
        PushNotification(
          id: '1',
          title: 'New article',
          body: 'Check this out',
          receivedAt: now,
          isRead: false,
        ),
        PushNotification(
          id: '2',
          title: 'Read message',
          body: 'Already seen',
          receivedAt: now,
          isRead: true,
        ),
        PushNotification(
          id: '3',
          title: 'Another alert',
          body: 'Unread again',
          receivedAt: now,
          isRead: false,
        ),
      ]);

      expect(controller.unreadCount, 2);
    });
  });
}
