import 'package:chucker_flutter/chucker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import '../helper/extensions/color_extension.dart';
import '../routes/app_pages.dart';
import 'app_config.dart';
import 'flavors.dart';

class App extends StatelessWidget {
  const App({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: F.isDevMode,
      title: F.title(AppConfig.appName),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColor.fromConfig(AppConfig.primaryColor),
          secondary: AppColor.fromConfig(AppConfig.secondaryColor),
        ),
        useMaterial3: true,
      ),
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
      navigatorObservers: [ChuckerFlutter.navigatorObserver],
    );
  }
}