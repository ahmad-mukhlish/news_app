import '../../domain/entities/news_article.dart';
import '../dto/news_article_dto.dart';

class NewsArticleMapper {
  static NewsArticle toEntity(NewsArticleDto dto) {
    return NewsArticle(
      author: dto.author ?? '',
      title: dto.title ?? '',
      description: dto.description ?? '',
      url: dto.url ?? '',
      urlToImage: dto.urlToImage ?? '',
      publishedAt: dto.publishedAt != null
          ? DateTime.tryParse(dto.publishedAt!) ?? DateTime.now()
          : DateTime.now(),
      content: dto.content ?? '',
      sourceName: dto.source?.name ?? 'Unknown Source',
    );
  }

  static List<NewsArticle> toEntityList(List<NewsArticleDto> dtoList) {
    return dtoList.map((dto) => toEntity(dto)).toList();
  }
}
