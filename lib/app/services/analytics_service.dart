import 'dart:developer' as developer;

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class AnalyticsService extends GetxService {
  AnalyticsService({FirebaseAnalytics? analytics})
    : _analytics = analytics ?? FirebaseAnalytics.instance,
      observer = FirebaseAnalyticsObserver(
        analytics: analytics ?? FirebaseAnalytics.instance,
      );

  final FirebaseAnalytics _analytics;
  final NavigatorObserver observer;

  static AnalyticsService get to => Get.find<AnalyticsService>();

  static List<NavigatorObserver> get navigatorObservers {
    if (!Get.isRegistered<AnalyticsService>()) return const [];

    return [to.observer];
  }

  static Future<void> logEventIfReady({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    if (!Get.isRegistered<AnalyticsService>()) return;

    await to.logEvent(name: name, parameters: parameters);
  }

  Future<AnalyticsService> init() async {
    await _analytics.setAnalyticsCollectionEnabled(true);
    await _analytics.logAppOpen();
    await logEvent(name: 'news_app_spike_started');

    developer.log('AnalyticsService initialized successfully');

    return this;
  }

  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    try {
      await _analytics.logEvent(name: name, parameters: parameters);
      developer.log('Analytics event logged: $name');
    } catch (error, stackTrace) {
      developer.log(
        'Failed to log Analytics event: $name',
        error: error,
        stackTrace: stackTrace,
        name: runtimeType.toString(),
      );
    }
  }
}
