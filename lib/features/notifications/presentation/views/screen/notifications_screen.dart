import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../app/helper/common_widgets/empty_state_widget.dart';
import '../../../../../app/helper/common_widgets/loading_widget.dart';
import '../../get/notifications_controller.dart';
import '../widgets/notification_list_item.dart';

class NotificationsScreen extends GetView<NotificationsController> {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          'Notifications',
          style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.bold),
        ),
        actions: [buildMarkAllAsRead(context)],
      ),
      body: buildBody(),
    );
  }

  Widget buildMarkAllAsRead(BuildContext context) {
    return Obx(() {
      final hasUnread = controller.notifications.any((n) => !n.isRead);
      if (!hasUnread) return const SizedBox.shrink();
      return Semantics(
        label: "Mark read",
        button: true,
        excludeSemantics: true,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: TextButton(
            style: TextButton.styleFrom(
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            onPressed: controller.markAllAsRead,
            child: Text(
              'Mark all read',
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget buildBody() {
    return Obx(() {
      if (controller.isLoading.value) {
        return LoadingWidget();
      }

      if (controller.notifications.isEmpty) {
        return const EmptyStateWidget(
          icon: Icons.notifications_none,
          message: 'No notifications yet',
        );
      }

      return RefreshIndicator(
        onRefresh: controller.loadNotifications,
        child: ListView.separated(
          itemCount: controller.notifications.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final notification = controller.notifications[index];
            return NotificationListItem(
              notification: notification,
              onTap: () => controller.navigateToDetail(notification),
            );
          },
        ),
      );
    });
  }
}
