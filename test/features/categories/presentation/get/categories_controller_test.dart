import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:news_app/app/domain/entities/news_article.dart';
import 'package:news_app/features/categories/data/repositories/categories_repository.dart';
import 'package:news_app/features/categories/domain/enums/news_category_enum.dart';
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

  tearDown(() {
    controller.onClose();
  });

  group('CategoriesController', () {
    test('should initialize with repository', () {
      expect(controller.repository, equals(mockRepository));
    });

    test('should initialize with PagingController', () {
      expect(controller.pagingController, isNotNull);
    });

    test('should initialize with business category selected by default', () {
      expect(controller.selectedCategory.value, equals(NewsCategoryEnum.business));
    });

    test('should update selected category when selectCategory is called', () {
      controller.selectCategory(NewsCategoryEnum.technology);

      expect(controller.selectedCategory.value, equals(NewsCategoryEnum.technology));
    });

    test('getCategoryPadding should return left padding for first item', () {
      final padding = controller.getCategoryPadding(0);

      expect(padding, equals(const EdgeInsets.only(left: CategoriesController.categoryListStartPadding)));
    });

    test('getCategoryPadding should return right padding for last item', () {
      final lastIndex = NewsCategoryEnum.values.length - 1;
      final padding = controller.getCategoryPadding(lastIndex);

      expect(padding, equals(const EdgeInsets.only(right: CategoriesController.categoryListEndPadding)));
    });

    test('getCategoryPadding should return zero padding for middle items', () {
      final padding = controller.getCategoryPadding(1);

      expect(padding, equals(EdgeInsets.zero));
    });

    test('fetchNextPage should load articles via repository and update paging state', () async {
      final articles = [_createNewsArticle(suffix: 'business-1')];

      when(
        mockRepository.fetchCategoryNews(
          category: anyNamed('category'),
          page: anyNamed('page'),
          pageSize: anyNamed('pageSize'),
        ),
      ).thenAnswer((_) async => articles);

      controller.pagingController.fetchNextPage();
      await _drainMicrotasks();

      verify(
        mockRepository.fetchCategoryNews(
          category: NewsCategoryEnum.business,
          page: 1,
          pageSize: null,
        ),
      ).called(1);

      final pages = controller.pagingController.value.pages;
      expect(pages, isNotNull);
      expect(pages!.length, equals(1));
      expect(pages.first, hasLength(1));
      expect(pages.first.first.title, equals('Title business-1'));
      expect(controller.pagingController.value.isLoading, isFalse);
    });

    test('selectCategory should refresh paging state and fetch new category data', () async {
      final businessArticles = [_createNewsArticle(suffix: 'business')];
      final healthArticles = [_createNewsArticle(suffix: 'health')];

      when(
        mockRepository.fetchCategoryNews(
          category: NewsCategoryEnum.business,
          page: anyNamed('page'),
          pageSize: anyNamed('pageSize'),
        ),
      ).thenAnswer((_) async => businessArticles);

      controller.pagingController.fetchNextPage();
      await _drainMicrotasks();

      final initialPages = controller.pagingController.value.pages;
      expect(initialPages, isNotNull);

      when(
        mockRepository.fetchCategoryNews(
          category: NewsCategoryEnum.health,
          page: anyNamed('page'),
          pageSize: anyNamed('pageSize'),
        ),
      ).thenAnswer((_) async => healthArticles);

      controller.selectCategory(NewsCategoryEnum.health);

      expect(controller.selectedCategory.value, equals(NewsCategoryEnum.health));
      expect(controller.pagingController.value.pages, isNull);
      expect(controller.pagingController.value.hasNextPage, isTrue);

      controller.pagingController.fetchNextPage();
      await _drainMicrotasks();

      verify(
        mockRepository.fetchCategoryNews(
          category: NewsCategoryEnum.health,
          page: 1,
          pageSize: null,
        ),
      ).called(1);

      final refreshedPages = controller.pagingController.value.pages;
      expect(refreshedPages, isNotNull);
      expect(refreshedPages!.first.first.title, equals('Title health'));
    });
  });
}

NewsArticle _createNewsArticle({required String suffix}) => NewsArticle(
      author: 'Author $suffix',
      title: 'Title $suffix',
      description: 'Description $suffix',
      url: 'https://example.com/$suffix',
      urlToImage: 'https://example.com/image_$suffix.png',
      publishedAt: DateTime(2024, 1, 1),
      content: 'Content $suffix',
      sourceName: 'Source $suffix',
    );

Future<void> _drainMicrotasks() async {
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
}
