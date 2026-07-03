import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/config/app.dart';
import 'app/config/flavors.dart';
import 'app/services/network/api_service.dart';
import 'app/services/analytics_service.dart';
import 'app/services/posthog_service.dart';
import 'app/services/notification/notification_service.dart';
import 'app/services/storage/local_storage_service.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setFlavorFromEnvironment();

  await initServicesAndDependencies();

  runApp(const App());
}

Future<void> initServicesAndDependencies() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // PostHog spike: register PostHog before AnalyticsService so it is ready to
  // receive the fanned out events (see AnalyticsService.logEventIfReady).
  await Get.putAsync<PostHogService>(
    () => PostHogService().init(),
    permanent: true,
  );

  await Get.putAsync<AnalyticsService>(
    () => AnalyticsService().init(),
    permanent: true,
  );

  await Get.putAsync<ApiService>(() => ApiService().init(), permanent: true);

  final prefs = await SharedPreferences.getInstance();
  Get.put<LocalStorageService>(
    LocalStorageService(prefs: prefs),
    permanent: true,
  );

  await Get.putAsync<NotificationService>(
    () => NotificationService().init(),
    permanent: true,
  );
}

void setFlavorFromEnvironment() {
  const flavorString = String.fromEnvironment('FLAVOR', defaultValue: 'prod');
  F.updateFlavor(flavorString);
}
