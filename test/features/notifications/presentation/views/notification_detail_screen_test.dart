import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/app/domain/entities/push_notification.dart';
import 'package:news_app/features/notifications/presentation/views/screen/notification_detail_screen.dart';

void main() {
  group('NotificationDetailScreen', () {
    testWidgets('renders title, body and timestamp with semantics labels',
        (WidgetTester tester) async {
      final notification = _buildNotification();

      await _pumpScreen(tester, notification: notification);

      expect(find.text('Notification Detail'), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              widget.properties.label == 'Notif title',
        ),
        findsOneWidget,
      );
      expect(find.text(notification.title), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Semantics && widget.properties.label == 'Notif body',
        ),
        findsOneWidget,
      );
      expect(find.text(notification.body), findsOneWidget);
      expect(find.text('Jan 1, 2024'), findsOneWidget);
      expect(find.text('Additional Data'), findsNothing);
    });

    testWidgets('shows additional data entries when present',
        (WidgetTester tester) async {
      final notification = _buildNotification(
        data: const {'newsId': '123', 'category': 'World'},
      );

      await _pumpScreen(tester, notification: notification);

      expect(find.text('Additional Data'), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is RichText && widget.text.toPlainText() == 'newsId: 123',
        ),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate(
          (widget) => widget is RichText &&
              widget.text.toPlainText() == 'category: World',
        ),
        findsOneWidget,
      );
    });

  });
}

Future<void> _pumpScreen(
  WidgetTester tester, {
  required PushNotification notification,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: NotificationDetailScreen(
        notification: notification,
        formattedDate: 'Jan 1, 2024',
      ),
    ),
  );
}

PushNotification _buildNotification({
  Map<String, dynamic>? data,
  String? imageUrl,
}) {
  return PushNotification(
    id: 'notif-1',
    title: 'Breaking News',
    body: 'Read the latest update now.',
    receivedAt: DateTime(2024, 1, 1, 12),
    data: data,
    imageUrl: imageUrl,
  );
}
