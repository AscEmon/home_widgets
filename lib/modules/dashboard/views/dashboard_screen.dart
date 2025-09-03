import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '/global/widget/global_appbar.dart';
import '/global/widget/global_text.dart';

import '/utils/styles/k_colors.dart';
import 'components/daily_hadith_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadDailyHadith();
  }

  void _loadDailyHadith() {
    context.read<DashboardBloc>().add(FetchDailyHadith());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlobalAppBar(title: "Daily Hadith"),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GlobalText(
              str: "Welcome to Daily Hadith App",
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: KColor.accent.color,
            ),
            SizedBox(height: 8.h),
            GlobalText(
              str: "Explore authentic Bukhari Hadith collection",
              fontSize: 14,
              color: KColor.grey.color,
            ),
            SizedBox(height: 24.h),
            const DailyHadithCard(),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }
}
