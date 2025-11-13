import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:news_app/app/data/dto/news_article_dto.dart';
import 'package:news_app/app/data/dto/news_response_dto.dart';
import 'package:news_app/app/data/dto/source_dto.dart';
import 'package:news_app/features/search/data/datasources/remote/search_remote_data_source.dart';
import 'package:news_app/features/search/data/repositories/search_repository.dart';
import 'package:news_app/features/search/domain/enums/search_in_enum.dart';
import 'package:news_app/features/search/domain/enums/sort_by_enum.dart';

import 'search_repository_test.mocks.dart';

@GenerateMocks([SearchRemoteDataSource])
void main() {
  late SearchRepository repository;
  late MockSearchRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockRemoteDataSource = MockSearchRemoteDataSource();
    repository = SearchRepository(remoteDataSource: mockRemoteDataSource);
  });

  tearDown(() {
    // Clean up after tests
  });

  group('SearchRepository', () {
    group('searchArticles', () {
      test('should return list of NewsArticle on success', () async {
        final mockResponse = NewsResponseDto(
          status: 'ok',
          totalResults: 2,
          articles: [
            NewsArticleDto(
              source: SourceDto(name: 'Source 1'),
              title: 'Flutter Article',
              author: 'Author 1',
              description: 'Description about Flutter',
              url: 'https://test1.com',
              urlToImage: 'https://test1.com/image.jpg',
              publishedAt: '2024-01-01T10:00:00Z',
              content: 'Content 1',
            ),
            NewsArticleDto(
              source: SourceDto(name: 'Source 2'),
              title: 'Dart Article',
              author: 'Author 2',
              description: 'Description about Dart',
              url: 'https://test2.com',
              urlToImage: 'https://test2.com/image.jpg',
              publishedAt: '2024-01-02T10:00:00Z',
              content: 'Content 2',
            ),
          ],
        );

        when(mockRemoteDataSource.searchArticles(
          query: anyNamed('query'),
          searchIn: anyNamed('searchIn'),
          sortBy: anyNamed('sortBy'),
          pageSize: anyNamed('pageSize'),
          page: anyNamed('page'),
        )).thenAnswer((_) async => mockResponse);

        final result = await repository.searchArticles(
          query: 'flutter',
          pageSize: 20,
          page: 1,
        );

        expect(result.length, 2);
        expect(result[0].title, 'Flutter Article');
        expect(result[0].author, 'Author 1');
        expect(result[1].title, 'Dart Article');
        expect(result[1].author, 'Author 2');
        verify(mockRemoteDataSource.searchArticles(
          query: 'flutter',
          searchIn: null,
          sortBy: null,
          pageSize: 20,
          page: 1,
        )).called(1);
      });

      test('should pass searchIn and sortBy parameters correctly', () async {
        final mockResponse = NewsResponseDto(
          status: 'ok',
          totalResults: 0,
          articles: [],
        );

        when(mockRemoteDataSource.searchArticles(
          query: anyNamed('query'),
          searchIn: anyNamed('searchIn'),
          sortBy: anyNamed('sortBy'),
          pageSize: anyNamed('pageSize'),
          page: anyNamed('page'),
        )).thenAnswer((_) async => mockResponse);

        await repository.searchArticles(
          query: 'flutter',
          searchIn: SearchInEnum.title,
          sortBy: SortByEnum.newest,
          pageSize: 10,
          page: 2,
        );

        verify(mockRemoteDataSource.searchArticles(
          query: 'flutter',
          searchIn: SearchInEnum.title,
          sortBy: SortByEnum.newest,
          pageSize: 10,
          page: 2,
        )).called(1);
      });

      test('should return empty list when response has no articles', () async {
        final mockResponse = NewsResponseDto(
          status: 'ok',
          totalResults: 0,
          articles: [],
        );

        when(mockRemoteDataSource.searchArticles(
          query: anyNamed('query'),
          searchIn: anyNamed('searchIn'),
          sortBy: anyNamed('sortBy'),
          pageSize: anyNamed('pageSize'),
          page: anyNamed('page'),
        )).thenAnswer((_) async => mockResponse);

        final result = await repository.searchArticles(query: 'nonexistent');

        expect(result, isEmpty);
      });

      test('should throw exception when remote data source fails', () async {
        when(mockRemoteDataSource.searchArticles(
          query: anyNamed('query'),
          searchIn: anyNamed('searchIn'),
          sortBy: anyNamed('sortBy'),
          pageSize: anyNamed('pageSize'),
          page: anyNamed('page'),
        )).thenThrow(Exception('API Error'));

        expect(
          () => repository.searchArticles(query: 'flutter'),
          throwsException,
        );
      });

      test('should handle all searchIn enum values', () async {
        final mockResponse = NewsResponseDto(
          status: 'ok',
          totalResults: 0,
          articles: [],
        );

        when(mockRemoteDataSource.searchArticles(
          query: anyNamed('query'),
          searchIn: anyNamed('searchIn'),
          sortBy: anyNamed('sortBy'),
          pageSize: anyNamed('pageSize'),
          page: anyNamed('page'),
        )).thenAnswer((_) async => mockResponse);

        // Test with description
        await repository.searchArticles(
          query: 'test',
          searchIn: SearchInEnum.description,
        );

        verify(mockRemoteDataSource.searchArticles(
          query: 'test',
          searchIn: SearchInEnum.description,
          sortBy: null,
          pageSize: null,
          page: null,
        )).called(1);
      });

      test('should handle all sortBy enum values', () async {
        final mockResponse = NewsResponseDto(
          status: 'ok',
          totalResults: 0,
          articles: [],
        );

        when(mockRemoteDataSource.searchArticles(
          query: anyNamed('query'),
          searchIn: anyNamed('searchIn'),
          sortBy: anyNamed('sortBy'),
          pageSize: anyNamed('pageSize'),
          page: anyNamed('page'),
        )).thenAnswer((_) async => mockResponse);

        // Test with popularity
        await repository.searchArticles(
          query: 'test',
          sortBy: SortByEnum.popularity,
        );

        verify(mockRemoteDataSource.searchArticles(
          query: 'test',
          searchIn: null,
          sortBy: SortByEnum.popularity,
          pageSize: null,
          page: null,
        )).called(1);
      });
    });
  });
}
