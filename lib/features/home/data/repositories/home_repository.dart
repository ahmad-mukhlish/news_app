import '../../../../app/data/news/mappers/news_article_mapper.dart';
import '../../../../app/domain/entities/news_article.dart';
import '../datasources/remote/home_remote_data_source.dart';

class HomeRepository {
  final HomeRemoteDataSource remoteDataSource;

  HomeRepository({required this.remoteDataSource});

  Future<List<NewsArticle>> fetchTopHeadlines({
    String? country,
    int? pageSize,
    int? page,
  }) async {
    try {
      // final response = await remoteDataSource.fetchTopHeadlines(
      //   country: country,
      //   pageSize: pageSize,
      //   page: page,
      // );

      return [];
    } catch (e) {
      rethrow;
    }
  }
}
