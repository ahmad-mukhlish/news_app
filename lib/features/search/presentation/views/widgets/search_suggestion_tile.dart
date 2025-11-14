import 'package:flutter/material.dart';

import '../../../domain/entities/search_suggestion_item.dart';

class SearchSuggestionTile extends StatelessWidget {
  final SearchSuggestionItem suggestion;

  const SearchSuggestionTile({
    super.key,
    required this.suggestion,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: "Search suggestion",
      child: ListTile(
        leading: const Icon(Icons.search),
        title: Text(
          suggestion.displayText,
          style: const TextStyle(fontSize: 14),
        ),
      ),
    );
  }
}
