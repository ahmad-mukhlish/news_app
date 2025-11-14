import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:news_app/app/helper/common_methods/date_time_methods.dart';

void main() {
  group('formatTimeAgo', () {
    test('returns "Just now" when less than a minute has passed', () {
      final recent = DateTime.now().subtract(const Duration(seconds: 45));

      expect(formatTimeAgo(recent), 'Just now');
    });

    test('returns minutes when under an hour', () {
      final dateTime = DateTime.now().subtract(const Duration(minutes: 5));

      expect(formatTimeAgo(dateTime), '5m ago');
    });

    test('returns hours when under a day', () {
      final dateTime = DateTime.now().subtract(const Duration(hours: 3));

      expect(formatTimeAgo(dateTime), '3h ago');
    });

    test('returns days when under a week', () {
      final dateTime = DateTime.now().subtract(const Duration(days: 2));

      expect(formatTimeAgo(dateTime), '2d ago');
    });

    test('returns formatted date when older than a week', () {
      final dateTime = DateTime.now().subtract(const Duration(days: 30));
      final formatted = DateFormat('MMM d, yyyy').format(dateTime);

      expect(formatTimeAgo(dateTime), formatted);
    });
  });
}
