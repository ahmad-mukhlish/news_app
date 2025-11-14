import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/features/search/domain/entities/search_suggestion_item.dart';
import 'package:news_app/features/search/domain/enums/search_in_enum.dart';
import 'package:news_app/features/search/domain/enums/sort_by_enum.dart';

void main() {
  group('SearchSuggestionItem', () {
    test('prefers searchIn display when provided', () {
      final item = SearchSuggestionItem(
        query: 'flutter',
        searchIn: SearchInEnum.title,
        sortBy: SortByEnum.none,
      );

      expect(item.displayText, 'Search "flutter" in title');
    });

    test('falls back to sortBy display when searchIn is none', () {
      final item = SearchSuggestionItem(
        query: 'dart',
        searchIn: SearchInEnum.none,
        sortBy: SortByEnum.popularity,
      );

      expect(item.displayText, 'Search "dart" (most popular)');
    });
  });
}
