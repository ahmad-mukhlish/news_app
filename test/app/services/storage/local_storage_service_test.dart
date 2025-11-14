import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/app/services/storage/local_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const sampleJson = '[{"id":"1"}]';

  Future<LocalStorageService> buildService() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    return LocalStorageService(prefs: prefs);
  }

  test('saveNotificationsJson persists payload to shared preferences', () async {
    final service = await buildService();

    await service.saveNotificationsJson(sampleJson);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('notifications'), sampleJson);
  });

  test('getNotificationsJson returns stored value', () async {
    final service = await buildService();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('notifications', sampleJson);

    final json = await service.getNotificationsJson();

    expect(json, sampleJson);
  });

  test('getNotificationsJson returns null when no data stored', () async {
    final service = await buildService();

    final json = await service.getNotificationsJson();

    expect(json, isNull);
  });
}
