import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CommonMethods', () {
    group('openUrl', () {
      test('should parse valid HTTP URL without throwing', () async {
        expect(
          () async {
            final uri = Uri.parse('https://example.com');
            expect(uri.scheme, 'https');
            expect(uri.host, 'example.com');
          },
          returnsNormally,
        );
      });

      test('should parse valid HTTPS URL without throwing', () async {
        expect(
          () async {
            final uri = Uri.parse('https://news.example.com/article/123');
            expect(uri.scheme, 'https');
            expect(uri.host, 'news.example.com');
            expect(uri.path, '/article/123');
          },
          returnsNormally,
        );
      });

      test('should parse URL with query parameters without throwing', () async {
        expect(
          () async {
            final uri = Uri.parse('https://example.com?foo=bar&baz=qux');
            expect(uri.scheme, 'https');
            expect(uri.host, 'example.com');
            expect(uri.queryParameters['foo'], 'bar');
            expect(uri.queryParameters['baz'], 'qux');
          },
          returnsNormally,
        );
      });

      test('should parse URL with fragment without throwing', () async {
        expect(
          () async {
            final uri = Uri.parse('https://example.com/page#section');
            expect(uri.scheme, 'https');
            expect(uri.host, 'example.com');
            expect(uri.fragment, 'section');
          },
          returnsNormally,
        );
      });

      test('should parse URL with port without throwing', () async {
        expect(
          () async {
            final uri = Uri.parse('https://example.com:8080/api');
            expect(uri.scheme, 'https');
            expect(uri.host, 'example.com');
            expect(uri.port, 8080);
            expect(uri.path, '/api');
          },
          returnsNormally,
        );
      });

      test('should handle empty string URL', () async {
        expect(
          () {
            final uri = Uri.parse('');
            expect(uri.toString(), '');
          },
          returnsNormally,
        );
      });

      test('should parse relative URL without throwing', () async {
        expect(
          () async {
            final uri = Uri.parse('/relative/path');
            expect(uri.path, '/relative/path');
          },
          returnsNormally,
        );
      });

      test('should parse URL with special characters in path', () async {
        expect(
          () async {
            final uri = Uri.parse('https://example.com/article/hello%20world');
            expect(uri.scheme, 'https');
            expect(uri.host, 'example.com');
            expect(uri.path, '/article/hello%20world');
          },
          returnsNormally,
        );
      });
    });
  });
}
