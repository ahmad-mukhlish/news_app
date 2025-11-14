import 'package:hive_flutter/hive_flutter.dart';

import '../../data/notification/dto/push_notification_dto.dart';

class LocalStorageService {
  late final Box _box;

  static const String kBoxName = 'news_app_storage';
  static const String _kNotificationsKey = 'notifications';

  LocalStorageService({required Box box}) : _box = box;

  Future<void> saveNotifications(List<PushNotificationDto> notifications) async {
    final jsonList = notifications.map((n) => n.toJson()).toList();
    await _box.put(_kNotificationsKey, jsonList);
  }

  List<PushNotificationDto> getNotifications() {
    final jsonList = _box.get(_kNotificationsKey, defaultValue: <dynamic>[]) as List<dynamic>;
    return jsonList
        .map((json) => PushNotificationDto.fromJson(Map<String, dynamic>.from(json as Map)))
        .toList();
  }
}
