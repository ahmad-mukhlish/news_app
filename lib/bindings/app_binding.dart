import 'package:get/get.dart';
import '../services/network/api_service.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.putAsync<ApiService>(() => ApiService().init(), permanent: true);
  }
}
