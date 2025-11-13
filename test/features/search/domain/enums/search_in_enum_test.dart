import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/features/search/domain/enums/search_in_enum.dart';

void main() {
  group('SearchInEnum', () {
    test('should have all 4 search location values', () {
      expect(SearchInEnum.values.length, 4);
      expect(SearchInEnum.values, contains(SearchInEnum.title));
      expect(SearchInEnum.values, contains(SearchInEnum.description));
      expect(SearchInEnum.values, contains(SearchInEnum.titleAndDescription));
      expect(SearchInEnum.values, contains(SearchInEnum.none));
    });

    group('toDto', () {
      test('should return correct API string for title', () {
        expect(SearchInEnum.title.toDto, 'title');
      });

      test('should return correct API string for description', () {
        expect(SearchInEnum.description.toDto, 'description');
      });

      test('should return correct API string for titleAndDescription', () {
        expect(SearchInEnum.titleAndDescription.toDto, 'title,description');
      });

      test('should return null for none', () {
        expect(SearchInEnum.none.toDto, null);
      });

      test('all non-none values should return non-null strings', () {
        expect(SearchInEnum.title.toDto, isNotNull);
        expect(SearchInEnum.description.toDto, isNotNull);
        expect(SearchInEnum.titleAndDescription.toDto, isNotNull);
      });

      test('titleAndDescription should return comma-separated value', () {
        expect(SearchInEnum.titleAndDescription.toDto, contains(','));
        expect(SearchInEnum.titleAndDescription.toDto!.split(','), ['title', 'description']);
      });
    });

    group('displayName', () {
      test('should return correct display name for title', () {
        expect(SearchInEnum.title.displayName, 'in title');
      });

      test('should return correct display name for description', () {
        expect(SearchInEnum.description.displayName, 'in description');
      });

      test('should return correct display name for titleAndDescription', () {
        expect(SearchInEnum.titleAndDescription.displayName, 'in title & description');
      });

      test('should return empty string for none', () {
        expect(SearchInEnum.none.displayName, '');
      });

      test('all displayNames should be valid String instances', () {
        for (final searchIn in SearchInEnum.values) {
          expect(searchIn.displayName, isA<String>());
        }
      });

      test('all non-none displayNames should be non-empty', () {
        expect(SearchInEnum.title.displayName, isNotEmpty);
        expect(SearchInEnum.description.displayName, isNotEmpty);
        expect(SearchInEnum.titleAndDescription.displayName, isNotEmpty);
      });

      test('all non-none displayNames should start with "in"', () {
        expect(SearchInEnum.title.displayName, startsWith('in '));
        expect(SearchInEnum.description.displayName, startsWith('in '));
        expect(SearchInEnum.titleAndDescription.displayName, startsWith('in '));
      });
    });

    group('edge cases', () {
      test('should handle all enum values without errors', () {
        for (final searchIn in SearchInEnum.values) {
          expect(() => searchIn.toDto, returnsNormally);
          expect(() => searchIn.displayName, returnsNormally);
        }
      });
    });
  });
}
