import 'dart:async';
import 'dart:developer' as developer;

import 'package:get/get.dart';

import '../../../../app/services/analytics_service.dart';
import '../../../notifications/data/repositories/notification_repository.dart';

class MainController extends GetxController {
  MainController({required NotificationRepository notificationRepository})
    : _notificationRepository = notificationRepository;

  static const int notificationsTabIndex = 3;
  static const List<String> _tabNames = [
    'home',
    'search',
    'categories',
    'notifications',
    'profile',
  ];

  final RxInt selectedIndex = 0.obs;
  final NotificationRepository _notificationRepository;

  @override
  void onInit() {
    super.onInit();
    _preloadNotifications();
  }

  void changePage(int index) {
    selectedIndex.value = index;
    unawaited(_logTabSelected(index));
  }

  void goToNotificationsTab() {
    changePage(notificationsTabIndex);
  }

  int get unreadCount => _notificationRepository.notifications
      .where((notification) => !notification.isRead)
      .length;

  Future<void> _preloadNotifications() async {
    try {
      await _notificationRepository.getAllNotifications();
    } catch (error, stackTrace) {
      developer.log(
        'Failed to preload notifications',
        error: error,
        stackTrace: stackTrace,
        name: runtimeType.toString(),
      );
    }
  }

  Future<void> _logTabSelected(int index) async {
    final isKnownTab = index >= 0 && index < _tabNames.length;
    if (!isKnownTab) return;

    await AnalyticsService.logEventIfReady(
      name: 'news_tab_selected',
      parameters: {'tab_index': index, 'tab_name': _tabNames[index]},
    );
  }
}
