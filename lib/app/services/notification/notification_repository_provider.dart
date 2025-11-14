import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/storage/local_storage_service.dart';
import '../../../features/notifications/data/datasources/local/notification_local_data_source.dart';
import '../../../features/notifications/data/repositories/notification_repository.dart';

/// Ensures that the [NotificationRepository] and its dependencies are
/// registered with GetX before returning the repository instance.
Future<NotificationRepository> ensureNotificationRepositoryInitialized() async {
  if (!Get.isRegistered<NotificationRepository>()) {
    if (!Get.isRegistered<LocalStorageService>()) {
      final prefs = await SharedPreferences.getInstance();
      Get.put(LocalStorageService(prefs: prefs));
    }

    if (!Get.isRegistered<NotificationLocalDataSource>()) {
      final storage = Get.find<LocalStorageService>();
      Get.put(NotificationLocalDataSource(storageService: storage));
    }

    if (!Get.isRegistered<NotificationRepository>()) {
      final dataSource = Get.find<NotificationLocalDataSource>();
      Get.put(NotificationRepository(localDataSource: dataSource));
    }
  }

  return Get.find<NotificationRepository>();
}
