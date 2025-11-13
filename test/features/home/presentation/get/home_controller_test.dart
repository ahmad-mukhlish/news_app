import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:news_app/features/home/data/repositories/home_repository.dart';
import 'package:news_app/features/home/presentation/get/home_controller.dart';

import 'home_controller_test.mocks.dart';

@GenerateMocks([HomeRepository])
void main() {
  late HomeController controller;
  late MockHomeRepository mockRepository;

  setUp(() {
    mockRepository = MockHomeRepository();
    controller = HomeController(repository: mockRepository);
  });

  group('HomeController', () {
    test('should initialize with repository', () {
      expect(controller.repository, equals(mockRepository));

      controller.onClose();
    });

    test('should initialize with PagingController', () {
      expect(controller.pagingController, isNotNull);

      controller.onClose();
    });

    test('should properly dispose pagingController on close', () {
      expect(() => controller.onClose(), returnsNormally);
    });
  });
}
