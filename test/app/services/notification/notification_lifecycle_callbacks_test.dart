import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:news_app/app/helper/common_methods/navigation_methods.dart'
    as navigation_methods;
import 'package:news_app/app/services/notification/notification_lifecycle_callbacks.dart';
import 'package:news_app/features/notifications/data/repositories/notification_repository.dart';

import 'notification_lifecycle_callbacks_test.mocks.dart';

@GenerateMocks([NotificationRepository])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockNotificationRepository mockRepository;
  late bool displayCalled;
  late bool? displayForceFlag;
  late RemoteMessage defaultNotificationMessage;

  RemoteMessage buildMessage({String? messageId}) {
    return RemoteMessage.fromMap({
      'messageId': messageId ?? 'message-id',
      'sentTime': DateTime.now().millisecondsSinceEpoch,
      'data': {
        'title': 'Hello',
        'body': 'Body',
      },
    });
  }

  setUp(() {
    Get.reset();
    mockRepository = MockNotificationRepository();
    Get.put<NotificationRepository>(mockRepository);

    displayCalled = false;
    displayForceFlag = null;
    setDisplayNotificationDisplayer((message, {bool force = false}) async {
      displayCalled = true;
      displayForceFlag = force;
    });

    navigation_methods.goToNotificationDetail = ({
      required notification,
      bool ensureNavigatorReady = false,
      Future<void> Function(String notificationId)? onMarkAsRead,
    }) async {};

    defaultNotificationMessage = buildMessage(messageId: 'message-id');

    when(mockRepository.appendNotification(any)).thenAnswer((_) async {});
    when(mockRepository.markNotificationReadById(any)).thenAnswer((_) async {});
    when(mockRepository.getNotificationById(any)).thenAnswer((_) async => null);
  });

  tearDown(() {
    Get.reset();
    resetDisplayNotificationDisplayer();
    navigation_methods.resetGoToNotificationDetail();
  });

  test('onForegroundMessage saves notification and forces display', () async {
    final message = buildMessage();

    await onForegroundMessage(message);

    verify(mockRepository.appendNotification(any)).called(1);
    expect(displayCalled, isTrue);
    expect(displayForceFlag, isTrue);
  });

  test('onBackgroundMessage saves notification and displays without force',
      () async {
    final message = buildMessage(messageId: 'bg-id');

    await onBackgroundMessage(message);

    verify(mockRepository.appendNotification(any)).called(1);
    expect(displayCalled, isTrue);
    expect(displayForceFlag, isFalse);
  });

  test('onMessageOpenedApp marks notification read and navigates', () async {
    var goToDetailCalled = false;
    navigation_methods.goToNotificationDetail = ({
      required notification,
      bool ensureNavigatorReady = false,
      Future<void> Function(String notificationId)? onMarkAsRead,
    }) async {
      goToDetailCalled = true;
      expect(ensureNavigatorReady, isTrue);
      expect(notification.id, 'message-id');
    };

    await onMessageOpenedApp(defaultNotificationMessage);

    verify(mockRepository.markNotificationReadById('message-id')).called(1);
    expect(goToDetailCalled, isTrue);
  });

  test('onMessageOpenedApp still navigates when notification not stored', () async {
    when(mockRepository.getNotificationById('message-id'))
        .thenAnswer((_) async => null);

    var goToDetailCalled = false;
    navigation_methods.goToNotificationDetail = ({
      required notification,
      bool ensureNavigatorReady = false,
      Future<void> Function(String notificationId)? onMarkAsRead,
    }) async {
      goToDetailCalled = true;
      expect(notification.id, 'message-id');
    };

    await onMessageOpenedApp(defaultNotificationMessage);

    expect(goToDetailCalled, isTrue);
  });

  test('onInitialMessage marks notification read and navigates', () async {
    var goToDetailCalled = false;
    navigation_methods.goToNotificationDetail = ({
      required notification,
      bool ensureNavigatorReady = false,
      Future<void> Function(String notificationId)? onMarkAsRead,
    }) async {
      goToDetailCalled = true;
      expect(ensureNavigatorReady, isTrue);
    };

    await onInitialMessage(defaultNotificationMessage);

    verify(mockRepository.markNotificationReadById('message-id')).called(1);
    expect(goToDetailCalled, isTrue);
  });
}
