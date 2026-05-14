import 'dart:developer' as developer;

import 'package:get/get.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import 'notification_lifecycle_callbacks.dart';

class NotificationService extends GetxService {
  static NotificationService get to => Get.find<NotificationService>();

  String? _oneSignalId;
  String? get oneSignalId => _oneSignalId;

  Future<NotificationService> init() async {
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
    OneSignal.initialize('YOUR_ONESIGNAL_APP_ID');
    await OneSignal.Notifications.requestPermission(false);

    NotificationLifecycleCallbacks.register();

    _oneSignalId = await OneSignal.User.getOnesignalId();
    OneSignal.User.pushSubscription.addObserver((state) {
      _oneSignalId = state.current.id;
    });

    developer.log('NotificationService initialized. OneSignal ID: $_oneSignalId');
    return this;
  }
}
