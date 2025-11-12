import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:news_app/features/headline/data/repositories/headline_repository.dart';
import 'package:news_app/features/headline/presentation/get/headline_controller.dart';

import 'headline_controller_test.mocks.dart';

@GenerateMocks([HeadlineRepository])
void main() {
  late HeadlineController controller;
  late MockHeadlineRepository mockRepository;

  setUp(() {
    mockRepository = MockHeadlineRepository();
    controller = HeadlineController(repository: mockRepository);
  });

  group('HeadlineController', () {
    test('should initialize with repository', () {
      // Assert
      expect(controller.repository, equals(mockRepository));

      // Cleanup
      controller.onClose();
    });

    test('should initialize with PagingController', () {
      // Assert
      expect(controller.pagingController, isNotNull);

      // Cleanup
      controller.onClose();
    });

    test('should properly dispose pagingController on close', () {
      // Act & Assert - should not throw exception
      expect(() => controller.onClose(), returnsNormally);
    });
  });
}
