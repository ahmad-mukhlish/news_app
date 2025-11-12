import '../../domain/entities/news_article.dart';
import '../datasources/remote/home_remote_data_source.dart';
import '../mappers/news_article_mapper.dart';

class HomeRepository {
  final HomeRemoteDataSource remoteDataSource;

  HomeRepository({required this.remoteDataSource});

  Future<List<NewsArticle>> fetchTopHeadlines({
    String? country = 'us',
    int? pageSize = 20,
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
