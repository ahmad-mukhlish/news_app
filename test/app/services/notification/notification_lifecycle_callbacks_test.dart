import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:news_app/features/notifications/data/repositories/notification_repository.dart';

import 'package:news_app/app/services/notification/notification_lifecycle_callbacks.dart';

import 'notification_lifecycle_callbacks_test.mocks.dart';

@GenerateMocks([NotificationRepository])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockNotificationRepository mockRepository;
  late bool displayCalled;
  late bool? displayForceFlag;

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

    when(mockRepository.appendNotification(any)).thenAnswer((_) async {});
  });

  tearDown(() {
    Get.reset();
    resetDisplayNotificationDisplayer();
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
}
