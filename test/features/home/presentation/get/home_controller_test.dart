import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:news_app/app/domain/entities/news_article.dart';
import 'package:news_app/features/home/data/repositories/home_repository.dart';
import 'package:news_app/features/home/presentation/get/home_controller.dart';

import 'home_controller_test.mocks.dart';

@GenerateMocks([HomeRepository])
void main() {
  late HomeController controller;
  late MockHomeRepository mockRepository;

  setUp(() {
    mockRepository = MockHomeRepository();
    controller = HomeController(repository: mockRepository);
  });

  tearDown(() {
    controller.onClose();
  });

  group('HomeController', () {
    test('should initialize with repository', () {
      expect(controller.repository, equals(mockRepository));
    });

    test('should initialize with PagingController', () {
      expect(controller.pagingController, isNotNull);
    });

    test('fetchNextPage should load articles into paging state', () async {
      final articles = [createArticle(1), createArticle(2)];

      when(
        mockRepository.fetchTopHeadlines(page: anyNamed('page')),
      ).thenAnswer((_) async => articles);

      controller.pagingController.fetchNextPage();
      await Future<void>.delayed(Duration.zero);

      verify(mockRepository.fetchTopHeadlines(page: 1)).called(1);
      final pagingState = controller.pagingController.value;
      expect(pagingState.pages, equals([articles]));
      expect(pagingState.keys, equals([1]));
      expect(pagingState.isLoading, isFalse);
      expect(pagingState.hasNextPage, isTrue);
    });

    test('fetchNextPage should stop when last page is empty', () {
      controller.pagingController.value = controller.pagingController.value
          .copyWith(
            pages: <List<NewsArticle>>[<NewsArticle>[]],
            keys: <int>[1],
          );

      controller.pagingController.fetchNextPage();

      final pagingState = controller.pagingController.value;
      expect(pagingState.hasNextPage, isFalse);
      verifyNever(mockRepository.fetchTopHeadlines(page: anyNamed('page')));
    });
  });
}

NewsArticle createArticle(int id) {
  final timestamp = DateTime(2024, 1, id);
  return NewsArticle(
    author: 'Author $id',
    title: 'Title $id',
    description: 'Description $id',
    url: 'https://example.com/$id',
    urlToImage: 'https://example.com/image_$id.png',
    publishedAt: timestamp,
    content: 'Content $id',
    sourceName: 'Source $id',
  );
}
