import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:home_widgets/utils/extension.dart';
import 'package:home_widgets/utils/service/widget_auto_update_service.dart';

/// Service to handle background fetch for widget updates
class BackgroundFetchService {
  static BackgroundFetchService? _instance;
  static BackgroundFetchService get instance =>
      _instance ??= BackgroundFetchService._();

  BackgroundFetchService._();

  /// Initialize the background fetch service
  Future<void> initializeBackgroundService() async {
    try {
      'Initializing background fetch service...'.log();
      final service = FlutterBackgroundService();

      await service.configure(
        androidConfiguration: AndroidConfiguration(
          onStart: onStartService,
          autoStart: true,
          isForegroundMode: false,
          notificationChannelId: 'daily_hadith_widget_updates',
          initialNotificationTitle: 'Daily Hadith Widget',
          initialNotificationContent: 'Updating widget in background',
          foregroundServiceNotificationId: 888,
        ),
        iosConfiguration: IosConfiguration(
          autoStart: true,
          onForeground: onStartService,
          onBackground: onIosBackground,
        ),
      );

      'Background fetch service initialized successfully'.log();
    } catch (e) {
      'Error initializing background fetch service: $e'.log();
    }
  }

  /// Start the background service
  Future<bool> startBackgroundService() async {
    try {
      'Starting background service...'.log();
      final service = FlutterBackgroundService();
      final result = await service.startService();
      'Background service started: $result'.log();
      return result;
    } catch (e) {
      'Error starting background service: $e'.log();
      return false;
    }
  }

  /// Check if the background service is running
  Future<bool> isBackgroundServiceRunning() async {
    try {
      final service = FlutterBackgroundService();
      return await service.isRunning();
    } catch (e) {
      'Error checking background service status: $e'.log();
      return false;
    }
  }

  /// Stop the background service
  Future<bool> stopBackgroundService() async {
    try {
      'Stopping background service...'.log();
      final service = FlutterBackgroundService();
      service.invoke('stopService');
      'Background service stop requested'.log();
      return true;
    } catch (e) {
      'Error stopping background service: $e'.log();
      return false;
    }
  }
}

/// Background task handler for iOS
@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  // Update widget every 5 minutes
  await WidgetAutoUpdateService.instance.forceUpdate();

  return true;
}

/// Background task handler for Android and iOS foreground
@pragma('vm:entry-point')
void onStartService(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  // Update widget immediately when service starts
  await WidgetAutoUpdateService.instance.forceUpdate();
  'Initial widget update completed in background service'.log();

  // Schedule periodic updates every 5 minutes
  Timer.periodic(const Duration(minutes: 5), (_) async {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        // Update notification if in foreground
        service.setForegroundNotificationInfo(
          title: "Daily Hadith Widget",
          content: "Updating widget: ${DateTime.now()}",
        );
      }
    }

    // Perform the widget update
    await WidgetAutoUpdateService.instance.forceUpdate();
    'Background widget update completed at ${DateTime.now()}'.log();

    // Send data to app if it's running
    service.invoke('update', {
      'time': DateTime.now().toIso8601String(),
      'status': 'Widget updated in background',
    });
  });
}
