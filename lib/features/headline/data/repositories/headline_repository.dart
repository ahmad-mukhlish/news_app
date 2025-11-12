import '../../domain/entities/news_article.dart';
import '../datasources/remote/headline_remote_data_source.dart';
import '../mappers/news_article_mapper.dart';

class HeadlineRepository {
  final HeadlineRemoteDataSource remoteDataSource;

  HeadlineRepository({required this.remoteDataSource});

  Future<List<NewsArticle>> fetchTopHeadlines({
    String? country,
    int? pageSize,
    int? page,
  }) async {
    try {
      final response = await remoteDataSource.fetchTopHeadlines(
        country: country,
        pageSize: pageSize,
        page: page,
      );

      return NewsArticleMapper.toEntityList(response.articles);
    } catch (e) {
      rethrow;
    }
  }
}
