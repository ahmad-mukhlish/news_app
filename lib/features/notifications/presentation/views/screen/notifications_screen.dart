import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../get/notifications_controller.dart';

class NotificationsScreen extends GetView<NotificationsController> {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          'Notifications',
          style: TextStyle(color: Theme.of(context).colorScheme.secondary),
        ),
      ),
      body: const Center(
        child: Text('Notifications - Coming Soon'),
      ),
    );
  }
}
