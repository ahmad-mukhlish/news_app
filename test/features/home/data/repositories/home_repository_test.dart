import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:news_app/app/data/news/dto/news_article_dto.dart';
import 'package:news_app/app/data/news/dto/news_response_dto.dart';
import 'package:news_app/app/data/news/dto/source_dto.dart';
import 'package:news_app/features/home/data/datasources/remote/home_remote_data_source.dart';
import 'package:news_app/features/home/data/repositories/home_repository.dart';


import 'home_repository_test.mocks.dart';

@GenerateMocks([HomeRemoteDataSource])
void main() {
  late HomeRepository repository;
  late MockHomeRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockRemoteDataSource = MockHomeRemoteDataSource();
    repository = HomeRepository(remoteDataSource: mockRemoteDataSource);
  });

  group('HomeRepository', () {
    group('fetchTopHeadlines', () {
      test('should return list of NewsArticle on success', () async {
        final mockResponse = NewsResponseDto(
          status: 'ok',
          totalResults: 2,
          articles: [
            NewsArticleDto(
              source: SourceDto(name: 'Source 1'),
              title: 'Article 1',
              author: 'Author 1',
              description: 'Description 1',
              url: 'https://test1.com',
              urlToImage: 'https://test1.com/image.jpg',
              publishedAt: '2024-01-01T10:00:00Z',
              content: 'Content 1',
            ),
            NewsArticleDto(
              source: SourceDto(name: 'Source 2'),
              title: 'Article 2',
              author: 'Author 2',
              description: 'Description 2',
              url: 'https://test2.com',
              urlToImage: 'https://test2.com/image.jpg',
              publishedAt: '2024-01-02T10:00:00Z',
              content: 'Content 2',
            ),
          ],
        );

        when(mockRemoteDataSource.fetchTopHeadlines(
          country: anyNamed('country'),
          pageSize: anyNamed('pageSize'),
          page: anyNamed('page'),
        )).thenAnswer((_) async => mockResponse);

        final result = await repository.fetchTopHeadlines(
          country: 'us',
          pageSize: 20,
          page: 1,
        );

        expect(result.length, 2);
        expect(result[0].title, 'Article 1');
        expect(result[0].author, 'Author 1');
        expect(result[1].title, 'Article 2');
        expect(result[1].author, 'Author 2');
        verify(mockRemoteDataSource.fetchTopHeadlines(
          country: 'us',
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

        when(mockRemoteDataSource.fetchTopHeadlines(
          country: anyNamed('country'),
          pageSize: anyNamed('pageSize'),
          page: anyNamed('page'),
        )).thenAnswer((_) async => mockResponse);

        final result = await repository.fetchTopHeadlines();


        expect(result, isEmpty);
      });

      test('should throw exception when remote data source fails', () async {
        when(mockRemoteDataSource.fetchTopHeadlines(
          country: anyNamed('country'),
          pageSize: anyNamed('pageSize'),
          page: anyNamed('page'),
        )).thenThrow(Exception('API Error'));

        expect(
          () => repository.fetchTopHeadlines(),
          throwsException,
        );
      });

      test('should pass correct parameters to remote data source', () async {
        final mockResponse = NewsResponseDto(
          status: 'ok',
          totalResults: 0,
          articles: [],
        );

        when(mockRemoteDataSource.fetchTopHeadlines(
          country: anyNamed('country'),
          pageSize: anyNamed('pageSize'),
          page: anyNamed('page'),
        )).thenAnswer((_) async => mockResponse);


        await repository.fetchTopHeadlines(
          country: 'uk',
          pageSize: 10,
          page: 2,
        );

        verify(mockRemoteDataSource.fetchTopHeadlines(
          country: 'uk',
          pageSize: 10,
          page: 2,
        )).called(1);
      });
    });
  });
}
