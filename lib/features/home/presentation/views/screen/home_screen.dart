import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../get/home_controller.dart';

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
      body: Obx(() {
        // Loading State
        if (controller.isLoading.value && controller.articles.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // Error State
        if (controller.hasError.value && controller.articles.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Error loading news',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    controller.errorMessage.value,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.refreshTopHeadlines,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        // Empty State
        if (controller.articles.isEmpty) {
          return const Center(
            child: Text('No news available'),
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
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image
                    if (article.urlToImage != null)
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: Image.network(
                          article.urlToImage!,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 200,
                              color: Colors.grey[300],
                              child: const Icon(Icons.broken_image, size: 64),
                            );
                          },
                        ),
                      ),

                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Source
                          Text(
                            article.sourceName,
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: Theme.of(context).primaryColor,
                                ),
                          ),
                          const SizedBox(height: 8),

                          // Title
                          Text(
                            article.title,
                            style: Theme.of(context).textTheme.titleMedium,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),

                          // Description
                          if (article.description != null)
                            Text(
                              article.description!,
                              style: Theme.of(context).textTheme.bodyMedium,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          const SizedBox(height: 8),

                          // Author & Date
                          Row(
                            children: [
                              if (article.author != null) ...[
                                const Icon(Icons.person, size: 14),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    article.author!,
                                    style:
                                        Theme.of(context).textTheme.labelSmall,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
