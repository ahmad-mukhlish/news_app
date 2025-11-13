import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../categories/presentation/views/screen/categories_screen.dart';
import '../../../../home/presentation/views/screen/home_screen.dart';
import '../../../../notifications/presentation/views/screen/notifications_screen.dart';
import '../../../../profile/presentation/views/screen/profile_screen.dart';
import '../../../../search/presentation/views/screen/search_screen.dart';
import '../../get/main_controller.dart';

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
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: controller.selectedIndex.value,
          onTap: controller.changePage,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Theme.of(context).colorScheme.tertiary,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search_outlined),
              activeIcon: Icon(Icons.saved_search),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.category_outlined),
              activeIcon: Icon(Icons.category),
              label: 'Categories',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications_outlined),
              activeIcon: Icon(Icons.notifications),
              label: 'Notif',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
