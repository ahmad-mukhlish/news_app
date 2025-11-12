import '../../../../../services/network/api_service.dart';
import '../../dto/news_response_dto.dart';

class HomeRemoteDataSource {
  final ApiService apiService;

  HomeRemoteDataSource({required this.apiService});

  static const String topHeadlines = '/top-headlines';
  static const int defaultPageSize = 20;
  static const int defaultPage = 1;
  static const String defaultCountry = 'us';

  Future<NewsResponseDto> fetchTopHeadlines({
    String? country,
    int? pageSize,
    int? page,
  }) async {
    try {
      final response = await apiService.get(
        path: topHeadlines,
        queryParameters: {
          'country': country ?? defaultCountry,
          'pageSize': pageSize ?? defaultPageSize,
          'page': page ?? defaultPage,
        },
      );
      return NewsResponseDto.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
