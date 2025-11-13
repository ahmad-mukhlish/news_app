import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/app/data/news/dto/news_article_dto.dart';
import 'package:news_app/app/data/news/dto/source_dto.dart';
import 'package:news_app/app/data/news/mappers/news_article_mapper.dart';

void main() {
  group('NewsArticleMapper', () {
    group('toEntity', () {
      test('should handle all null values from DTO', () {
        final dto = NewsArticleDto(
          source: null,
          author: null,
          title: null,
          description: null,
          url: null,
          urlToImage: null,
          publishedAt: null,
          content: null,
        );

        final result = NewsArticleMapper.toEntity(dto);

        expect(result.author, '');
        expect(result.title, '');
        expect(result.description, '');
        expect(result.url, '');
        expect(result.urlToImage, '');
        expect(result.content, '');
        expect(result.sourceName, 'Unknown Source');
        expect(result.publishedAt, isA<DateTime>());
      });

      test('should map all valid values correctly', () {
        final source = SourceDto(name: 'Test Source');
        final dto = NewsArticleDto(
          source: source,
          author: 'John Doe',
          title: 'Test Title',
          description: 'Test Description',
          url: 'https://test.com',
          urlToImage: 'https://test.com/image.jpg',
          publishedAt: '2024-01-01T10:00:00Z',
          content: 'Test Content',
        );

        final result = NewsArticleMapper.toEntity(dto);

        expect(result.author, 'John Doe');
        expect(result.title, 'Test Title');
        expect(result.description, 'Test Description');
        expect(result.url, 'https://test.com');
        expect(result.urlToImage, 'https://test.com/image.jpg');
        expect(result.content, 'Test Content');
        expect(result.sourceName, 'Test Source');
        expect(result.publishedAt.year, 2024);
        expect(result.publishedAt.month, 1);
        expect(result.publishedAt.day, 1);
      });

      test('should handle invalid date string by using current date', () {
        final dto = NewsArticleDto(
          publishedAt: 'invalid-date',
        );

        final result = NewsArticleMapper.toEntity(dto);

        expect(result.publishedAt, isA<DateTime>());
        final now = DateTime.now();
        expect(result.publishedAt.year, now.year);
      });

      test('should use "Unknown Source" when source is null', () {
        final dto = NewsArticleDto(
          source: null,
        );

        final result = NewsArticleMapper.toEntity(dto);

        expect(result.sourceName, 'Unknown Source');
      });

      test('should use "Unknown Source" when source name is null', () {
        final source = SourceDto(name: null);
        final dto = NewsArticleDto(
          source: source,
        );

        final result = NewsArticleMapper.toEntity(dto);

        expect(result.sourceName, 'Unknown Source');
      });
    });

    group('toEntityList', () {
      test('should return empty list for empty input', () {
        final dtoList = <NewsArticleDto>[];

        final result = NewsArticleMapper.toEntityList(dtoList);

        expect(result, isEmpty);
      });

      test('should map multiple DTOs to entities correctly', () {
        final dtoList = [
          NewsArticleDto(title: 'Article 1', author: 'Author 1'),
          NewsArticleDto(title: 'Article 2', author: 'Author 2'),
          NewsArticleDto(title: 'Article 3', author: 'Author 3'),
        ];

        final result = NewsArticleMapper.toEntityList(dtoList);

        expect(result.length, 3);
        expect(result[0].title, 'Article 1');
        expect(result[0].author, 'Author 1');
        expect(result[1].title, 'Article 2');
        expect(result[1].author, 'Author 2');
        expect(result[2].title, 'Article 3');
        expect(result[2].author, 'Author 3');
      });
    });
  });
}
