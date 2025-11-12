import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:news_app/services/network/api_service.dart';

import 'app/app.dart';
import 'app/flavors.dart';


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

