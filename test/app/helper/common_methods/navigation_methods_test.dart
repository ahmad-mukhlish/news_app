import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:news_app/app/domain/entities/push_notification.dart';
import 'package:news_app/app/helper/common_methods/navigation_methods.dart'
    as navigation_methods;
import 'package:news_app/app/services/storage/local_storage_service.dart';
import 'package:news_app/features/main/presentation/get/main_controller.dart';
import 'package:news_app/features/notifications/data/repositories/notification_repository.dart';
import 'package:news_app/features/notifications/presentation/get/notifications_binding.dart';
import 'package:news_app/features/notifications/presentation/get/notifications_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    Get.testMode = true;
    Get.reset();
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    Get.put<LocalStorageService>(
      LocalStorageService(prefs: prefs),
    );
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets(
    'goToNotificationDetail marks notification as read before navigating',
    (WidgetTester tester) async {
      await tester.pumpWidget(const GetMaterialApp(home: SizedBox.shrink()));

      await tester.runAsync(() async {
        await _ensureNotificationsDependenciesReady();
        final notification = _buildNotification(isRead: false);
        var markInvocations = 0;

        await navigation_methods.goToNotificationDetail(
          notification: notification,
          onMarkAsRead: (notificationId) async {
            markInvocations++;
            expect(notificationId, notification.id);
          },
        );

        expect(markInvocations, 1);
      });
    },
  );

  testWidgets(
    'goToNotificationDetail does not call onMarkAsRead when notification already read',
    (WidgetTester tester) async {
      await tester.pumpWidget(const GetMaterialApp(home: SizedBox.shrink()));

      await tester.runAsync(() async {
        await _ensureNotificationsDependenciesReady();
        var markInvocations = 0;

        await navigation_methods.goToNotificationDetail(
          notification: _buildNotification(isRead: true),
          onMarkAsRead: (_) async {
            markInvocations++;
          },
        );

        expect(markInvocations, 0);
      });
    },
  );

  testWidgets(
    'goToNotificationDetail selects notifications tab when MainController is registered',
    (WidgetTester tester) async {
      await tester.pumpWidget(const GetMaterialApp(home: SizedBox.shrink()));

      await tester.runAsync(() async {
        await _ensureNotificationsDependenciesReady();

        final repository = Get.find<NotificationRepository>();
        final mainController =
            MainController(notificationRepository: repository);
        Get.put<MainController>(mainController);

        expect(mainController.selectedIndex.value, 0);

        await navigation_methods.goToNotificationDetail(
          notification: _buildNotification(isRead: true),
        );

        expect(
          mainController.selectedIndex.value,
          MainController.notificationsTabIndex,
        );
      });
    },
  );

  testWidgets(
    'goToNotificationDetail waits for navigator readiness before pushing detail screen',
    (WidgetTester tester) async {
      await tester.runAsync(() async {
        await _ensureNotificationsDependenciesReady();
        var navigationCompleted = false;

        final navigationFuture = navigation_methods.goToNotificationDetail(
          notification: _buildNotification(isRead: true),
          ensureNavigatorReady: true,
        ).then((_) => navigationCompleted = true);

        expect(Get.key.currentState, isNull);

        await Future<void>.delayed(const Duration(milliseconds: 120));
        await tester.pumpWidget(const GetMaterialApp(home: SizedBox.shrink()));
        await tester.pumpAndSettle();

        await navigationFuture;

        expect(navigationCompleted, isTrue);
        expect(Get.key.currentState?.canPop(), isTrue);
      });
    },
  );
}

PushNotification _buildNotification({bool isRead = false}) {
  return PushNotification(
    id: 'notif-123',
    title: 'Breaking News',
    body: 'Read the latest update',
    receivedAt: DateTime(2024, 1, 1, 12),
    isRead: isRead,
  );
}

Future<void> _ensureNotificationsDependenciesReady() async {
  NotificationsBinding().dependencies();

  var attempts = 0;
  while (!Get.isRegistered<LocalStorageService>() && attempts < 20) {
    await Future<void>.delayed(const Duration(milliseconds: 10));
    attempts++;
  }

  if (!Get.isRegistered<NotificationsController>()) {
    await Future<void>.delayed(Duration.zero);
  }

  if (!Get.isRegistered<NotificationRepository>()) {
    await Future<void>.delayed(Duration.zero);
  }

  expect(Get.isRegistered<NotificationsController>(), isTrue);
  expect(Get.isRegistered<NotificationRepository>(), isTrue);
}
