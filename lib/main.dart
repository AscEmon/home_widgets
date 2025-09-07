import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_widgets/constant/app_url.dart';
import 'package:home_widgets/utils/enum.dart';
import 'package:home_widgets/utils/extension.dart';
import 'package:home_widgets/utils/service/background_fetch_service.dart';
import 'package:home_widgets/utils/service/widget_auto_update_service.dart';
import 'package:home_widgets/utils/styles/k_colors.dart';

import 'data_provider/pref_helper.dart';
import 'modules/dashboard/views/dashboard_screen.dart';
import 'utils/app_routes.dart';
import 'utils/app_version.dart';
import 'utils/bloc_reinitalizer.dart';
import 'utils/mixin/bloc_provider_mixin.dart';
import 'utils/navigation.dart';
import 'utils/network_connection.dart';
import 'utils/service/hadith_widget_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initServices();
  //Set Potraite Mode only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize home widget
  await HadithWidgetProvider.initializeWidget();
  runApp(const MyApp());
}

/// Make sure you always init shared pref first. It has token and token is need
/// to make API call
initServices() async {
  const mode = String.fromEnvironment('mode', defaultValue: 'DEV');
  AppUrlExtention.setUrl(mode == "DEV" ? UrlLink.isDev : UrlLink.isLive);
  await PrefHelper.init();
  await AppVersion.getVersion();
  await NetworkConnection.instance.internetAvailable();
  
  // Initialize background fetch service for widget updates
  await BackgroundFetchService.instance.initializeBackgroundService();
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp>
    with BlocProviderMixin, WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkWidgetLaunch();
    _startWidgetUpdateServices();
  }
  
  /// Start the widget update services
  Future<void> _startWidgetUpdateServices() async {
    try {
      // Start the background service for widget updates
      await BackgroundFetchService.instance.startBackgroundService();
      
      // Start the auto-update service for widget updates when app is active
      WidgetAutoUpdateService.instance.startAutoUpdate();
      
      'Widget update services started successfully'.log();
    } catch (e) {
      'Error starting widget update services: $e'.log();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    'App lifecycle state changed to: $state'.log();
    
    if (state == AppLifecycleState.resumed) {
      // App is visible and in the foreground
      _checkWidgetLaunch();
      
      // Restart the auto-update service when app is resumed
      WidgetAutoUpdateService.instance.startAutoUpdate();
      'Auto-update service restarted on app resume'.log();
      
    } else if (state == AppLifecycleState.paused) {
      // App is not visible, but running in the background
      // Keep background service running, but stop the foreground timer
      WidgetAutoUpdateService.instance.stopAutoUpdate();
      'Auto-update service paused on app pause'.log();
      
    } else if (state == AppLifecycleState.detached) {
      // App is in the process of being terminated
      // Ensure background service is still running
      BackgroundFetchService.instance.startBackgroundService();
      'Ensuring background service is running before app detach'.log();
    }
  }

  Future<void> _checkWidgetLaunch() async {
    try {
      "_checkWidgetLaunch".log();
      // Check if app was launched from widget
      Navigation.pushAndRemoveUntil(
        Navigation.key.currentContext!,
        appRoutes: AppRoutes.dashboard,
      );
    } catch (e) {
      'Error checking widget launch: $e'.log();
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChannels.textInput.invokeMethod('TextInput.hide');

    return ScreenUtilInit(
      // Change the height and Width based on design
      designSize: const Size(960, 1440),
      minTextAdapt: true,
      builder: (ctx, child) {
        return ScreenUtilInit(
          //Change the height and Width based on design
          designSize: const Size(360, 800),
          minTextAdapt: true,
          builder: (ctx, child) {
            return BlocReinitializer(
              child: MaterialApp(
                title: 'Daily Hadith',
                navigatorKey: Navigation.key,
                debugShowCheckedModeBanner: false,
                locale:
                    (PrefHelper.getLanguage() == 1)
                        ? const Locale('en', 'US')
                        : const Locale('bn', 'BD'),
                theme: ThemeData(
                  progressIndicatorTheme: ProgressIndicatorThemeData(
                    color: KColor.secondary.color,
                  ),
                  textTheme: GoogleFonts.poppinsTextTheme(),
                  primaryColor: KColor.primary.color,
                  visualDensity: VisualDensity.adaptivePlatformDensity,
                  colorScheme: ThemeData().colorScheme.copyWith(
                    secondary: KColor.secondary.color,
                  ),
                  primarySwatch: KColor.primary.color as MaterialColor,
                ),
                home: child,
              ),
            );
          },
          child: const DashboardScreen(),
        );
      },
    );
  }
}
