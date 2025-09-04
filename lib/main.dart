import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_widget/home_widget.dart';
import 'package:home_widgets/constant/app_url.dart';
import 'package:home_widgets/utils/enum.dart';
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
import 'utils/service/hadith_widget_service.dart';

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

  // Setup widget callbacks
  HomeWidget.registerInteractivityCallback(backgroundCallback);

  // Check if app was launched from widget
  final launchedFromWidget = await HomeWidget.initiallyLaunchedFromHomeWidget();
  if (launchedFromWidget == true) {
    print('App was launched from widget');
    Navigation.pushAndRemoveUntil(
      Navigation.key.currentContext!,
      appRoutes: AppRoutes.dashboard,
    );
  }

  runApp(const MyApp());
}

// Background callback for widget interactions
Future<void> backgroundCallback(Uri? uri) async {
  print('Background callback triggered with URI: $uri');
  if (uri?.host == 'hadith_widget_clicked') {
    // Handle widget click in background
    print('Hadith widget was clicked!');

    // You can add additional handling here
  }
}

/// Make sure you always init shared pref first. It has token and token is need
/// to make API call
initServices() async {
  const mode = String.fromEnvironment('mode', defaultValue: 'DEV');
  AppUrlExtention.setUrl(mode == "DEV" ? UrlLink.isDev : UrlLink.isLive);
  await PrefHelper.init();
  await AppVersion.getVersion();
  await NetworkConnection.instance.internetAvailable();

  // Check if we need to update the daily hadith for widget
  final shouldUpdate = await HadithWidgetService.shouldUpdateDailyHadith();
  if (shouldUpdate) {
    // We'll fetch a new hadith when the app starts in the dashboard screen
  }
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
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkWidgetLaunch();
    }
  }

  Future<void> _checkWidgetLaunch() async {
    try {
      // Check if app was launched from widget
      Navigation.pushAndRemoveUntil(
        Navigation.key.currentContext!,
        appRoutes: AppRoutes.dashboard,
      );
    } catch (e) {
      print('Error checking widget launch: $e');
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

                //localization
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
