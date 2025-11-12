import 'package:get/get.dart';

import 'categories_controller.dart';

class CategoriesBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<CategoriesController>()) {
      Get.lazyPut<CategoriesController>(
        () => CategoriesController(),
      );
    }
  }
}
