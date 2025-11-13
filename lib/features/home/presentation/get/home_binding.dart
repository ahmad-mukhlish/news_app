import 'package:get/get.dart';

import '../../../../app/services/network/api_service.dart';
import '../../data/datasources/remote/home_remote_data_source.dart';
import '../../data/repositories/home_repository.dart';
import 'home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<HomeRemoteDataSource>()) {
      Get.lazyPut<HomeRemoteDataSource>(
        () => HomeRemoteDataSource(apiService: Get.find<ApiService>()),
      );
    }

    if (!Get.isRegistered<HomeRepository>()) {
      Get.lazyPut<HomeRepository>(
        () => HomeRepository(remoteDataSource: Get.find<HomeRemoteDataSource>()),
      );
    }

    if (!Get.isRegistered<HomeController>()) {
      Get.lazyPut<HomeController>(
        () => HomeController(repository: Get.find<HomeRepository>()),
      );
    }
  }
}
