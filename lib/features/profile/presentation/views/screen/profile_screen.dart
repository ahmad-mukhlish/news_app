import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../get/profile_controller.dart';

class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          'Profile',
          style: TextStyle(color: Theme.of(context).colorScheme.secondary),
        ),
      ),
      body: const Center(
        child: Text('Profile - Coming Soon'),
      ),
    );
  }
}
