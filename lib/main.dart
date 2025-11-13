import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/config/app.dart';
import 'app/config/flavors.dart';
import 'app/services/network/api_service.dart';
import 'app/services/notification/notification_service.dart';
import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setFlavorFromEnvironment();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  initServices();

  runApp(const App());
}

void initServices() {
  Get.putAsync<ApiService>(() => ApiService().init(), permanent: true);
  Get.putAsync<NotificationService>(() => NotificationService().init(), permanent: true);
}

void setFlavorFromEnvironment() {
  const flavorString = String.fromEnvironment('FLAVOR', defaultValue: 'prod');
  F.updateFlavor(flavorString);
}

