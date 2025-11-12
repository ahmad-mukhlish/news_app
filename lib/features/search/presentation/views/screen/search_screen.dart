import 'package:flutter/material.dart';
import 'package:get/get.dart';


class SearchScreen extends GetView<SearchController> {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          'Search',
          style: TextStyle(color: Theme.of(context).colorScheme.secondary),
        ),
      ),
      body: const Center(
        child: Text('Search - Coming Soon'),
      ),
    );
  }
}
