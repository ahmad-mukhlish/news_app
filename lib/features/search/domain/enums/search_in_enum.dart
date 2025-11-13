enum SearchInEnum {
  title,
  description,
  titleAndDescription,
  none;

  String? get toDto {
    switch (this) {
      case SearchInEnum.title:
        return 'title';
      case SearchInEnum.description:
        return 'description';
      case SearchInEnum.titleAndDescription:
        return 'title,description';
      case SearchInEnum.none:
        return null;
    }
  }

  String get displayName {
    switch (this) {
      case SearchInEnum.title:
        return 'in title';
      case SearchInEnum.description:
        return 'in description';
      case SearchInEnum.titleAndDescription:
        return 'in title & description';
      case SearchInEnum.none:
        return '';
    }
  }
}
