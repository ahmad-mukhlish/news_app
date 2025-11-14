import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../config/app_config.dart';
import '../../domain/entities/news_article.dart';
import '../common_methods/url_methods.dart';
import 'empty_state_widget.dart';
import 'error_widget.dart';
import 'loading_widget.dart';
import 'news_article_card.dart';

class PagedNewsList extends StatelessWidget {
  final PagingController<int, NewsArticle> pagingController;
  final EdgeInsetsGeometry? padding;

  const PagedNewsList({
    super.key,
    required this.pagingController,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: "Pagination list",
      child: PagingListener(
        controller: pagingController,
        builder: (context, state, fetchNextPage) {
          return RefreshIndicator(
            onRefresh: () async => pagingController.refresh(),
            child: PagedListView<int, NewsArticle>(
              state: state,
              fetchNextPage: fetchNextPage,
              padding: padding ?? const EdgeInsets.all(16),
              builderDelegate: PagedChildBuilderDelegate<NewsArticle>(
                itemBuilder: (context, article, index) => NewsArticleCard(
                  article: article,
                  onTap: () => openUrl(article.url),
                ),
                firstPageErrorIndicatorBuilder: (context) => ErrorStateWidget(
                  title: 'Error loading news',
                  message: state.error.toString(),
                  lottieUrl: AppConfig.errorAnimation,
                  onRetry: () => pagingController.refresh(),
                ),
                noItemsFoundIndicatorBuilder: (context) => const EmptyStateWidget(
                  message: 'No news available',
                  lottieUrl: AppConfig.emptyNewsAnimation,
                ),
                firstPageProgressIndicatorBuilder: (context) => const LoadingWidget(),
                newPageProgressIndicatorBuilder: (context) => const LoadingWidget(),
              ),
            ),
          );
        },
      ),
    );
  }
}
