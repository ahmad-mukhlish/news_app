import '../../domain/entities/news_article.dart';
import '../datasources/remote/home_remote_data_source.dart';
import '../mappers/news_article_mapper.dart';

class HomeRepository {
  final HomeRemoteDataSource remoteDataSource;

  HomeRepository({required this.remoteDataSource});

  Future<List<NewsArticle>> fetchTopHeadlines({
    String country = 'us',
    int pageSize = 20,
    int page = 1,
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

  Future<List<NewsArticle>> fetchByCategory({
    required String category,
    String country = 'us',
    int pageSize = 20,
    int page = 1,
  }) async {
    try {
      final response = await remoteDataSource.fetchByCategory(
        category: category,
        country: country,
        pageSize: pageSize,
        page: page,
      );

      return NewsArticleMapper.toEntityList(response.articles);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<NewsArticle>> searchNews({
    required String query,
    List<String> searchIn = const ['title', 'description'],
    int pageSize = 20,
    int page = 1,
  }) async {
    try {
      final response = await remoteDataSource.searchNews(
        query: query,
        searchIn: searchIn,
        pageSize: pageSize,
        page: page,
      );

      return NewsArticleMapper.toEntityList(response.articles);
    } catch (e) {
      rethrow;
    }
  }
}
