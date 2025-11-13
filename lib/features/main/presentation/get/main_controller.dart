import 'package:get/get.dart';

class MainController extends GetxController {
  static const int notificationsTabIndex = 3;
  final RxInt selectedIndex = 0.obs;

  void changePage(int index) {
    selectedIndex.value = index;
  }

  void goToNotificationsTab() {
    changePage(notificationsTabIndex);
  }
}
