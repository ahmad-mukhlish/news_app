import 'package:get/get.dart';

import '../../../../services/network/api_service.dart';
import '../../data/datasources/remote/headline_remote_data_source.dart';
import '../../data/repositories/headline_repository.dart';
import 'headline_controller.dart';

class HeadlineBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<HeadlineRemoteDataSource>()) {
      Get.lazyPut<HeadlineRemoteDataSource>(
        () => HeadlineRemoteDataSource(apiService: Get.find<ApiService>()),
      );
    }

    if (!Get.isRegistered<HeadlineRepository>()) {
      Get.lazyPut<HeadlineRepository>(
        () => HeadlineRepository(remoteDataSource: Get.find<HeadlineRemoteDataSource>()),
      );
    }

    if (!Get.isRegistered<HeadlineController>()) {
      Get.lazyPut<HeadlineController>(
        () => HeadlineController(repository: Get.find<HeadlineRepository>()),
      );
    }
  }
}
