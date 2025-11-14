import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../app/services/storage/local_storage_service.dart';
import '../../data/datasources/local/notification_local_data_source.dart';
import '../../data/repositories/notification_repository.dart';
import 'notifications_controller.dart';

class NotificationsBinding extends Bindings {
  @override
  void dependencies() {
    // Initialize repository dependencies if not already registered
    if (!Get.isRegistered<NotificationRepository>()) {
      if (!Get.isRegistered<LocalStorageService>()) {
        Get.putAsync<LocalStorageService>(
          () async {
            final prefs = await SharedPreferences.getInstance();
            return LocalStorageService(prefs: prefs);
          },
        );
      }

      if (!Get.isRegistered<NotificationLocalDataSource>()) {
        Get.lazyPut<NotificationLocalDataSource>(
          () => NotificationLocalDataSource(
            storageService: Get.find<LocalStorageService>(),
          ),
        );
      }

      Get.lazyPut<NotificationRepository>(
        () => NotificationRepository(
          localDataSource: Get.find<NotificationLocalDataSource>(),
        ),
      );
    }

    if (!Get.isRegistered<NotificationsController>()) {
      Get.lazyPut<NotificationsController>(
        () => NotificationsController(
          repository: Get.find<NotificationRepository>(),
        ),
      );
    }
  }
}
