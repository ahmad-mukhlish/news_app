import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:news_app/app/data/news/dto/news_response_dto.dart';
import 'package:news_app/features/search/data/datasources/remote/search_remote_data_source.dart';
import 'package:news_app/features/search/domain/enums/search_in_enum.dart';
import 'package:news_app/features/search/domain/enums/sort_by_enum.dart';
import 'package:news_app/app/services/network/api_service.dart';

import 'search_remote_data_source_test.mocks.dart';

@GenerateMocks([ApiService])
void main() {
  late MockApiService mockApiService;
  late SearchRemoteDataSource dataSource;

  setUp(() {
    mockApiService = MockApiService();
    dataSource = SearchRemoteDataSource(apiService: mockApiService);
  });

  Map<String, dynamic> mockResponseJson({int articles = 1}) {
    return {
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
    };
  }

  Response<Map<String, dynamic>> buildResponse(Map<String, dynamic> json) {
    return Response<Map<String, dynamic>>(
      data: json,
      requestOptions: RequestOptions(path: SearchRemoteDataSource.everything),
    );
  }

  test('searchArticles calls ApiService with default pagination', () async {
    final response = buildResponse(mockResponseJson());
    when(mockApiService.get(
      path: SearchRemoteDataSource.everything,
      queryParameters: anyNamed('queryParameters'),
      options: anyNamed('options'),
    )).thenAnswer((_) async => response);

    final result = await dataSource.searchArticles(query: 'flutter');

    expect(result.status, 'ok');
    expect(result.totalResults, 1);
    verify(mockApiService.get(
      path: SearchRemoteDataSource.everything,
      queryParameters: {
        'q': 'flutter',
        'pageSize': SearchRemoteDataSource.defaultPageSize,
        'page': SearchRemoteDataSource.defaultPage,
      },
      options: null,
    )).called(1);
  });

  test('searchArticles forwards optional filters when provided', () async {
    final response = buildResponse(mockResponseJson(articles: 2));
    when(mockApiService.get(
      path: SearchRemoteDataSource.everything,
      queryParameters: anyNamed('queryParameters'),
      options: anyNamed('options'),
    )).thenAnswer((_) async => response);

    await dataSource.searchArticles(
      query: 'dart',
      searchIn: SearchInEnum.title,
      sortBy: SortByEnum.popularity,
      pageSize: 5,
      page: 3,
    );

    verify(mockApiService.get(
      path: SearchRemoteDataSource.everything,
      queryParameters: {
        'q': 'dart',
        'pageSize': 5,
        'page': 3,
        'searchIn': 'title',
        'sortBy': 'popularity',
      },
      options: null,
    )).called(1);
  });

  test('searchArticles rethrows ApiService errors', () async {
    when(mockApiService.get(
      path: SearchRemoteDataSource.everything,
      queryParameters: anyNamed('queryParameters'),
      options: anyNamed('options'),
    )).thenThrow(Exception('network'));

    expect(
      () => dataSource.searchArticles(query: 'flutter'),
      throwsException,
    );
  });
}
