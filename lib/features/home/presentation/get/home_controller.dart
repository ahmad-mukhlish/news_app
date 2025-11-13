import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../../../app/domain/entities/news_article.dart';
import '../../data/repositories/home_repository.dart';

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

  @override
  void onClose() {
    pagingController.dispose();
    super.onClose();
  }
}
