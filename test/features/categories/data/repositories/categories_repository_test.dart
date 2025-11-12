import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:news_app/app/data/dto/news_article_dto.dart';
import 'package:news_app/app/data/dto/news_response_dto.dart';
import 'package:news_app/app/data/dto/source_dto.dart';
import 'package:news_app/features/categories/data/datasources/remote/categories_remote_data_source.dart';
import 'package:news_app/features/categories/data/repositories/categories_repository.dart';
import 'package:news_app/features/categories/domain/enums/news_category.dart';

import 'categories_repository_test.mocks.dart';

@GenerateMocks([CategoriesRemoteDataSource])
void main() {
  late CategoriesRepository repository;
  late MockCategoriesRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockRemoteDataSource = MockCategoriesRemoteDataSource();
    repository = CategoriesRepository(remoteDataSource: mockRemoteDataSource);
  });

  group('CategoriesRepository', () {
    group('fetchCategoryNews', () {
      test('should return list of NewsArticle on success', () async {
        final mockResponse = NewsResponseDto(
          status: 'ok',
          totalResults: 2,
          articles: [
            NewsArticleDto(
              source: SourceDto(name: 'Tech Source'),
              title: 'Tech Article 1',
              author: 'Tech Author',
              description: 'Tech Description 1',
              url: 'https://tech1.com',
              urlToImage: 'https://tech1.com/image.jpg',
              publishedAt: '2024-01-01T10:00:00Z',
              content: 'Tech Content 1',
            ),
            NewsArticleDto(
              source: SourceDto(name: 'Tech Source 2'),
              title: 'Tech Article 2',
              author: 'Tech Author 2',
              description: 'Tech Description 2',
              url: 'https://tech2.com',
              urlToImage: 'https://tech2.com/image.jpg',
              publishedAt: '2024-01-02T10:00:00Z',
              content: 'Tech Content 2',
            ),
          ],
        );

        when(mockRemoteDataSource.fetchCategoryNews(
          category: anyNamed('category'),
          pageSize: anyNamed('pageSize'),
          page: anyNamed('page'),
        )).thenAnswer((_) async => mockResponse);

        final result = await repository.fetchCategoryNews(
          category: NewsCategoryEnum.technology,
          pageSize: 20,
          page: 1,
        );

        expect(result.length, 2);
        expect(result[0].title, 'Tech Article 1');
        expect(result[0].author, 'Tech Author');
        expect(result[1].title, 'Tech Article 2');
        expect(result[1].author, 'Tech Author 2');
        verify(mockRemoteDataSource.fetchCategoryNews(
          category: NewsCategoryEnum.technology,
          pageSize: 20,
          page: 1,
        )).called(1);
      });

      test('should return empty list when response has no articles', () async {
        final mockResponse = NewsResponseDto(
          status: 'ok',
          totalResults: 0,
          articles: [],
        );

        when(mockRemoteDataSource.fetchCategoryNews(
          category: anyNamed('category'),
          pageSize: anyNamed('pageSize'),
          page: anyNamed('page'),
        )).thenAnswer((_) async => mockResponse);

        final result = await repository.fetchCategoryNews(
          category: NewsCategoryEnum.business,
        );

        expect(result, isEmpty);
      });

      test('should throw exception when remote data source fails', () async {
        when(mockRemoteDataSource.fetchCategoryNews(
          category: anyNamed('category'),
          pageSize: anyNamed('pageSize'),
          page: anyNamed('page'),
        )).thenThrow(Exception('API Error'));

        expect(
          () => repository.fetchCategoryNews(
            category: NewsCategoryEnum.sports,
          ),
          throwsException,
        );
      });

      test('should pass correct parameters to remote data source', () async {
        final mockResponse = NewsResponseDto(
          status: 'ok',
          totalResults: 0,
          articles: [],
        );

        when(mockRemoteDataSource.fetchCategoryNews(
          category: anyNamed('category'),
          pageSize: anyNamed('pageSize'),
          page: anyNamed('page'),
        )).thenAnswer((_) async => mockResponse);

        await repository.fetchCategoryNews(
          category: NewsCategoryEnum.health,
          pageSize: 10,
          page: 2,
        );

        verify(mockRemoteDataSource.fetchCategoryNews(
          category: NewsCategoryEnum.health,
          pageSize: 10,
          page: 2,
        )).called(1);
      });

      test('should work with different category enums', () async {
        final mockResponse = NewsResponseDto(
          status: 'ok',
          totalResults: 1,
          articles: [
            NewsArticleDto(
              source: SourceDto(name: 'Science Source'),
              title: 'Science Article',
              author: 'Science Author',
              description: 'Science Description',
              url: 'https://science.com',
              urlToImage: 'https://science.com/image.jpg',
              publishedAt: '2024-01-01T10:00:00Z',
              content: 'Science Content',
            ),
          ],
        );

        when(mockRemoteDataSource.fetchCategoryNews(
          category: anyNamed('category'),
          pageSize: anyNamed('pageSize'),
          page: anyNamed('page'),
        )).thenAnswer((_) async => mockResponse);

        final result = await repository.fetchCategoryNews(
          category: NewsCategoryEnum.science,
        );

        expect(result.length, 1);
        expect(result[0].title, 'Science Article');
        verify(mockRemoteDataSource.fetchCategoryNews(
          category: NewsCategoryEnum.science,
          pageSize: null,
          page: null,
        )).called(1);
      });
    });
  });
}
