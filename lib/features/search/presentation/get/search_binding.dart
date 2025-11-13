import 'package:get/get.dart';

import '../../../../app/services/network/api_service.dart';
import '../../data/datasources/remote/search_remote_data_source.dart';
import '../../data/repositories/search_repository.dart';
import 'search_controller.dart';

class SearchBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<SearchRemoteDataSource>()) {
      Get.lazyPut<SearchRemoteDataSource>(
        () => SearchRemoteDataSource(apiService: Get.find<ApiService>()),
      );
    }

    if (!Get.isRegistered<SearchRepository>()) {
      Get.lazyPut<SearchRepository>(
        () => SearchRepository(
            remoteDataSource: Get.find<SearchRemoteDataSource>()),
      );
    }

    if (!Get.isRegistered<SearchController>()) {
      Get.lazyPut<SearchController>(
        () => SearchController(repository: Get.find<SearchRepository>()),
      );
    }
  }
}
