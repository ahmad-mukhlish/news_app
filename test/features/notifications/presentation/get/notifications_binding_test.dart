import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:news_app/app/services/storage/local_storage_service.dart';
import 'package:news_app/features/notifications/data/datasources/local/notification_local_data_source.dart';
import 'package:news_app/features/notifications/data/repositories/notification_repository.dart';
import 'package:news_app/features/notifications/presentation/get/notifications_binding.dart';
import 'package:news_app/features/notifications/presentation/get/notifications_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
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

  Future<void> pump() => Future<void>.delayed(Duration.zero);

  test('dependencies registers storage, data source, repository, and controller', () async {
    NotificationsBinding().dependencies();
    await pump();

    expect(Get.isRegistered<LocalStorageService>(), isTrue);
    expect(Get.isRegistered<NotificationLocalDataSource>(), isTrue);
    expect(Get.isRegistered<NotificationRepository>(), isTrue);
    expect(Get.isRegistered<NotificationsController>(), isTrue);
  });

  test('reusing binding does not overwrite existing instances', () async {
    NotificationsBinding().dependencies();
    await pump();
    final initialRepository = Get.find<NotificationRepository>();

    NotificationsBinding().dependencies();
    await pump();

    expect(Get.find<NotificationRepository>(), same(initialRepository));
  });
}
