import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../../../app/domain/entities/news_article.dart';
import '../../data/repositories/search_repository.dart';
import '../../domain/entities/search_suggestion_item.dart';
import '../../domain/enums/search_in_enum.dart';
import '../../domain/enums/sort_by_enum.dart';

class SearchController extends GetxController {
  final SearchRepository repository;

  SearchController({required this.repository});

  final hasSearched = false.obs;
  final currentQuery = ''.obs;
  final hasText = false.obs;
  SearchInEnum? currentSearchIn;
  SortByEnum? currentSortBy;

  late final TextEditingController searchTextController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    searchTextController.addListener(() {
      hasText.value = searchTextController.text.isNotEmpty;
    });
  }

  late final PagingController<int, NewsArticle> pagingController = PagingController(
    getNextPageKey: (state) {
      if (state.lastPageIsEmpty) return null;
      return state.nextIntPageKey;
    },
    fetchPage: _fetchPage,
  );

  Future<List<NewsArticle>> _fetchPage(int pageKey) async {
    if (currentQuery.value.isEmpty) return [];

    final articles = await repository.searchArticles(
      query: currentQuery.value,
      searchIn: currentSearchIn,
      sortBy: currentSortBy,
      page: pageKey,
    );
    return articles;
  }

  List<SearchSuggestionItem> generateSuggestions(String query) {
    if (query.isEmpty || query.length < 3) return [];

    return [
      // SearchIn variants (no sortBy preference)
      SearchSuggestionItem(
        query: query,
        searchIn: SearchInEnum.title,
        sortBy: SortByEnum.none,
      ),
      SearchSuggestionItem(
        query: query,
        searchIn: SearchInEnum.description,
        sortBy: SortByEnum.none,
      ),
      SearchSuggestionItem(
        query: query,
        searchIn: SearchInEnum.titleAndDescription,
        sortBy: SortByEnum.none,
      ),
      // SortBy variants (search all fields)
      SearchSuggestionItem(
        query: query,
        searchIn: SearchInEnum.none,
        sortBy: SortByEnum.newest,
      ),
      SearchSuggestionItem(
        query: query,
        searchIn: SearchInEnum.none,
        sortBy: SortByEnum.popularity,
      ),
      SearchSuggestionItem(
        query: query,
        searchIn: SearchInEnum.none,
        sortBy: SortByEnum.relevancy,
      ),
    ];
  }

  void executeSearch(SearchSuggestionItem suggestion) {
    currentQuery.value = suggestion.query;
    searchTextController.text = suggestion.query;
    currentSearchIn = suggestion.searchIn != SearchInEnum.none ? suggestion.searchIn : null;
    currentSortBy = suggestion.sortBy != SortByEnum.none ? suggestion.sortBy : null;

    hasSearched.value = true;
    pagingController.refresh();
  }

  void submitQuery(String query) {
    if (query.length < 3) return;

    executeSearch(
      SearchSuggestionItem(
        query: query,
        searchIn: SearchInEnum.none,
        sortBy: SortByEnum.none,
      ),
    );
  }

  void clearSearch() {
    searchTextController.clear();
  }

  @override
  void onClose() {
    searchTextController.dispose();
    pagingController.dispose();
    super.onClose();
  }
}
