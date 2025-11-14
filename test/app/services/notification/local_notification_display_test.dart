import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
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

import 'local_notification_display_test.mocks.dart';

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

  RemoteMessage buildMessage({
    Map<String, Object?>? notification,
    Map<String, Object?>? data,
  }) {
    return RemoteMessage.fromMap({
      'messageId': '123',
      'sentTime': DateTime.now().millisecondsSinceEpoch,
      'data': data ?? <String, dynamic>{},
      if (notification != null) 'notification': notification,
    });
  }

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

  test(
    'does not display when not forced and notification payload exists',
    () async {
      final message = buildMessage(notification: {
        'title': 'System Title',
        'body': 'System Body',
      });

      await displayLocalNotification(message);

      verifyNever(
        mockNotificationsPlugin.show(
          any,
          any,
          any,
          any,
          payload: anyNamed('payload'),
        ),
      );
    },
  );

  test('displays when forced and uses data payload fallback', () async {
    final message = buildMessage(
      data: {
        'title': 'Data Title',
        'body': 'Data Body',
        'extra': 'value',
      },
    );

    await displayLocalNotification(message, force: true);

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

    expect(captured[0], 'Data Title');
    expect(captured[1], 'Data Body');
    final payload = captured[2] as String;
    final decoded = jsonDecode(payload) as Map<String, dynamic>;
    expect(decoded['notificationId'], '123');
    expect(decoded['data'], containsPair('extra', 'value'));
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
