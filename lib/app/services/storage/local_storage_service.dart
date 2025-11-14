import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  final SharedPreferences _prefs;

  static const String _kNotificationsKey = 'notifications';

  LocalStorageService({required SharedPreferences prefs}) : _prefs = prefs;

  Future<void> saveNotificationsJson(String json) async {
    await _prefs.setString(_kNotificationsKey, json);
  }

  Future<String?> getNotificationsJson() async {
    return _prefs.getString(_kNotificationsKey);
  }
}
