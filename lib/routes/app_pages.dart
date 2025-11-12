import 'package:get/get_navigation/src/routes/get_route.dart';

import '../features/home/presentation/get/home_binding.dart';
import '../features/home/presentation/views/screen/home_screen.dart';
import 'app_routes.dart';

class AppPages {
  static const initial = AppRoutes.home;

  static final routes = [
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeScreen(),
      binding: HomeBinding(),
    ),
  ];
}