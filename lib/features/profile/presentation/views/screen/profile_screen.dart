import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:news_app/app/config/app_config.dart';
import 'package:news_app/app/helper/common_widgets/lottie_widget.dart';

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
      body: buildBody(context),
    );
  }

  Widget buildBody(BuildContext context) {
    return Semantics(
      label: "Coming soon",
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const LottieWidget(
              url: AppConfig.comingSoonAnimation,
              height: 220,
            ),
            const SizedBox(height: 16),
            Text(
              'Profile - Coming Soon',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}
