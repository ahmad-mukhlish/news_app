import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/features/search/domain/enums/sort_by_enum.dart';

void main() {
  group('SortByEnum', () {
    test('should have all 4 sort values', () {
      expect(SortByEnum.values.length, 4);
      expect(SortByEnum.values, contains(SortByEnum.newest));
      expect(SortByEnum.values, contains(SortByEnum.popularity));
      expect(SortByEnum.values, contains(SortByEnum.relevancy));
      expect(SortByEnum.values, contains(SortByEnum.none));
    });

    group('toDto', () {
      test('should return correct API string for newest', () {
        expect(SortByEnum.newest.toDto, 'publishedAt');
      });

      test('should return correct API string for popularity', () {
        expect(SortByEnum.popularity.toDto, 'popularity');
      });

      test('should return correct API string for relevancy', () {
        expect(SortByEnum.relevancy.toDto, 'relevancy');
      });

      test('should return null for none', () {
        expect(SortByEnum.none.toDto, null);
      });

      test('all non-none values should return non-null strings', () {
        expect(SortByEnum.newest.toDto, isNotNull);
        expect(SortByEnum.popularity.toDto, isNotNull);
        expect(SortByEnum.relevancy.toDto, isNotNull);
      });
    });

    group('displayName', () {
      test('should return correct display name for newest', () {
        expect(SortByEnum.newest.displayName, '(latest first)');
      });

      test('should return correct display name for popularity', () {
        expect(SortByEnum.popularity.displayName, '(most popular)');
      });

      test('should return correct display name for relevancy', () {
        expect(SortByEnum.relevancy.displayName, '(most relevant)');
      });

      test('should return empty string for none', () {
        expect(SortByEnum.none.displayName, '');
      });

      test('all displayNames should be valid String instances', () {
        for (final sortBy in SortByEnum.values) {
          expect(sortBy.displayName, isA<String>());
        }
      });

      test('all non-none displayNames should be non-empty', () {
        expect(SortByEnum.newest.displayName, isNotEmpty);
        expect(SortByEnum.popularity.displayName, isNotEmpty);
        expect(SortByEnum.relevancy.displayName, isNotEmpty);
      });
    });

    group('edge cases', () {
      test('should handle all enum values without errors', () {
        for (final sortBy in SortByEnum.values) {
          expect(() => sortBy.toDto, returnsNormally);
          expect(() => sortBy.displayName, returnsNormally);
        }
      });
    });
  });
}
