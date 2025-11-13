import 'package:get/get.dart';

import '../../../categories/presentation/get/categories_binding.dart';
import '../../../home/presentation/get/home_binding.dart';
import '../../../notifications/presentation/get/notifications_binding.dart';
import '../../../profile/presentation/get/profile_binding.dart';
import '../../../search/presentation/get/search_binding.dart';
import 'main_controller.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<MainController>()) {
      Get.lazyPut<MainController>(
        () => MainController(),
      );
    }

    HomeBinding().dependencies();
    SearchBinding().dependencies();
    CategoriesBinding().dependencies();
    NotificationsBinding().dependencies();
    ProfileBinding().dependencies();
  }
}
