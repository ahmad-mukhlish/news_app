import 'package:get/get.dart';

import '../../data/repositories/categories_repository.dart';

class CategoriesController extends GetxController {
  final CategoriesRepository repository;

  CategoriesController({required this.repository});
}
