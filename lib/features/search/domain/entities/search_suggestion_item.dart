import '../enums/search_in_enum.dart';
import '../enums/sort_by_enum.dart';

class SearchSuggestionItem {
  final String query;
  final SearchInEnum searchIn;
  final SortByEnum sortBy;

  SearchSuggestionItem({
    required this.query,
    required this.searchIn,
    required this.sortBy,
  });

  String get displayText {
    if (searchIn != SearchInEnum.none) return 'Search "$query" ${searchIn.displayName}';
    return 'Search "$query" ${sortBy.displayName}';
  }
}
