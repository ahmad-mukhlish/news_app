import 'package:get/get.dart';

import '../../../../app/services/network/api_service.dart';
import '../../data/datasources/remote/categories_remote_data_source.dart';
import '../../data/repositories/categories_repository.dart';
import 'categories_controller.dart';

class CategoriesBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<CategoriesRemoteDataSource>()) {
      Get.lazyPut<CategoriesRemoteDataSource>(
        () => CategoriesRemoteDataSource(apiService: Get.find<ApiService>()),
      );
    }

    if (!Get.isRegistered<CategoriesRepository>()) {
      Get.lazyPut<CategoriesRepository>(
        () => CategoriesRepository(
          remoteDataSource: Get.find<CategoriesRemoteDataSource>(),
        ),
      );
    }

    if (!Get.isRegistered<CategoriesController>()) {
      Get.lazyPut<CategoriesController>(
        () =>
            CategoriesController(repository: Get.find<CategoriesRepository>()),
      );
    }
  }
}
