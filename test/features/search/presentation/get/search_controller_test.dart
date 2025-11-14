import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:news_app/app/domain/entities/news_article.dart';
import 'package:news_app/features/search/data/repositories/search_repository.dart';
import 'package:news_app/features/search/domain/entities/search_suggestion_item.dart';
import 'package:news_app/features/search/domain/enums/search_in_enum.dart';
import 'package:news_app/features/search/domain/enums/sort_by_enum.dart';
import 'package:news_app/features/search/presentation/get/search_controller.dart'
    as search;

import 'search_controller_test.mocks.dart';

@GenerateMocks([SearchRepository])
void main() {
  late search.SearchController controller;
  late MockSearchRepository mockRepository;

  setUp(() {
    mockRepository = MockSearchRepository();
    controller = search.SearchController(repository: mockRepository);
  });

  tearDown(() {
    controller.onClose();
  });

  group('SearchController', () {
    test('should initialize with repository', () {
      expect(controller.repository, equals(mockRepository));
    });

    test('should initialize with PagingController', () {
      expect(controller.pagingController, isNotNull);
    });

    test('should initialize with TextEditingController', () {
      expect(controller.searchTextController, isNotNull);
    });

    test('should initialize hasSearched as false', () {
      expect(controller.hasSearched.value, false);
    });

    test('should initialize currentQuery as empty', () {
      expect(controller.currentQuery.value, '');
    });

    test('should initialize hasText as false', () {
      expect(controller.hasText.value, false);
    });

    test('should update hasText when text input changes', () {
      controller.onInit();

      expect(controller.hasText.value, isFalse);

      controller.searchTextController.text = 'news';
      expect(controller.hasText.value, isTrue);

      controller.searchTextController.clear();
      expect(controller.hasText.value, isFalse);
    });

    group('generateSuggestions', () {
      test('should return empty list when query is empty', () {
        final suggestions = controller.generateSuggestions('');
        expect(suggestions, isEmpty);
      });

      test('should return empty list when query has less than 3 characters',
          () {
        final suggestions = controller.generateSuggestions('ab');
        expect(suggestions, isEmpty);
      });

      test('should return 6 suggestions when query has 3 or more characters',
          () {
        final suggestions = controller.generateSuggestions('flutter');
        expect(suggestions.length, 6);
      });

      test('should return correct searchIn suggestions', () {
        final suggestions = controller.generateSuggestions('flutter');

        expect(suggestions[0].searchIn, SearchInEnum.title);
        expect(suggestions[0].sortBy, SortByEnum.none);

        expect(suggestions[1].searchIn, SearchInEnum.description);
        expect(suggestions[1].sortBy, SortByEnum.none);

        expect(suggestions[2].searchIn, SearchInEnum.titleAndDescription);
        expect(suggestions[2].sortBy, SortByEnum.none);
      });

      test('should return correct sortBy suggestions', () {
        final suggestions = controller.generateSuggestions('flutter');

        expect(suggestions[3].searchIn, SearchInEnum.none);
        expect(suggestions[3].sortBy, SortByEnum.newest);

        expect(suggestions[4].searchIn, SearchInEnum.none);
        expect(suggestions[4].sortBy, SortByEnum.popularity);

        expect(suggestions[5].searchIn, SearchInEnum.none);
        expect(suggestions[5].sortBy, SortByEnum.relevancy);
      });

      test('should maintain query text in all suggestions', () {
        final suggestions = controller.generateSuggestions('flutter');

        for (final suggestion in suggestions) {
          expect(suggestion.query, 'flutter');
        }
      });
    });

    group('executeSearch', () {
      test('should update currentQuery when executing search', () {
        final suggestion = SearchSuggestionItem(
          query: 'flutter',
          searchIn: SearchInEnum.title,
          sortBy: SortByEnum.none,
        );

        controller.executeSearch(suggestion);

        expect(controller.currentQuery.value, 'flutter');
      });

      test('should update searchTextController when executing search', () {
        final suggestion = SearchSuggestionItem(
          query: 'flutter',
          searchIn: SearchInEnum.title,
          sortBy: SortByEnum.none,
        );

        controller.executeSearch(suggestion);

        expect(controller.searchTextController.text, 'flutter');
      });

      test('should update currentSearchIn when searchIn is not none', () {
        final suggestion = SearchSuggestionItem(
          query: 'flutter',
          searchIn: SearchInEnum.title,
          sortBy: SortByEnum.none,
        );

        controller.executeSearch(suggestion);

        expect(controller.currentSearchIn, SearchInEnum.title);
      });

      test('should set currentSearchIn to null when searchIn is none', () {
        final suggestion = SearchSuggestionItem(
          query: 'flutter',
          searchIn: SearchInEnum.none,
          sortBy: SortByEnum.newest,
        );

        controller.executeSearch(suggestion);

        expect(controller.currentSearchIn, isNull);
      });

      test('should update currentSortBy when sortBy is not none', () {
        final suggestion = SearchSuggestionItem(
          query: 'flutter',
          searchIn: SearchInEnum.none,
          sortBy: SortByEnum.newest,
        );

        controller.executeSearch(suggestion);

        expect(controller.currentSortBy, SortByEnum.newest);
      });

      test('should set currentSortBy to null when sortBy is none', () {
        final suggestion = SearchSuggestionItem(
          query: 'flutter',
          searchIn: SearchInEnum.title,
          sortBy: SortByEnum.none,
        );

        controller.executeSearch(suggestion);

        expect(controller.currentSortBy, isNull);
      });

      test('should set hasSearched to true', () {
        final suggestion = SearchSuggestionItem(
          query: 'flutter',
          searchIn: SearchInEnum.none,
          sortBy: SortByEnum.none,
        );

        controller.executeSearch(suggestion);

        expect(controller.hasSearched.value, true);
      });
    });

    group('submitQuery', () {
      test('should not execute search when query has less than 3 characters',
          () {
        controller.submitQuery('ab');

        expect(controller.hasSearched.value, false);
        expect(controller.currentQuery.value, '');
      });

      test('should execute search when query has 3 or more characters', () {
        controller.submitQuery('flutter');

        expect(controller.hasSearched.value, true);
        expect(controller.currentQuery.value, 'flutter');
      });

      test('should set searchIn to none when submitting query', () {
        controller.submitQuery('flutter');

        expect(controller.currentSearchIn, isNull);
      });

      test('should set sortBy to none when submitting query', () {
        controller.submitQuery('flutter');

        expect(controller.currentSortBy, isNull);
      });
    });

    group('clearSearch', () {
      test('should clear searchTextController', () {
        controller.searchTextController.text = 'flutter';

        controller.clearSearch();

        expect(controller.searchTextController.text, isEmpty);
      });

      test('should NOT reset hasSearched (keeps results visible)', () {
        final suggestion = SearchSuggestionItem(
          query: 'flutter',
          searchIn: SearchInEnum.none,
          sortBy: SortByEnum.none,
        );
        controller.executeSearch(suggestion);

        controller.clearSearch();

        expect(controller.hasSearched.value, true);
      });

      test('should NOT reset currentQuery (keeps results visible)', () {
        final suggestion = SearchSuggestionItem(
          query: 'flutter',
          searchIn: SearchInEnum.none,
          sortBy: SortByEnum.none,
        );
        controller.executeSearch(suggestion);

        controller.clearSearch();

        expect(controller.currentQuery.value, 'flutter');
      });
    });

    group('pagingController', () {
      test('should not call repository when query is empty', () async {
        controller.pagingController.fetchNextPage();

        await pumpEventQueue();

        verifyNever(
          mockRepository.searchArticles(
            query: anyNamed('query'),
            searchIn: anyNamed('searchIn'),
            sortBy: anyNamed('sortBy'),
            pageSize: anyNamed('pageSize'),
            page: anyNamed('page'),
          ),
        );
      });

      test('should fetch first page using active filters', () async {
        final sampleArticle = NewsArticle(
          author: 'Author',
          title: 'Title',
          description: 'Desc',
          url: 'https://example.com',
          urlToImage: 'https://example.com/image.png',
          publishedAt: DateTime(2024, 1, 1),
          content: 'Content',
          sourceName: 'Source',
        );

        when(
          mockRepository.searchArticles(
            query: anyNamed('query'),
            searchIn: anyNamed('searchIn'),
            sortBy: anyNamed('sortBy'),
            pageSize: anyNamed('pageSize'),
            page: anyNamed('page'),
          ),
        ).thenAnswer((_) async => [sampleArticle]);

        final suggestion = SearchSuggestionItem(
          query: 'flutter',
          searchIn: SearchInEnum.description,
          sortBy: SortByEnum.relevancy,
        );

        controller.executeSearch(suggestion);
        controller.pagingController.fetchNextPage();

        await untilCalled(
          mockRepository.searchArticles(
            query: anyNamed('query'),
            searchIn: anyNamed('searchIn'),
            sortBy: anyNamed('sortBy'),
            pageSize: anyNamed('pageSize'),
            page: anyNamed('page'),
          ),
        );

        verify(
          mockRepository.searchArticles(
            query: 'flutter',
            searchIn: SearchInEnum.description,
            sortBy: SortByEnum.relevancy,
            pageSize: null,
            page: 1,
          ),
        ).called(1);

        final pages = controller.pagingController.value.pages;
        expect(pages, isNotNull);
        expect(pages!.length, 1);
        expect(pages.first.single, same(sampleArticle));
      });
    });



    group('onClose', () {
      test('should have working searchTextController before disposal', () {
        final testController = search.SearchController(repository: mockRepository);

        testController.searchTextController.text = 'test';

        expect(testController.searchTextController.text, 'test');

        testController.onClose();
      });

      test('should have working pagingController before disposal', () {
        final testController = search.SearchController(repository: mockRepository);

        expect(testController.pagingController, isNotNull);

        testController.onClose();
      });
    });
  });
}
