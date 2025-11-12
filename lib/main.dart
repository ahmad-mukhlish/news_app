import 'package:chucker_flutter/chucker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:news_app/routes/app_pages.dart';

import 'app/flavors.dart';
import 'bindings/app_binding.dart';
import 'config/app_config.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize flavor from dart-define
  const flavorString = String.fromEnvironment('FLAVOR', defaultValue: 'prod');
  F.updateFlavor(flavorString);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: F.isDevMode,
      title: F.title(AppConfig.appName),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(int.parse(AppConfig.primaryColorHex)),
        ),
        useMaterial3: true,
      ),
      initialBinding: AppBinding(),
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
      navigatorObservers: [ChuckerFlutter.navigatorObserver],
    );
  }
}