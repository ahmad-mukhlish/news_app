import 'package:get/get_navigation/src/routes/get_route.dart';

import '../../features/headline/presentation/get/headline_binding.dart';
import '../../features/headline/presentation/views/screen/headline_screen.dart';
import 'app_routes.dart';

class AppPages {
  static const initial = AppRoutes.headline;

  static final routes = [
    GetPage(
      name: AppRoutes.headline,
      page: () => const HeadlineScreen(),
      binding: HeadlineBinding(),
    ),
  ];
}