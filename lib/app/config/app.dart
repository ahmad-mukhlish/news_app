import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import '../../features/main/presentation/get/main_binding.dart';
import '../../features/main/presentation/views/screen/main_screen.dart';
import '../helper/extensions/color_extension.dart';
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
      home: const MainScreen(),
      initialBinding: MainBinding(),
    );
  }
}
