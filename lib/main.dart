import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/config/app.dart';
import 'app/config/flavors.dart';
import 'app/services/network/api_service.dart';
import 'app/services/notification/notification_service.dart';
import 'app/services/storage/local_storage_service.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setFlavorFromEnvironment();

  await initServicesAndDependencies();

  runApp(const App());
}

Future<void> initServicesAndDependencies() async {
  await Get.putAsync<ApiService>(() => ApiService().init(), permanent: true);

  final prefs = await SharedPreferences.getInstance();
  Get.put<LocalStorageService>(
    LocalStorageService(prefs: prefs),
    permanent: true,
  );

  await Get.putAsync<NotificationService>(() => NotificationService().init(), permanent: true);
}

void setFlavorFromEnvironment() {
  const flavorString = String.fromEnvironment('FLAVOR', defaultValue: 'prod');
  F.updateFlavor(flavorString);
}
