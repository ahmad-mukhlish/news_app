import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/app/domain/entities/news_article.dart';

void main() {
  group('NewsArticle', () {
    test('stores provided values', () {
      final publishedAt = DateTime(2024, 1, 10, 12, 30);

      final article = NewsArticle(
        author: 'Author Name',
        title: 'Breaking News',
        description: 'Important details',
        url: 'https://example.com/article',
        urlToImage: 'https://example.com/image.jpg',
        publishedAt: publishedAt,
        content: 'Full content here',
        sourceName: 'News Source',
      );

      expect(article.author, 'Author Name');
      expect(article.title, 'Breaking News');
      expect(article.description, 'Important details');
      expect(article.url, 'https://example.com/article');
      expect(article.urlToImage, 'https://example.com/image.jpg');
      expect(article.publishedAt, publishedAt);
      expect(article.content, 'Full content here');
      expect(article.sourceName, 'News Source');
    });
  });
}
