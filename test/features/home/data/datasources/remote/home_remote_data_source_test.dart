import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:news_app/app/services/network/api_service.dart';
import 'package:news_app/features/home/data/datasources/remote/home_remote_data_source.dart';

import 'home_remote_data_source_test.mocks.dart';

@GenerateMocks([ApiService])
void main() {
  late MockApiService mockApiService;
  late HomeRemoteDataSource dataSource;

  setUp(() {
    mockApiService = MockApiService();
    dataSource = HomeRemoteDataSource(apiService: mockApiService);
  });

  Response<Map<String, dynamic>> mockResponse({required int articles}) {
    return Response<Map<String, dynamic>>(
      data: {
        'status': 'ok',
        'totalResults': articles,
        'articles': List.generate(articles, (index) {
          return {
            'source': {'name': 'Source $index'},
            'author': 'Author $index',
            'title': 'Title $index',
            'description': 'Desc $index',
            'url': 'https://example.com/$index',
            'urlToImage': 'https://example.com/$index.png',
            'publishedAt': '2024-01-0${index + 1}T10:00:00Z',
            'content': 'Content $index',
          };
        }),
      },
      requestOptions: RequestOptions(path: HomeRemoteDataSource.topHeadlines),
    );
  }

  test('fetchTopHeadlines uses default parameters when none provided', () async {
    when(mockApiService.get(
      path: HomeRemoteDataSource.topHeadlines,
      queryParameters: anyNamed('queryParameters'),
      options: anyNamed('options'),
    )).thenAnswer((_) async => mockResponse(articles: 2));

    final result = await dataSource.fetchTopHeadlines();

    expect(result.totalResults, 2);
    verify(mockApiService.get(
      path: HomeRemoteDataSource.topHeadlines,
      queryParameters: {
        'country': HomeRemoteDataSource.defaultCountry,
        'pageSize': HomeRemoteDataSource.defaultPageSize,
        'page': HomeRemoteDataSource.defaultPage,
      },
      options: null,
    )).called(1);
  });

  test('fetchTopHeadlines forwards pagination and country overrides', () async {
    when(mockApiService.get(
      path: HomeRemoteDataSource.topHeadlines,
      queryParameters: anyNamed('queryParameters'),
      options: anyNamed('options'),
    )).thenAnswer((_) async => mockResponse(articles: 1));

    await dataSource.fetchTopHeadlines(country: 'id', pageSize: 5, page: 3);

    verify(mockApiService.get(
      path: HomeRemoteDataSource.topHeadlines,
      queryParameters: {
        'country': 'id',
        'pageSize': 5,
        'page': 3,
      },
      options: null,
    )).called(1);
  });

  test('fetchTopHeadlines rethrows ApiService errors', () async {
    when(mockApiService.get(
      path: HomeRemoteDataSource.topHeadlines,
      queryParameters: anyNamed('queryParameters'),
      options: anyNamed('options'),
    )).thenThrow(Exception('network'));

    expect(
      () => dataSource.fetchTopHeadlines(),
      throwsException,
    );
  });
}
