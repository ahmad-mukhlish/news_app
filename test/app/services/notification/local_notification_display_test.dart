import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:news_app/app/services/notification/local_notification_display.dart';

import 'local_notification_display_test.mocks.dart';

@GenerateMocks([
  FlutterLocalNotificationsPlugin,
  AndroidFlutterLocalNotificationsPlugin,
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockFlutterLocalNotificationsPlugin mockNotificationsPlugin;
  late MockAndroidFlutterLocalNotificationsPlugin mockAndroidPlugin;

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
    mockNotificationsPlugin = MockFlutterLocalNotificationsPlugin();
    mockAndroidPlugin = MockAndroidFlutterLocalNotificationsPlugin();

    when(mockNotificationsPlugin.initialize(any))
        .thenAnswer((_) async => true);
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
    resetLocalNotificationsTestingState();
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

    verify(mockNotificationsPlugin.initialize(any)).called(1);
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
    expect(captured[2], contains('"extra":"value"'));
  });
}
