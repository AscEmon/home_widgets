import 'package:flutter/material.dart';
import '../modules/dashboard/views/dashboard_screen.dart';
import '../modules/hadith/views/hadith_list_screen.dart';
import '../modules/hadith/views/hadith_detail_screen.dart';


enum AppRoutes {
  dashboard,
  hadithList,
  hadithDetail,
}

extension AppRoutesExtention on AppRoutes {
  Widget buildWidget<T extends Object>({T? arguments}) {
    switch (this) {
      case AppRoutes.dashboard:
        return const DashboardScreen();
      case AppRoutes.hadithList:
        return const HadithListScreen();
      case AppRoutes.hadithDetail:
        if (arguments != null && arguments is int) {
          return HadithDetailScreen(hadithId: arguments);
        }
        return const HadithListScreen();
    }
  }
}


