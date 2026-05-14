import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import 'package:news_app/app/helper/common_methods/navigation_methods.dart'
    as navigation_methods;
import 'package:news_app/app/services/notification/local_notification_display.dart';
import 'package:news_app/app/services/notification/notification_lifecycle_callbacks.dart';
import 'package:news_app/features/notifications/data/repositories/notification_repository.dart';
import 'package:mockito/annotations.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import 'local_notification_display_test.mocks.dart'
    hide MockNotificationRepository;
import 'notification_lifecycle_callbacks_test.mocks.dart';

OSNotification buildNotification({
  String notificationId = 'notif-123',
  String title = 'Test Title',
  String body = 'Test Body',
  Map<String, dynamic>? additionalData,
  String? bigPicture,
}) {
  return OSNotification({
    'notificationId': notificationId,
    'title': title,
    'body': body,
    if (additionalData != null) 'additionalData': additionalData,
    if (bigPicture != null) 'bigPicture': bigPicture,
  });
}

@GenerateMocks([NotificationRepository])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockNotificationRepository mockRepository;
  late MockFlutterLocalNotificationsPlugin mockPlugin;
  late MockAndroidFlutterLocalNotificationsPlugin mockAndroidPlugin;

  setUp(() {
    Get.reset();
    mockRepository = MockNotificationRepository();
    Get.put<NotificationRepository>(mockRepository);

    mockPlugin = MockFlutterLocalNotificationsPlugin();
    mockAndroidPlugin = MockAndroidFlutterLocalNotificationsPlugin();

    when(
      mockPlugin.initialize(
        any,
        onDidReceiveNotificationResponse:
            anyNamed('onDidReceiveNotificationResponse'),
        onDidReceiveBackgroundNotificationResponse:
            anyNamed('onDidReceiveBackgroundNotificationResponse'),
      ),
    ).thenAnswer((_) async => true);
    when(
      mockPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >(),
    ).thenReturn(mockAndroidPlugin);
    when(mockAndroidPlugin.createNotificationChannel(any))
        .thenAnswer((_) async {});
    when(
      mockPlugin.show(any, any, any, any, payload: anyNamed('payload')),
    ).thenAnswer((_) async {});

    setLocalNotificationsPluginForTesting(mockPlugin, initialized: false);

    navigation_methods.goToNotificationDetail = ({
      required notification,
      bool ensureNavigatorReady = false,
      Future<void> Function(String notificationId)? onMarkAsRead,
    }) async {};

    when(mockRepository.appendNotification(any)).thenAnswer((_) => Future<void>.value());
    when(mockRepository.markNotificationReadById(any)).thenAnswer((_) => Future<void>.value());
    when(mockRepository.getNotificationById(any)).thenAnswer((_) async => null);
  });

  tearDown(() {
    Get.reset();
    resetLocalNotificationsTestingState();
    navigation_methods.resetGoToNotificationDetail();
  });

  group('handleForegroundNotification', () {
    test('saves notification to repository and calls preventDefault', () async {
      final notification = buildNotification();
      var preventDefaultCalled = false;

      await NotificationLifecycleCallbacks.handleForegroundNotification(
        notification: notification,
        preventDefault: () => preventDefaultCalled = true,
      );

      verify(mockRepository.appendNotification(any)).called(1);
      expect(preventDefaultCalled, isTrue);
    });

    test('shows local notification via plugin', () async {
      final notification = buildNotification(
        title: 'Breaking News',
        body: 'Something happened',
      );

      await NotificationLifecycleCallbacks.handleForegroundNotification(
        notification: notification,
        preventDefault: () {},
      );

      await Future<void>.delayed(Duration.zero);
      verify(mockPlugin.show(any, any, any, any, payload: anyNamed('payload')))
          .called(1);
    });
  });

  group('handleNotificationClick', () {
    test('saves notification to repo when not already stored', () async {
      when(mockRepository.getNotificationById('notif-123'))
          .thenAnswer((_) async => null);

      await NotificationLifecycleCallbacks.handleNotificationClick(
        buildNotification(),
      );

      verify(mockRepository.appendNotification(any)).called(1);
    });

    test('does not save again if notification already in repo', () async {
      when(mockRepository.getNotificationById('notif-123'))
          .thenAnswer((_) async => null);

      await NotificationLifecycleCallbacks.handleNotificationClick(
        buildNotification(),
      );

      verify(mockRepository.appendNotification(any)).called(1);
    });

    test('marks notification as read and navigates', () async {
      var goToDetailCalled = false;
      navigation_methods.goToNotificationDetail = ({
        required notification,
        bool ensureNavigatorReady = false,
        Future<void> Function(String notificationId)? onMarkAsRead,
      }) async {
        goToDetailCalled = true;
        expect(ensureNavigatorReady, isTrue);
        await onMarkAsRead?.call(notification.id);
      };

      when(mockRepository.getNotificationById('notif-123'))
          .thenAnswer((_) async => null);

      await NotificationLifecycleCallbacks.handleNotificationClick(
        buildNotification(notificationId: 'notif-123'),
      );

      expect(goToDetailCalled, isTrue);
      verify(mockRepository.markNotificationReadById('notif-123')).called(1);
    });

    test('still navigates when notification not in repository', () async {
      when(mockRepository.getNotificationById(any))
          .thenAnswer((_) async => null);

      var navigated = false;
      navigation_methods.goToNotificationDetail = ({
        required notification,
        bool ensureNavigatorReady = false,
        Future<void> Function(String notificationId)? onMarkAsRead,
      }) async {
        navigated = true;
        expect(notification.title, 'Test Title');
      };

      await NotificationLifecycleCallbacks.handleNotificationClick(
        buildNotification(),
      );

      expect(navigated, isTrue);
    });
  });
}
