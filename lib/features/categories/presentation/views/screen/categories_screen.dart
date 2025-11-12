import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../app/helper/common_widgets/paged_news_list.dart';
import '../../../domain/enums/news_category.dart';
import '../../get/categories_controller.dart';
import '../widgets/category_chip.dart';

class CategoriesScreen extends GetView<CategoriesController> {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          'Categories',
          style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.bold),
        ),
      ),
      body: buildBody(context),
    );
  }

  Widget buildBody(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        buildCategorySlider(),
        Expanded(
          child: PagedNewsList(
            pagingController: controller.pagingController,
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),
        ),
      ],
    );
  }

  Widget buildCategorySlider() {
    return SizedBox(
      height: 116,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: NewsCategoryEnum.values.length,
        itemBuilder: (context, index) {
          final category = NewsCategoryEnum.values[index];
          return Padding(
            padding: controller.getCategoryPadding(index),
            child: Obx(
              () => CategoryChip(
                category: category,
                isSelected: controller.selectedCategory.value == category,
                onTap: () => controller.selectCategory(category),
              ),
            ),
          );
        },
      ),
    );
  }
}
