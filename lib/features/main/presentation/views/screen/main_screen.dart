import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../categories/presentation/views/screen/categories_screen.dart';
import '../../../../home/presentation/views/screen/home_screen.dart';
import '../../../../notifications/presentation/views/screen/notifications_screen.dart';
import '../../../../profile/presentation/views/screen/profile_screen.dart';
import '../../../../search/presentation/views/screen/search_screen.dart';
import '../../get/main_controller.dart';
import '../widgets/notification_badge_icon.dart';

class MainScreen extends GetView<MainController> {
  const MainScreen({super.key});

  static const List<Widget> pages = [
    HomeScreen(),
    SearchScreen(),
    CategoriesScreen(),
    NotificationsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        body: pages[controller.selectedIndex.value],
        bottomNavigationBar: Semantics(
          container: true,
          child: BottomNavigationBar(
            currentIndex: controller.selectedIndex.value,
            onTap: controller.changePage,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Theme.of(context).primaryColor,
            unselectedItemColor: Theme.of(context).colorScheme.tertiary,
            items: [
              BottomNavigationBarItem(
                icon: Semantics(
                  label: 'Home tab',
                  button: true,
                  child: const Icon(Icons.home_outlined),
                ),
                activeIcon: const Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Semantics(
                  label: 'Search tab',
                  button: true,
                  child: const Icon(Icons.search_outlined),
                ),
                activeIcon: const Icon(Icons.saved_search),
                label: 'Search',
              ),
              BottomNavigationBarItem(
                icon: Semantics(
                  label: 'Categories tab',
                  button: true,
                  child: const Icon(Icons.category_outlined),
                ),
                activeIcon: const Icon(Icons.category),
                label: 'Categories',
              ),
              BottomNavigationBarItem(
                icon: Semantics(
                  label: 'Notifications tab',
                  button: true,
                  child: NotificationBadgeIcon(count: controller.unreadCount),
                ),
                activeIcon: NotificationBadgeIcon(
                  count: controller.unreadCount,
                  isActive: true,
                ),
                label: 'Notif',
              ),
              BottomNavigationBarItem(
                icon: Semantics(
                  label: 'Profile tab',
                  button: true,
                  child: const Icon(Icons.person_outline),
                ),
                activeIcon: const Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
