import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/repositories/categories_repository.dart';
import '../../domain/enums/news_category.dart';

class CategoriesController extends GetxController {
  final CategoriesRepository repository;

  CategoriesController({required this.repository});

  static const double categoryListStartPadding = 24.0;
  static const double categoryListEndPadding = 8.0;

  final Rx<NewsCategoryEnum?> selectedCategory = Rx<NewsCategoryEnum?>(null);

  @override
  void onInit() {
    super.onInit();
    // Select first category by default
    if (NewsCategoryEnum.values.isNotEmpty) {
      selectedCategory.value = NewsCategoryEnum.values.first;
    }
  }

  void selectCategory(NewsCategoryEnum category) {
    selectedCategory.value = category;
    // TODO: Fetch news for this category
  }

  EdgeInsets getCategoryPadding(int index) {
    if (index == 0) return const EdgeInsets.only(left: categoryListStartPadding);
    if (index == NewsCategoryEnum.values.length - 1) {
      return const EdgeInsets.only(right: categoryListEndPadding);
    }
    return EdgeInsets.zero;
  }
}
