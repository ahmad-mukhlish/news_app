import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../helper/common_widgets/empty_state_widget.dart';
import '../../../../../helper/common_widgets/error_widget.dart';
import '../../../../../helper/common_widgets/loading_widget.dart';
import '../../get/home_controller.dart';
import '../widgets/news_article_card.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Top Headlines'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.refreshTopHeadlines,
          ),
        ],
      ),
      body: buildBody(context),
    );
  }

  Widget buildBody(BuildContext context) {
    return Obx(() {
      // Loading State
      if (controller.isLoading.value && controller.articles.isEmpty) {
        return const LoadingWidget();
      }

      // Error State
      if (controller.hasError.value && controller.articles.isEmpty) {
        return ErrorStateWidget(
          title: 'Error loading news',
          message: controller.errorMessage.value,
          onRetry: controller.refreshTopHeadlines,
        );
      }

      // Empty State
      if (controller.articles.isEmpty) {
        return const EmptyStateWidget(
          message: 'No news available',
        );
      }

      // Success State - News List
      return RefreshIndicator(
        onRefresh: controller.refreshTopHeadlines,
        child: ListView.builder(
          itemCount: controller.articles.length,
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) {
            final article = controller.articles[index];
            return NewsArticleCard(article: article);
          },
        ),
      );
    });
  }
}
