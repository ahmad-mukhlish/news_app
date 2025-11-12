import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../get/categories_controller.dart';

class CategoriesScreen extends GetView<CategoriesController> {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          'Categories',
          style: TextStyle(color: Theme.of(context).colorScheme.secondary),
        ),
      ),
      body: const Center(
        child: Text('Categories - Coming Soon'),
      ),
    );
  }
}
