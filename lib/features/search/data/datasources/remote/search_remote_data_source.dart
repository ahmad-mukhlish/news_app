import '../../../../../app/data/dto/news_response_dto.dart';
import '../../../../../app/services/network/api_service.dart';
import '../../../domain/enums/search_in_enum.dart';
import '../../../domain/enums/sort_by_enum.dart';

class SearchRemoteDataSource {
  final ApiService apiService;

  SearchRemoteDataSource({required this.apiService});

  static const String everything = '/everything';
  static const int defaultPageSize = 20;
  static const int defaultPage = 1;

  Future<NewsResponseDto> searchArticles({
    required String query,
    SearchInEnum? searchIn,
    SortByEnum? sortBy,
    int? pageSize,
    int? page,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'q': query,
        'pageSize': pageSize ?? defaultPageSize,
        'page': page ?? defaultPage,
         if (searchIn?.toDto != null) 'searchIn': searchIn?.toDto,
         if (sortBy?.toDto != null) 'sortBy': sortBy?.toDto,
      };

      final response = await apiService.get(
        path: everything,
        queryParameters: queryParameters,
      );

      return NewsResponseDto.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
