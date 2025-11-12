import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/repositories/home_repository.dart';
import '../../domain/entities/news_article.dart';

class HomeController extends GetxController {
  final HomeRepository repository;

  HomeController({required this.repository});

  late final PagingController<int, NewsArticle> pagingController =
      PagingController(
        getNextPageKey: (state) {
          if (state.lastPageIsEmpty) return null;
          return state.nextIntPageKey;
        },
        fetchPage: (pageKey) async {
          final newArticles = await repository.fetchTopHeadlines(
            page: pageKey,
          );
          return newArticles;
        },
      );

  Future<void> openArticle(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
  }

  @override
  void onClose() {
    pagingController.dispose();
    super.onClose();
  }
}
