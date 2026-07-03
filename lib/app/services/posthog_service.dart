import 'dart:developer' as developer;

import 'package:get/get.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

/// PostHog spike harness.
///
/// This service mirrors [AnalyticsService] so the same events can be sent to
/// PostHog and Firebase at the same time. The goal of the spike is a side by
/// side read: Firebase reports counts the next day, PostHog reports them the
/// same day, so dual logging lets the two be compared on identical traffic.
///
/// This is throwaway spike code, not production wiring.
class PostHogService extends GetxService {
  /// PostHog project API key. Copy it from the PostHog web app under
  /// Settings, then Project, then Project API Key. It is safe to paste here
  /// for a throwaway spike project; delete the project when the spike is done.
  static const String _apiKey = 'phc_ANytvAdTMJr3mdAnbwcJuk4B2Es88mdJa6ewXNmGD4yh';

  /// PostHog Cloud host. Use the US host below, or
  /// 'https://eu.i.posthog.com' if the project was created on the EU cloud.
  /// This must match the region shown when the project was created.
  static const String _host = 'https://us.i.posthog.com';

  static PostHogService get to => Get.find<PostHogService>();

  /// Fan an event out to PostHog only when the service is registered, so a
  /// call site never crashes if PostHog failed to initialize. Mirrors
  /// [AnalyticsService.logEventIfReady].
  static Future<void> captureIfReady({
    required String name,
    Map<String, Object>? properties,
  }) async {
    if (!Get.isRegistered<PostHogService>()) return;

    await to.capture(name: name, properties: properties);
  }

  Future<PostHogService> init() async {
    final config = PostHogConfig(_apiKey);
    // Send every event immediately instead of batching: a spike wants same
    // minute reads in the PostHog activity feed, not hourly flushes.
    config.flushAt = 1;
    config.host = _host;
    // Print the outgoing network calls so it is visible on the device console
    // that events are actually leaving.
    config.debug = true;

    await Posthog().setup(config);
    await capture(name: 'news_app_posthog_spike_started');

    developer.log('PostHogService initialized successfully');

    return this;
  }

  Future<void> capture({
    required String name,
    Map<String, Object>? properties,
  }) async {
    try {
      await Posthog().capture(eventName: name, properties: properties);
      developer.log('PostHog event captured: $name');
    } catch (error, stackTrace) {
      developer.log(
        'Failed to capture PostHog event: $name',
        error: error,
        stackTrace: stackTrace,
        name: runtimeType.toString(),
      );
    }
  }
}
