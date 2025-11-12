import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:news_app/features/categories/data/repositories/categories_repository.dart';
import 'package:news_app/features/categories/domain/enums/news_category.dart';
import 'package:news_app/features/categories/presentation/get/categories_controller.dart';

import 'categories_controller_test.mocks.dart';

@GenerateMocks([CategoriesRepository])
void main() {
  late CategoriesController controller;
  late MockCategoriesRepository mockRepository;

  setUp(() {
    mockRepository = MockCategoriesRepository();
    controller = CategoriesController(repository: mockRepository);
  });

  group('CategoriesController', () {
    test('should initialize with repository', () {
      expect(controller.repository, equals(mockRepository));

      controller.onClose();
    });

    test('should initialize with PagingController', () {
      expect(controller.pagingController, isNotNull);

      controller.onClose();
    });

    test('should initialize with business category selected by default', () {
      expect(controller.selectedCategory.value, equals(NewsCategoryEnum.business));

      controller.onClose();
    });

    test('should update selected category when selectCategory is called', () {
      controller.selectCategory(NewsCategoryEnum.technology);

      expect(controller.selectedCategory.value, equals(NewsCategoryEnum.technology));

      controller.onClose();
    });

    test('getCategoryPadding should return left padding for first item', () {
      final padding = controller.getCategoryPadding(0);

      expect(padding, equals(const EdgeInsets.only(left: CategoriesController.categoryListStartPadding)));

      controller.onClose();
    });

    test('getCategoryPadding should return right padding for last item', () {
      final lastIndex = NewsCategoryEnum.values.length - 1;
      final padding = controller.getCategoryPadding(lastIndex);

      expect(padding, equals(const EdgeInsets.only(right: CategoriesController.categoryListEndPadding)));

      controller.onClose();
    });

    test('getCategoryPadding should return zero padding for middle items', () {
      final padding = controller.getCategoryPadding(1);

      expect(padding, equals(EdgeInsets.zero));

      controller.onClose();
    });

    test('should properly dispose pagingController on close', () {
      expect(() => controller.onClose(), returnsNormally);
    });
  });
}
