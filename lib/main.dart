import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app/config/app.dart';
import 'app/config/flavors.dart';
import 'app/services/network/api_service.dart';
import 'app/services/notification/notification_service.dart';
import 'app/services/storage/local_storage_service.dart';
import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setFlavorFromEnvironment();
  await Hive.initFlutter();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initServices();

  runApp(const App());
}

Future<void> initServices() async {
  await Get.putAsync<ApiService>(() => ApiService().init(), permanent: true);
  await Get.putAsync<LocalStorageService>(
    () async {
      final box = await Hive.openBox(LocalStorageService.kBoxName);
      return LocalStorageService(box: box);
    },
    permanent: true,
  );

  await Get.putAsync<NotificationService>(() => NotificationService().init(), permanent: true);
}

void setFlavorFromEnvironment() {
  const flavorString = String.fromEnvironment('FLAVOR', defaultValue: 'prod');
  F.updateFlavor(flavorString);
}

