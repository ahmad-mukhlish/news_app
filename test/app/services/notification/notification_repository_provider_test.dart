import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:news_app/app/services/notification/notification_repository_provider.dart';
import 'package:news_app/app/services/storage/local_storage_service.dart';
import 'package:news_app/features/notifications/data/datasources/local/notification_local_data_source.dart';
import 'package:news_app/features/notifications/data/repositories/notification_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.reset();
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(Get.reset);

  group('ensureNotificationRepositoryInitialized', () {
    test('registers repository and dependencies when missing', () async {
      final repository = await ensureNotificationRepositoryInitialized();

      expect(repository, isA<NotificationRepository>());
      expect(Get.isRegistered<LocalStorageService>(), isTrue);
      expect(Get.isRegistered<NotificationLocalDataSource>(), isTrue);
      expect(Get.isRegistered<NotificationRepository>(), isTrue);
      expect(Get.find<NotificationRepository>(), same(repository));
    });

    test('returns existing repository without registering dependencies',
        () async {
      final prefs = await SharedPreferences.getInstance();
      final storage = LocalStorageService(prefs: prefs);
      final dataSource =
          NotificationLocalDataSource(storageService: storage);
      final preRegisteredRepo =
          NotificationRepository(localDataSource: dataSource);
      Get.put<NotificationRepository>(preRegisteredRepo);

      final repository = await ensureNotificationRepositoryInitialized();

      expect(repository, same(preRegisteredRepo));
      expect(Get.isRegistered<LocalStorageService>(), isFalse);
      expect(Get.isRegistered<NotificationLocalDataSource>(), isFalse);
    });
  });
}
