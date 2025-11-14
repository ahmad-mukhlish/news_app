import 'package:get/get.dart';

import '../../../categories/presentation/get/categories_binding.dart';
import '../../../home/presentation/get/home_binding.dart';
import '../../../notifications/data/repositories/notification_repository.dart';
import '../../../notifications/presentation/get/notifications_binding.dart';
import '../../../search/presentation/get/search_binding.dart';
import 'main_controller.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {
    // MainController depends on NotificationRepository (badge count), so the
    // notifications controller must be initialized first to guarantee the repo is
    // available before we lazily create the controller.
    NotificationsBinding().dependencies();

    if (!Get.isRegistered<MainController>()) {
      Get.lazyPut<MainController>(
        () => MainController(
          notificationRepository: Get.find<NotificationRepository>(),
        ),
      );
    }

    HomeBinding().dependencies();
    SearchBinding().dependencies();
    CategoriesBinding().dependencies();
  }
}
