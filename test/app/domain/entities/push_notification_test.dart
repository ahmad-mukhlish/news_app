import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/app/domain/entities/push_notification.dart';

void main() {
  group('PushNotification', () {
    test('defaults to unread state', () {
      final notification = PushNotification(
        id: 'notif-1',
        title: 'Hello',
        body: 'World',
        receivedAt: DateTime(2024, 1, 1),
      );

      expect(notification.isRead, isFalse);
    });

    test('copyWith overrides provided fields', () {
      final original = PushNotification(
        id: 'notif-1',
        title: 'Original',
        body: 'Body',
        receivedAt: DateTime(2024, 1, 1, 10),
        data: const {'foo': 'bar'},
        imageUrl: 'https://example.com/original.png',
      );

      final updated = original.copyWith(
        title: 'Updated title',
        isRead: true,
        imageUrl: 'https://example.com/new.png',
      );

      expect(updated.id, 'notif-1');
      expect(updated.title, 'Updated title');
      expect(updated.body, 'Body');
      expect(updated.receivedAt, original.receivedAt);
      expect(updated.data, const {'foo': 'bar'});
      expect(updated.imageUrl, 'https://example.com/new.png');
      expect(updated.isRead, isTrue);
    });

    test('copyWith retains original values when nothing provided', () {
      final original = PushNotification(
        id: 'notif-2',
        title: 'Title',
        body: 'Body',
        receivedAt: DateTime(2024, 2, 1),
        data: const {'baz': 'qux'},
        imageUrl: 'https://example.com/img.png',
        isRead: true,
      );

      final copy = original.copyWith();

      expect(copy.id, original.id);
      expect(copy.title, original.title);
      expect(copy.body, original.body);
      expect(copy.receivedAt, original.receivedAt);
      expect(copy.data, original.data);
      expect(copy.imageUrl, original.imageUrl);
      expect(copy.isRead, original.isRead);
    });
  });
}
