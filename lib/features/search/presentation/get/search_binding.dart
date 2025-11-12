import 'package:get/get.dart';

import 'search_controller.dart';

class SearchBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<SearchController>()) {
      Get.lazyPut<SearchController>(
        () => SearchController(),
      );
    }
  }
}
