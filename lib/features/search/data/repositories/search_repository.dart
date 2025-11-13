import '../../../../app/data/mappers/news_article_mapper.dart';
import '../../../../app/domain/entities/news_article.dart';
import '../../domain/enums/search_in_enum.dart';
import '../../domain/enums/sort_by_enum.dart';
import '../datasources/remote/search_remote_data_source.dart';

class SearchRepository {
  final SearchRemoteDataSource remoteDataSource;

  SearchRepository({required this.remoteDataSource});

  Future<List<NewsArticle>> searchArticles({
    required String query,
    SearchInEnum? searchIn,
    SortByEnum? sortBy,
    int? pageSize,
    int? page,
  }) async {
    try {
      final response = await remoteDataSource.searchArticles(
        query: query,
        searchIn: searchIn,
        sortBy: sortBy,
        pageSize: pageSize,
        page: page,
      );

      return NewsArticleMapper.toEntityList(response.articles);
    } catch (e) {
      rethrow;
    }
  }
}
