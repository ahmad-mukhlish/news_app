import 'news_article_dto.dart';

class NewsResponseDto {
  final String status;
  final int? totalResults;
  final List<NewsArticleDto> articles;

  NewsResponseDto({
    required this.status,
    this.totalResults,
    required this.articles,
  });

  factory NewsResponseDto.fromJson(Map<String, dynamic> json) {
    return NewsResponseDto(
      status: json['status'] ?? 'error',
      totalResults: json['totalResults'],
      articles: (json['articles'] as List?)
              ?.map((article) => NewsArticleDto.fromJson(article))
              .toList() ??
          [],
    );
  }
}
