import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/config/app.dart';
import 'app/config/flavors.dart';
import 'app/services/network/api_service.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setFlavorFromEnvironment();
  initServices();
  runApp(const App());
}

void initServices() {
  Get.putAsync<ApiService>(() => ApiService().init(), permanent: true);
}

void setFlavorFromEnvironment() {
  const flavorString = String.fromEnvironment('FLAVOR', defaultValue: 'prod');
  F.updateFlavor(flavorString);
}

