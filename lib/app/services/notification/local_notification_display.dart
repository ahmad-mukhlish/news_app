import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

const AndroidNotificationChannel _defaultAndroidChannel =
    AndroidNotificationChannel(
      'news_app_high_importance_channel',
      'News App Alerts',
      description: 'Used to deliver in-app alerts while the app is active.',
      importance: Importance.max,
    );

bool _localNotificationsInitialized = false;

Future<void> _ensureLocalNotificationsInitialized() async {
  if (_localNotificationsInitialized) return;

  const initializationSettings = InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    iOS: DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    ),
  );

  await _localNotificationsPlugin.initialize(initializationSettings);

  final androidImplementation = _localNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();
  await androidImplementation?.createNotificationChannel(
    _defaultAndroidChannel,
  );

  _localNotificationsInitialized = true;
}

Future<void> displayLocalNotification(
  RemoteMessage message, {
  bool force = false,
}) async {
  final notification = message.notification;
  final hasNotificationPayload = notification != null;

  // When not forced, let the system notification handle background display.
  if (!force && hasNotificationPayload) return;

  final dataTitle = message.data['title']?.toString();
  final dataBody = message.data['body']?.toString();

  final title = notification?.title ?? dataTitle ?? 'News App';
  final body = notification?.body ?? dataBody ?? '';

  if (title.isEmpty && body.isEmpty) return;

  await _ensureLocalNotificationsInitialized();

  await _localNotificationsPlugin.show(
    message.hashCode,
    title,
    body,
    NotificationDetails(
      android: AndroidNotificationDetails(
        _defaultAndroidChannel.id,
        _defaultAndroidChannel.name,
        channelDescription: _defaultAndroidChannel.description,
        icon: notification?.android?.smallIcon ?? '@mipmap/ic_launcher',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'News update',
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    ),
    payload: message.data.isEmpty ? null : jsonEncode(message.data),
  );
}
