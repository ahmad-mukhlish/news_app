import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/app/services/notification/notification_service.dart';

void main() {
  group('NotificationService', () {
    test('oneSignalId is null before init is called', () {
      final service = NotificationService();
      expect(service.oneSignalId, isNull);
    });
  });
}
