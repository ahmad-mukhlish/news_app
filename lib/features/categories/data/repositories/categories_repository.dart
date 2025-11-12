import '../../../../app/data/mappers/news_article_mapper.dart';
import '../../../../app/domain/entities/news_article.dart';
import '../../domain/enums/news_category.dart';
import '../datasources/remote/categories_remote_data_source.dart';

class CategoriesRepository {
  final CategoriesRemoteDataSource remoteDataSource;

  CategoriesRepository({required this.remoteDataSource});

  Future<List<NewsArticle>> fetchCategoryNews({
    required NewsCategoryEnum category,
    int? pageSize,
    int? page,
  }) async {
    try {
      final response = await remoteDataSource.fetchCategoryNews(
        category: category,
        pageSize: pageSize,
        page: page,
      );

      return NewsArticleMapper.toEntityList(response.articles);
    } catch (e) {
      rethrow;
    }
  }
}
