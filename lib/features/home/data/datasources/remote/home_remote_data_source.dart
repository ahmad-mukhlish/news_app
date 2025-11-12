import '../../../../../services/network/api_service.dart';
import '../../dto/news_response_dto.dart';

class HomeRemoteDataSource {
  final ApiService apiService;

  HomeRemoteDataSource({required this.apiService});

  static const String topHeadlines = '/top-headlines';
  static const String everything = '/everything';
  static const int defaultPageSize = 20;
  static const int defaultPage = 1;
  static const String defaultCountry = 'us';

  Future<NewsResponseDto> fetchTopHeadlines({
    String country = defaultCountry,
    int pageSize = defaultPageSize,
    int page = defaultPage,
  }) async {
    try {
      final response = await apiService.get(
        path: topHeadlines,
        queryParameters: {
          'country': country,
          'pageSize': pageSize,
          'page': page,
        },
      );
      return NewsResponseDto.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<NewsResponseDto> fetchByCategory({
    required String category,
    String country = defaultCountry,
    int pageSize = defaultPageSize,
    int page = defaultPage,
  }) async {
    try {
      final response = await apiService.get(
        path: topHeadlines,
        queryParameters: {
          'country': country,
          'category': category,
          'pageSize': pageSize,
          'page': page,
        },
      );

      return NewsResponseDto.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<NewsResponseDto> searchNews({
    required String query,
    List<String> searchIn = const ['title', 'description'],
    int pageSize = defaultPageSize,
    int page = defaultPage,
  }) async {
    try {
      final response = await apiService.get(
        path: everything,
        queryParameters: {
          'q': query,
          'searchIn': searchIn.join(','),
          'pageSize': pageSize,
          'page': page,
        },
      );

      return NewsResponseDto.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
