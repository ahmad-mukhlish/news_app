import 'package:get/get.dart';

import '../../../../services/network/api_service.dart';
import '../../data/datasources/remote/home_remote_data_source.dart';
import '../../data/repositories/home_repository.dart';
import 'home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Data Source
    if (!Get.isRegistered<HomeRemoteDataSource>()) {
      Get.lazyPut<HomeRemoteDataSource>(
        () => HomeRemoteDataSource(apiService: Get.find<ApiService>()),
      );
    }

    // Repository
    if (!Get.isRegistered<HomeRepository>()) {
      Get.lazyPut<HomeRepository>(
        () => HomeRepository(remoteDataSource: Get.find<HomeRemoteDataSource>()),
      );
    }

    // Controller
    if (!Get.isRegistered<HomeController>()) {
      Get.lazyPut<HomeController>(
        () => HomeController(repository: Get.find<HomeRepository>()),
      );
    }
  }
}
