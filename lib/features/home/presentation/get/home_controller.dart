import 'package:get/get.dart';

import '../../data/repositories/home_repository.dart';
import '../../domain/entities/news_article.dart';

class HomeController extends GetxController {
  final HomeRepository repository;

  HomeController({required this.repository});

  final RxList<NewsArticle> articles = <NewsArticle>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool hasError = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchTopHeadlines();
  }

  Future<void> fetchTopHeadlines() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final result = await repository.fetchTopHeadlines(
        country: 'us',
        pageSize: 20,
      );

      articles.value = result;
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshTopHeadlines() async {
    await fetchTopHeadlines();
  }
}
