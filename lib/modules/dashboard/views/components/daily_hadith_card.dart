import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '/global/widget/global_text.dart';
import '/modules/hadith/bloc/hadith_bloc.dart';
import '/modules/hadith/bloc/hadith_event.dart';
import '/modules/hadith/bloc/hadith_state.dart';
import '/modules/hadith/model/hadith_model.dart';
import '/modules/hadith/model/hadith_widget_model.dart';
import '/modules/hadith/service/hadith_widget_provider.dart';
import '/utils/enum.dart';
import '/utils/styles/k_colors.dart';

class DailyHadithCard extends StatelessWidget {
  const DailyHadithCard({super.key});

  // Update the widget with the daily hadith
  void _updateWidget(HadithModel hadith) async {
    try {
      // Create widget model from hadith model
      final widgetModel = HadithWidgetModel(
        id: hadith.id,
        narrator: hadith.narrator,
        text: hadith.text,
        reference: hadith.reference,
        updatedAt: DateTime.now(),
      );

      // Update the widget
      await HadithWidgetProvider.updateDailyHadithWidget(widgetModel);
    } catch (e) {
      // Silently handle errors - widget update should not affect app functionality
      debugPrint('Failed to update widget: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: KColor.fill.color,
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
              Icon(Icons.format_quote, color: KColor.primary.color, size: 24.w),
              SizedBox(width: 8.w),
              GlobalText(
                str: "Daily Hadith",
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: KColor.primary.color,
              ),
            ],
          ),
          SizedBox(height: 16.h),
          BlocBuilder<HadithBloc, HadithState>(
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
                          context.read<HadithBloc>().add(
                            const FetchDailyHadith(),
                          );
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
                // Update the widget with the daily hadith
                _updateWidget(state.dailyHadith!);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GlobalText(
                      str: state.dailyHadith!.narrator,
                      fontSize: 14,
                      color: KColor.secondary.color,
                      fontWeight: FontWeight.w500,
                    ),
                    SizedBox(height: 8.h),
                    GlobalText(
                      str:
                          state.dailyHadith!.text.length > 150
                              ? "${state.dailyHadith!.text.substring(0, 150)}..."
                              : state.dailyHadith!.text,
                      fontSize: 14,
                      color: KColor.black.color,
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8.h),
                    GlobalText(
                      str: state.dailyHadith!.reference,
                      fontSize: 12,
                      color: KColor.grey.color,
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
