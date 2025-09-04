import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:home_widgets/utils/service/widget_auto_update_service.dart';

import '/global/widget/global_text.dart';
import '/modules/dashboard/bloc/dashboard_bloc.dart';
import '/modules/dashboard/bloc/dashboard_event.dart';
import '/modules/dashboard/bloc/dashboard_state.dart';
import '/utils/enum.dart';
import '/utils/styles/k_colors.dart';

class DailyHadithCard extends StatefulWidget {
  const DailyHadithCard({super.key});

  @override
  State<DailyHadithCard> createState() => _DailyHadithCardState();
}

class _DailyHadithCardState extends State<DailyHadithCard> {
  @override
  void initState() {
    super.initState();
    // Start the auto-update service when this widget is created
    WidgetAutoUpdateService.instance.startAutoUpdate();
  }

  @override
  void dispose() {
    // Stop the auto-update service when this widget is disposed
    WidgetAutoUpdateService.instance.stopAutoUpdate();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: KColor.accent.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.format_quote, color: KColor.accent.color, size: 24.w),
              SizedBox(width: 8.w),
              GlobalText(
                str: "Daily Hadith",
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: KColor.accent.color,
              ),
            ],
          ),
          SizedBox(height: 16.h),
          BlocBuilder<DashboardBloc, DashboardState>(
            buildWhen:
                (previous, current) =>
                    previous.dailyHadithStatus != current.dailyHadithStatus ||
                    previous.dailyHadith != current.dailyHadith,
            builder: (context, state) {
              if (state.dailyHadithStatus == AppStatus.loading) {
                return Center(
                  child: CircularProgressIndicator(color: KColor.primary.color),
                );
              } else if (state.dailyHadithStatus == AppStatus.error) {
                return Center(
                  child: Column(
                    children: [
                      GlobalText(
                        str: "Failed to load daily hadith",
                        fontSize: 14,
                        color: KColor.red.color,
                      ),
                      SizedBox(height: 8.h),
                      ElevatedButton(
                        onPressed: () {
                          context.read<DashboardBloc>().add(FetchDailyHadith());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: KColor.primary.color,
                          foregroundColor: KColor.white.color,
                        ),
                        child: const GlobalText(
                          str: "Retry",
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                );
              } else if (state.dailyHadith != null) {
                // // Update the widget with the daily hadith
                // _updateWidget(state.dailyHadith!);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GlobalText(
                          str: state.dailyHadith!.narrator,
                          fontSize: 14,
                          color: KColor.accent.color,
                          fontWeight: FontWeight.w900,
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    GlobalText(
                      str: state.dailyHadith!.text,
                      fontSize: 14,
                      color: KColor.black.color,
                      fontWeight: FontWeight.w400,
                    ),
                    SizedBox(height: 8.h),
                    GlobalText(
                      str: state.dailyHadith!.reference,
                      fontSize: 12,
                      color: KColor.grey.color,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.italic,
                    ),
                  ],
                );
              } else {
                return Center(
                  child: GlobalText(
                    str: "No daily hadith available",
                    fontSize: 14,
                    color: KColor.grey.color,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
