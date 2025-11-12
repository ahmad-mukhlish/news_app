import '../../../../../app/data/dto/news_response_dto.dart';
import '../../../../../app/services/network/api_service.dart';
import '../../../domain/enums/news_category.dart';

class CategoriesRemoteDataSource {
  final ApiService apiService;

  CategoriesRemoteDataSource({required this.apiService});

  static const String topHeadlines = '/top-headlines';
  static const int defaultPageSize = 20;
  static const int defaultPage = 1;

  Future<NewsResponseDto> fetchCategoryNews({
    required NewsCategoryEnum category,
    int? pageSize,
    int? page,
  }) async {
    try {
      final response = await apiService.get(
        path: topHeadlines,
        queryParameters: {
          'category': category.toDto,
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
