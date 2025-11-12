import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:news_app/app/app_config.dart';

import '../../../../../helper/common_widgets/empty_state_widget.dart';
import '../../../../../helper/common_widgets/error_widget.dart';
import '../../../../../helper/common_widgets/loading_widget.dart';
import '../../../domain/entities/news_article.dart';
import '../../get/headline_controller.dart';
import '../widgets/news_article_card.dart';

class HeadlineScreen extends GetView<HeadlineController> {
  const HeadlineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(AppConfig.appName, style: TextStyle(color: Theme.of(context).colorScheme.secondary),),
      ),
      body: buildBody(context),
    );
  }

  Widget buildBody(BuildContext context) {
    return PagingListener(
      controller: controller.pagingController,
      builder: (context, state, fetchNextPage) {
        return RefreshIndicator(
          onRefresh: () async => controller.pagingController.refresh(),
          child: PagedListView<int, NewsArticle>(
            state: state,
            fetchNextPage: fetchNextPage,
            padding: const EdgeInsets.all(16),
            builderDelegate: PagedChildBuilderDelegate<NewsArticle>(
              itemBuilder: (context, article, index) => NewsArticleCard(
                article: article,
                onTap: () => controller.openArticle(article.url),
              ),
              firstPageErrorIndicatorBuilder: (context) => ErrorStateWidget(
                title: 'Error loading news',
                message: state.error.toString(),
                onRetry: () => controller.pagingController.refresh(),
              ),
              noItemsFoundIndicatorBuilder: (context) => const EmptyStateWidget(
                message: 'No news available',
              ),
              firstPageProgressIndicatorBuilder: (context) => const LoadingWidget(),
              newPageProgressIndicatorBuilder: (context) => const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
          ),
        );
      },
    );
  }
}
