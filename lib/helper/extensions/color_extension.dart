import 'package:flutter/material.dart';

extension AppColor on Color {
  static Color fromConfig(String hexString) {
    return Color(int.parse(hexString));
  }
}