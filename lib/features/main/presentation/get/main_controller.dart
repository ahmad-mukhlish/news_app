import 'package:get/get.dart';

import '../../../notifications/data/repositories/notification_repository.dart';

class MainController extends GetxController {
  MainController({required NotificationRepository notificationRepository})
      : _notificationRepository = notificationRepository;

  static const int notificationsTabIndex = 3;
  final RxInt selectedIndex = 0.obs;
  final NotificationRepository _notificationRepository;

  void changePage(int index) {
    selectedIndex.value = index;
  }

  void goToNotificationsTab() {
    changePage(notificationsTabIndex);
  }

  int get unreadCount => _notificationRepository.notifications
      .where((notification) => !notification.isRead)
      .length;
}
