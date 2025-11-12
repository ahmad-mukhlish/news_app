import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:news_app/app/config/app_config.dart';

import '../../../../../app/helper/common_widgets/paged_news_list.dart';
import '../../get/headline_controller.dart';

class HeadlineScreen extends GetView<HeadlineController> {
  const HeadlineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(AppConfig.appName, style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.bold),),
      ),
      body: PagedNewsList(pagingController: controller.pagingController),
    );
  }
}
