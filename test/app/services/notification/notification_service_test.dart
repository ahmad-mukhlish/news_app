import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_messaging_platform_interface/firebase_messaging_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:news_app/app/services/notification/notification_service.dart';

import 'notification_service_test.mocks.dart';

const NotificationSettings _defaultSettings = NotificationSettings(
  alert: AppleNotificationSetting.enabled,
  announcement: AppleNotificationSetting.notSupported,
  authorizationStatus: AuthorizationStatus.authorized,
  badge: AppleNotificationSetting.enabled,
  carPlay: AppleNotificationSetting.notSupported,
  lockScreen: AppleNotificationSetting.enabled,
  notificationCenter: AppleNotificationSetting.enabled,
  showPreviews: AppleShowPreviewSetting.always,
  sound: AppleNotificationSetting.enabled,
  timeSensitive: AppleNotificationSetting.notSupported,
  criticalAlert: AppleNotificationSetting.notSupported,
  providesAppNotificationSettings: AppleNotificationSetting.notSupported,
);

class TestFirebaseMessagingPlatform extends FirebaseMessagingPlatform {
  TestFirebaseMessagingPlatform() : super();

  BackgroundMessageHandler? backgroundHandler;

  @override
  FirebaseMessagingPlatform delegateFor({required FirebaseApp app}) {
    return this;
  }

  @override
  FirebaseMessagingPlatform setInitialValues({bool? isAutoInitEnabled}) {
    return this;
  }

  @override
  void registerBackgroundMessageHandler(BackgroundMessageHandler handler) {
    backgroundHandler = handler;
  }

  @override
  bool get isAutoInitEnabled => true;

  @override
  Stream<String> get onTokenRefresh => const Stream.empty();

  @override
  Future<RemoteMessage?> getInitialMessage() async => null;

  @override
  Future<void> deleteToken() async {}

  @override
  Future<String?> getAPNSToken() async => null;

  @override
  Future<String?> getToken({String? vapidKey}) async => null;

  @override
  Future<NotificationSettings> getNotificationSettings() async =>
      _defaultSettings;

  @override
  Future<bool> isSupported() async => true;

  @override
  Future<NotificationSettings> requestPermission({
    bool alert = true,
    bool announcement = false,
    bool badge = true,
    bool carPlay = false,
    bool criticalAlert = false,
    bool provisional = false,
    bool sound = true,
    bool providesAppNotificationSettings = false,
  }) async {
    return _defaultSettings;
  }

  @override
  Future<void> setAutoInitEnabled(bool enabled) async {}

  @override
  Future<void> setForegroundNotificationPresentationOptions({
    required bool alert,
    required bool badge,
    required bool sound,
  }) async {}

  @override
  Future<void> subscribeToTopic(String topic) async {}

  @override
  Future<void> unsubscribeFromTopic(String topic) async {}

  @override
  Future<void> setDeliveryMetricsExportToBigQuery(bool enabled) async {}
}

@GenerateMocks([FirebaseMessaging])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NotificationService', () {
    late MockFirebaseMessaging mockMessaging;
    late NotificationService service;
    late StreamController<String> tokenRefreshController;
    late TestFirebaseMessagingPlatform fakePlatform;

    setUp(() {
      fakePlatform = TestFirebaseMessagingPlatform();
      FirebaseMessagingPlatform.instance = fakePlatform;

      mockMessaging = MockFirebaseMessaging();
      tokenRefreshController = StreamController<String>.broadcast();

      when(mockMessaging.getNotificationSettings())
          .thenAnswer((_) async => _defaultSettings);
      when(mockMessaging.getToken()).thenAnswer((_) async => 'initial-token');
      when(mockMessaging.onTokenRefresh)
          .thenAnswer((_) => tokenRefreshController.stream);
      when(mockMessaging.getInitialMessage()).thenAnswer((_) async => null);

      service = NotificationService(messaging: mockMessaging);
    });

    tearDown(() async {
      await tokenRefreshController.close();
    });

    test('init fetches token, subscribes to refresh and registers background handler',
        () async {
      final result = await service.init();

      expect(result, same(service));
      expect(service.fcmToken, 'initial-token');
      expect(fakePlatform.backgroundHandler, isNotNull);

      tokenRefreshController.add('new-token');
      await Future<void>.delayed(Duration.zero);
      expect(service.fcmToken, 'new-token');

      verify(mockMessaging.getNotificationSettings()).called(1);
      verify(mockMessaging.getToken()).called(1);
      verify(mockMessaging.onTokenRefresh).called(1);
      verify(mockMessaging.getInitialMessage()).called(1);
    });

    test('init completes even when initial token retrieval fails', () async {
      when(mockMessaging.getToken()).thenThrow(Exception('network-error'));

      await service.init();

      expect(service.fcmToken, isNull);
    });
  });
}
