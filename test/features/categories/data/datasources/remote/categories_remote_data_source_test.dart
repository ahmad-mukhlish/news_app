import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:news_app/app/data/dto/news_response_dto.dart';
import 'package:news_app/app/services/network/api_service.dart';
import 'package:news_app/features/categories/data/datasources/remote/categories_remote_data_source.dart';
import 'package:news_app/features/categories/domain/enums/news_category_enum.dart';
import 'categories_remote_data_source_test.mocks.dart';

@GenerateMocks([ApiService])
void main() {
  late CategoriesRemoteDataSource dataSource;
  late MockApiService mockApiService;

  setUp(() {
    mockApiService = MockApiService();
    dataSource = CategoriesRemoteDataSource(apiService: mockApiService);
  });

  group('CategoriesRemoteDataSource', () {
    group('fetchCategoryNews', () {
      test('should call apiService.get with correct parameters', () async {
        final mockResponseData = {
          'status': 'ok',
          'totalResults': 0,
          'articles': [],
        };

        when(mockApiService.get(
          path: anyNamed('path'),
          queryParameters: anyNamed('queryParameters'),
        )).thenAnswer((_) async => Response(
              data: mockResponseData,
              statusCode: 200,
              requestOptions: RequestOptions(path: '/top-headlines'),
            ));

        await dataSource.fetchCategoryNews(
          category: NewsCategoryEnum.technology,
          pageSize: 10,
          page: 2,
        );

        verify(mockApiService.get(
          path: '/top-headlines',
          queryParameters: {
            'category': 'technology',
            'pageSize': 10,
            'page': 2,
          },
        )).called(1);
      });

      test('should use default values when optional parameters are null', () async {
        final mockResponseData = {
          'status': 'ok',
          'totalResults': 0,
          'articles': [],
        };

        when(mockApiService.get(
          path: anyNamed('path'),
          queryParameters: anyNamed('queryParameters'),
        )).thenAnswer((_) async => Response(
              data: mockResponseData,
              statusCode: 200,
              requestOptions: RequestOptions(path: '/top-headlines'),
            ));

        await dataSource.fetchCategoryNews(
          category: NewsCategoryEnum.business,
        );

        verify(mockApiService.get(
          path: '/top-headlines',
          queryParameters: {
            'category': 'business',
            'pageSize': 20,
            'page': 1,
          },
        )).called(1);
      });

      test('should return NewsResponseDto on success', () async {
        final mockResponseData = {
          'status': 'ok',
          'totalResults': 1,
          'articles': [
            {
              'source': {'id': null, 'name': 'Test Source'},
              'author': 'Test Author',
              'title': 'Test Title',
              'description': 'Test Description',
              'url': 'https://test.com',
              'urlToImage': 'https://test.com/image.jpg',
              'publishedAt': '2024-01-01T10:00:00Z',
              'content': 'Test Content',
            }
          ],
        };

        when(mockApiService.get(
          path: anyNamed('path'),
          queryParameters: anyNamed('queryParameters'),
        )).thenAnswer((_) async => Response(
              data: mockResponseData,
              statusCode: 200,
              requestOptions: RequestOptions(path: '/top-headlines'),
            ));

        final result = await dataSource.fetchCategoryNews(
          category: NewsCategoryEnum.sports,
        );

        expect(result, isA<NewsResponseDto>());
        expect(result.status, 'ok');
        expect(result.totalResults, 1);
        expect(result.articles.length, 1);
        expect(result.articles[0].title, 'Test Title');
      });

      test('should throw exception when apiService fails', () async {
        when(mockApiService.get(
          path: anyNamed('path'),
          queryParameters: anyNamed('queryParameters'),
        )).thenThrow(Exception('Network Error'));

        expect(
          () => dataSource.fetchCategoryNews(
            category: NewsCategoryEnum.health,
          ),
          throwsException,
        );
      });

      test('should correctly convert category enum to string', () async {
        final mockResponseData = {
          'status': 'ok',
          'totalResults': 0,
          'articles': [],
        };

        when(mockApiService.get(
          path: anyNamed('path'),
          queryParameters: anyNamed('queryParameters'),
        )).thenAnswer((_) async => Response(
              data: mockResponseData,
              statusCode: 200,
              requestOptions: RequestOptions(path: '/top-headlines'),
            ));

        await dataSource.fetchCategoryNews(
          category: NewsCategoryEnum.entertainment,
        );

        verify(mockApiService.get(
          path: '/top-headlines',
          queryParameters: {
            'category': 'entertainment',
            'pageSize': 20,
            'page': 1,
          },
        )).called(1);
      });
    });
  });
}
