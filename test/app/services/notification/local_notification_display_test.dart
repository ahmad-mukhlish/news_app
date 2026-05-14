import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:news_app/app/data/notification/dto/push_notification_dto.dart';
import 'package:news_app/app/helper/common_methods/navigation_methods.dart'
    as navigation_methods;
import 'package:news_app/app/services/notification/local_notification_display.dart';
import 'package:news_app/features/notifications/data/repositories/notification_repository.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import 'local_notification_display_test.mocks.dart';

OSNotification buildNotification({
  String notificationId = '123',
  String? title,
  String? body,
  Map<String, dynamic>? additionalData,
}) {
  return OSNotification({
    'notificationId': notificationId,
    if (title != null) 'title': title,
    if (body != null) 'body': body,
    if (additionalData != null) 'additionalData': additionalData,
  });
}

@GenerateMocks([
  FlutterLocalNotificationsPlugin,
  AndroidFlutterLocalNotificationsPlugin,
  NotificationRepository,
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockFlutterLocalNotificationsPlugin mockNotificationsPlugin;
  late MockAndroidFlutterLocalNotificationsPlugin mockAndroidPlugin;
  late MockNotificationRepository mockNotificationRepository;

  setUp(() {
    Get.testMode = true;
    Get.reset();

    mockNotificationsPlugin = MockFlutterLocalNotificationsPlugin();
    mockAndroidPlugin = MockAndroidFlutterLocalNotificationsPlugin();
    mockNotificationRepository = MockNotificationRepository();
    Get.put<NotificationRepository>(mockNotificationRepository);

    when(
      mockNotificationsPlugin.initialize(
        any,
        onDidReceiveNotificationResponse:
            anyNamed('onDidReceiveNotificationResponse'),
        onDidReceiveBackgroundNotificationResponse:
            anyNamed('onDidReceiveBackgroundNotificationResponse'),
      ),
    ).thenAnswer((_) async => true);
    when(
      mockNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >(),
    ).thenReturn(mockAndroidPlugin);
    when(mockAndroidPlugin.createNotificationChannel(any))
        .thenAnswer((_) async {});
    when(
      mockNotificationsPlugin.show(
        any,
        any,
        any,
        any,
        payload: anyNamed('payload'),
      ),
    ).thenAnswer((_) async {});

    setLocalNotificationsPluginForTesting(
      mockNotificationsPlugin,
      initialized: false,
    );
  });

  tearDown(() {
    Get.reset();
    resetLocalNotificationsTestingState();
    navigation_methods.resetGoToNotificationDetail();
  });

  test('initializes plugin on first call and shows notification', () async {
    final notification = buildNotification(
      title: 'Breaking News',
      body: 'Something happened',
      additionalData: {'extra': 'value'},
    );

    await displayLocalNotification(notification);

    verify(
      mockNotificationsPlugin.initialize(
        any,
        onDidReceiveNotificationResponse:
            anyNamed('onDidReceiveNotificationResponse'),
        onDidReceiveBackgroundNotificationResponse:
            anyNamed('onDidReceiveBackgroundNotificationResponse'),
      ),
    ).called(1);
    verify(mockAndroidPlugin.createNotificationChannel(any)).called(1);

    final captured = verify(
      mockNotificationsPlugin.show(
        any,
        captureAny,
        captureAny,
        any,
        payload: captureAnyNamed('payload'),
      ),
    ).captured;

    expect(captured[0], 'Breaking News');
    expect(captured[1], 'Something happened');

    final payload = captured[2] as String;
    final decoded = jsonDecode(payload) as Map<String, dynamic>;
    expect(decoded['notificationId'], '123');
    expect(decoded['data'], containsPair('extra', 'value'));
  });

  test('does not show notification when title and body are both empty', () async {
    final notification = buildNotification();

    await displayLocalNotification(notification);

    verifyNever(
      mockNotificationsPlugin.show(
        any,
        any,
        any,
        any,
        payload: anyNamed('payload'),
      ),
    );
  });

  test('skips re-initialization on subsequent calls', () async {
    setLocalNotificationsPluginForTesting(
      mockNotificationsPlugin,
      initialized: true,
    );
    final notification = buildNotification(title: 'Title', body: 'Body');

    await displayLocalNotification(notification);

    verifyNever(
      mockNotificationsPlugin.initialize(
        any,
        onDidReceiveNotificationResponse:
            anyNamed('onDidReceiveNotificationResponse'),
        onDidReceiveBackgroundNotificationResponse:
            anyNamed('onDidReceiveBackgroundNotificationResponse'),
      ),
    );
    verify(
      mockNotificationsPlugin.show(any, any, any, any,
          payload: anyNamed('payload')),
    ).called(1);
  });

  test('handleLocalNotificationResponse navigates using stored notification',
      () async {
    final payload = const {
      'notificationId': 'notif-1',
      'title': 'Payload Title',
      'body': 'Payload Body',
      'receivedAt': '2024-01-01T12:00:00.000Z',
      'data': {'foo': 'bar'},
    };

    when(mockNotificationRepository.getNotificationById('notif-1'))
        .thenAnswer(
      (_) async => PushNotificationDto(
        id: 'notif-1',
        title: 'Stored Title',
        body: 'Stored body',
        receivedAt: DateTime(2024, 1, 1, 12).toIso8601String(),
        data: const {'foo': 'bar'},
        isRead: false,
      ),
    );
    when(mockNotificationRepository.markNotificationReadById('notif-1'))
        .thenAnswer((_) async {});

    var navigated = false;
    navigation_methods.goToNotificationDetail = ({
      required notification,
      bool ensureNavigatorReady = false,
      Future<void> Function(String notificationId)? onMarkAsRead,
    }) async {
      navigated = true;
      expect(notification.title, 'Stored Title');
      expect(ensureNavigatorReady, isTrue);
      await onMarkAsRead?.call(notification.id);
    };

    final response = NotificationResponse(
      notificationResponseType: NotificationResponseType.selectedNotification,
      payload: jsonEncode(payload),
    );

    await handleLocalNotificationResponse(response);

    expect(navigated, isTrue);
    verify(mockNotificationRepository.markNotificationReadById('notif-1'))
        .called(1);
  });

  test(
    'handleLocalNotificationResponse uses payload fallback when repository misses',
    () async {
      when(mockNotificationRepository.getNotificationById(any))
          .thenAnswer((_) async => null);

      var navigated = false;
      navigation_methods.goToNotificationDetail = ({
        required notification,
        bool ensureNavigatorReady = false,
        Future<void> Function(String notificationId)? onMarkAsRead,
      }) async {
        navigated = true;
        expect(notification.title, 'Payload Title');
        expect(notification.data, containsPair('foo', 'bar'));
      };

      final response = NotificationResponse(
        notificationResponseType:
            NotificationResponseType.selectedNotificationAction,
        payload: jsonEncode({
          'notificationId': 'notif-2',
          'title': 'Payload Title',
          'body': 'Payload Body',
          'receivedAt': '2024-01-01T12:00:00.000Z',
          'data': {'foo': 'bar'},
        }),
      );

      await handleLocalNotificationResponse(response);

      expect(navigated, isTrue);
    },
  );
}
