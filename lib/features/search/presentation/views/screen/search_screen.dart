import 'package:flutter/material.dart' hide SearchController;
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';

import '../../../../../app/config/app_config.dart';
import '../../../../../app/helper/common_widgets/empty_state_widget.dart';
import '../../../../../app/helper/common_widgets/paged_news_list.dart';
import '../../../domain/entities/search_suggestion_item.dart';
import '../../get/search_controller.dart';
import '../widgets/search_suggestion_tile.dart';

class SearchScreen extends GetView<SearchController> {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          'Search',
          style: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: buildBody(context),
    );
  }

  Widget buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          buildSearchField(context),
          const SizedBox(height: 16),
          Expanded(child: buildSearchResult()),
        ],
      ),
    );
  }

  Widget buildSearchField(BuildContext context) {
    return TypeAheadField<SearchSuggestionItem>(
      controller: controller.searchTextController,
      debounceDuration: const Duration(milliseconds: 300),
      hideOnEmpty: true,
      builder: (context, textController, focusNode) =>
          buildSearchBar(textController, focusNode, context),
      suggestionsCallback: controller.generateSuggestions,
      itemBuilder: (_, suggestion) =>
          SearchSuggestionTile(suggestion: suggestion),
      onSelected: controller.executeSearch,
    );
  }

  Widget buildSearchBar(
    TextEditingController textController,
    FocusNode focusNode,
    BuildContext context,
  ) {
    return SearchBar(
      controller: textController,
      focusNode: focusNode,
      hintText: 'Search news...',
      leading: const Icon(Icons.search),
      trailing: [buildClearSearchButton()],
      elevation: WidgetStateProperty.all(2),
      padding: WidgetStateProperty.all(
        const EdgeInsets.symmetric(horizontal: 16),
      ),
      backgroundColor: WidgetStateProperty.all(
        Theme.of(context).colorScheme.secondaryContainer,
      ),
      onSubmitted: controller.submitQuery,
    );
  }

  Widget buildClearSearchButton() {
    return Obx(() {
      if (!controller.hasText.value) {
        return const SizedBox.shrink();
      }
      return IconButton(
        icon: Semantics(
          label: "Clear search",
          button: true,
          child: const Icon(Icons.clear),
        ),
        onPressed: controller.clearSearch,
      );
    });
  }

  Widget buildSearchResult() {
    return Obx(() {
      if (!controller.hasSearched.value) {
        return const EmptyStateWidget(
          message: 'Enter keywords to search for news',
          lottieUrl: AppConfig.searchPageLottieAnimation,
          lottieHeight: 250,
        );
      }

      return PagedNewsList(pagingController: controller.pagingController);
    });
  }
}
