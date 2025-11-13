enum SortByEnum {
  newest,
  popularity,
  relevancy,
  none;

  String? get toDto {
    switch (this) {
      case SortByEnum.newest:
        return 'publishedAt';
      case SortByEnum.popularity:
        return 'popularity';
      case SortByEnum.relevancy:
        return 'relevancy';
      case SortByEnum.none:
        return null;
    }
  }

  String get displayName {
    switch (this) {
      case SortByEnum.newest:
        return '(latest first)';
      case SortByEnum.popularity:
        return '(most popular)';
      case SortByEnum.relevancy:
        return '(most relevant)';
      case SortByEnum.none:
        return '';
    }
  }
}
