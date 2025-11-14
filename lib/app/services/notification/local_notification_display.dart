import 'dart:convert';
import 'dart:developer' as developer;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../config/app_config.dart';
import '../../data/notification/mappers/push_notification_mapper.dart';
import '../../domain/entities/push_notification.dart';
import '../../helper/common_methods/navigation_methods.dart';
import 'notification_repository_provider.dart';

FlutterLocalNotificationsPlugin _localNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

const AndroidNotificationChannel _defaultAndroidChannel =
    AndroidNotificationChannel(
      AppConfig.notificationChannelId,
      AppConfig.notificationChannelName,
      description: 'Used to deliver in-app alerts while the app is active.',
      importance: Importance.max,
    );

bool _localNotificationsInitialized = false;

@visibleForTesting
void setLocalNotificationsPluginForTesting(
  FlutterLocalNotificationsPlugin plugin, {
  bool initialized = false,
}) {
  _localNotificationsPlugin = plugin;
  _localNotificationsInitialized = initialized;
}

@visibleForTesting
void resetLocalNotificationsTestingState() {
  _localNotificationsPlugin = FlutterLocalNotificationsPlugin();
  _localNotificationsInitialized = false;
}

Future<void> _ensureLocalNotificationsInitialized() async {
  if (_localNotificationsInitialized) return;

  const initializationSettings = InitializationSettings(
    android: AndroidInitializationSettings(AppConfig.notificationIcon),
    iOS: DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    ),
  );

  await _localNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: handleLocalNotificationResponse,
    onDidReceiveBackgroundNotificationResponse:
        handleLocalNotificationBackgroundResponse,
  );

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

  final notificationEntity = PushNotificationMapper.fromRemoteMessage(message);
  final title = notificationEntity.title.isEmpty
      ? AppConfig.appName
      : notificationEntity.title;
  final body = notificationEntity.body;

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
        icon: notification?.android?.smallIcon ?? AppConfig.notificationIcon,
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
    payload: jsonEncode(_buildPayload(notificationEntity)),
  );
}

Map<String, dynamic> _buildPayload(PushNotification notification) {
  return {
    'notificationId': notification.id,
    'title': notification.title,
    'body': notification.body,
    'imageUrl': notification.imageUrl,
    'receivedAt': notification.receivedAt.toIso8601String(),
    if (notification.data != null) 'data': notification.data,
  };
}

Map<String, dynamic>? _decodePayload(String? payload) {
  if (payload == null || payload.isEmpty) return null;

  try {
    final decoded = jsonDecode(payload);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
  } catch (error, stackTrace) {
    developer.log(
      'Failed to decode local notification payload: $error',
      stackTrace: stackTrace,
    );
  }
  return null;
}

PushNotification _notificationFromPayload(Map<String, dynamic> payload) {
  final receivedAtRaw = payload['receivedAt']?.toString();
  final receivedAt = receivedAtRaw != null
      ? DateTime.tryParse(receivedAtRaw) ?? DateTime.now()
      : DateTime.now();

  return PushNotification(
    id: payload['notificationId']?.toString() ??
        DateTime.now().millisecondsSinceEpoch.toString(),
    title: payload['title']?.toString() ?? AppConfig.appName,
    body: payload['body']?.toString() ?? '',
    receivedAt: receivedAt,
    data: payload['data'] is Map<String, dynamic>
        ? Map<String, dynamic>.from(payload['data'] as Map)
        : null,
    imageUrl: payload['imageUrl']?.toString(),
  );
}

@visibleForTesting
Future<void> handleLocalNotificationResponse(
  NotificationResponse response,
) async {
  final payload = _decodePayload(response.payload);
  if (payload == null) return;

  final fallbackNotification = _notificationFromPayload(payload);

  try {
    final repository = await ensureNotificationRepositoryInitialized();
    final storedNotificationDto =
        await repository.getNotificationById(fallbackNotification.id);

    final resolvedNotification = storedNotificationDto != null
        ? PushNotificationMapper.toEntity(storedNotificationDto)
        : fallbackNotification;

    await goToNotificationDetail(
      notification: resolvedNotification,
      ensureNavigatorReady: true,
      onMarkAsRead: repository.markNotificationReadById,
    );
  } catch (error, stackTrace) {
    developer.log(
      'Failed to handle local notification response: $error',
      stackTrace: stackTrace,
    );
  }
}

@pragma('vm:entry-point')
Future<void> handleLocalNotificationBackgroundResponse(
  NotificationResponse response,
) {
  return handleLocalNotificationResponse(response);
}
