import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../../../app/domain/entities/news_article.dart';
import '../../data/repositories/categories_repository.dart';
import '../../domain/enums/news_category_enum.dart';

class CategoriesController extends GetxController {
  final CategoriesRepository repository;

  CategoriesController({required this.repository});

  static const double categoryListStartPadding = 24.0;
  static const double categoryListEndPadding = 8.0;

  final selectedCategory = NewsCategoryEnum.business.obs;

  late final PagingController<int, NewsArticle> pagingController = PagingController(
    getNextPageKey: (state) {
      if (state.lastPageIsEmpty) return null;
      return state.nextIntPageKey;
    },
    fetchPage: _fetchPage,
  );


  Future<List<NewsArticle>> _fetchPage(int pageKey) async {
    final category = selectedCategory.value;
    final newArticles = await repository.fetchCategoryNews(
      category: category,
      page: pageKey,
    );
    return newArticles;
  }

  void selectCategory(NewsCategoryEnum category) {
    selectedCategory.value = category;
    pagingController.refresh();
  }

  EdgeInsets getCategoryPadding(int index) {
    if (index == 0) return const EdgeInsets.only(left: categoryListStartPadding);
    if (index == NewsCategoryEnum.values.length - 1) {
      return const EdgeInsets.only(right: categoryListEndPadding);
    }
    return EdgeInsets.zero;
  }

  @override
  void onClose() {
    pagingController.dispose();
    super.onClose();
  }
}
