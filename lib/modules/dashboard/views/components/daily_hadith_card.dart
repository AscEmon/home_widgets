import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:home_widgets/utils/service/hadith_widget_service.dart';

import '/global/widget/global_text.dart';
import '/modules/dashboard/bloc/dashboard_bloc.dart';
import '/modules/dashboard/bloc/dashboard_event.dart';
import '/modules/dashboard/bloc/dashboard_state.dart';
import '/utils/enum.dart';
import '/utils/styles/k_colors.dart';
import '../../model/hadith_model.dart';

class DailyHadithCard extends StatelessWidget {
  const DailyHadithCard({super.key});

  // Update the widget with the daily hadith
  void _updateWidget(HadithModel hadith, [BuildContext? contextForSnackbar]) async {
    try {
      // Create widget model from hadith model
      final widgetModel = HadithModel(
        id: hadith.id,
        narrator: hadith.narrator,
        text: hadith.text,
        reference: hadith.reference,
        chapter: hadith.chapter,
        bookNumber: hadith.bookNumber,
        hadithNumber: hadith.hadithNumber,
        date: DateTime.now(),
        title: hadith.title,
      );

      // Update the widget
      final result = await HadithWidgetService.saveDailyHadithForWidget(widgetModel);
      
      // Show success message if context is provided
      if (contextForSnackbar != null) {
        ScaffoldMessenger.of(contextForSnackbar).showSnackBar(
          SnackBar(
            content: Text(result ? 'Widget updated successfully' : 'Widget update failed'),
            duration: const Duration(seconds: 2),
          ),
        );
        
        // Verify data was saved by reading it back
        _verifyWidgetData(contextForSnackbar);
      }
    } catch (e) {
      // Show error if context is provided, otherwise silently log
      debugPrint('Failed to update widget: $e');
      if (contextForSnackbar != null) {
        ScaffoldMessenger.of(contextForSnackbar).showSnackBar(
          SnackBar(
            content: Text('Failed to update widget: $e'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  // Save test data to widget for debugging
  void _saveTestDataToWidget(BuildContext context) async {
    try {
      // Create a test hadith model with known values
      final testHadith = HadithModel(
        id: 999,
        narrator: "TEST NARRATOR",
        text: "This is a test hadith to verify widget data transfer. If you see this text in the widget, data transfer is working correctly.",
        reference: "TEST REFERENCE: 123",
        chapter: "Test Chapter",
        bookNumber: 1,
        hadithNumber: 123,
        date: DateTime.now(),
        title: "Test Hadith",
      );
      
      // Update the widget with test data
      final result = await HadithWidgetService.saveDailyHadithForWidget(testHadith);
      
      // Show result
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result ? 'Test data saved to widget' : 'Failed to save test data'),
          duration: const Duration(seconds: 2),
          backgroundColor: result ? Colors.green : Colors.red,
        ),
      );
      
      // Verify data was saved
      _verifyWidgetData(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving test data: $e'),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  // Verify that data was saved correctly
  void _verifyWidgetData(BuildContext context) async {
    try {
      // Get the data from the widget service
      final hadith = await HadithWidgetService.getDailyHadithForWidget();
      
      // Show the data in a dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Widget Data Verification'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Narrator: ${hadith?.narrator ?? 'Not found'}'),
                const SizedBox(height: 8),
                Text('Text: ${hadith?.text != null ? (hadith!.text.length > 50 ? '${hadith.text.substring(0, 50)}...' : hadith.text) : 'Not found'}'),
                const SizedBox(height: 8),
                Text('Reference: ${hadith?.reference ?? 'Not found'}'),
                const SizedBox(height: 8),
                Text('Last Updated: ${hadith?.date != null ? hadith!.date.toString() : 'Not found'}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to verify widget data: $e'),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
    }
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
                // Update the widget with the daily hadith
                _updateWidget(state.dailyHadith!);

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
                        // Widget action buttons
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Refresh widget button
                            IconButton(
                              onPressed: () {
                                _updateWidget(state.dailyHadith!, context);
                              },
                              icon: Icon(
                                Icons.refresh,
                                color: KColor.accent.color,
                                size: 20.w,
                              ),
                              tooltip: 'Refresh widget',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            // Test widget button
                            IconButton(
                              onPressed: () {
                                _saveTestDataToWidget(context);
                              },
                              icon: Icon(
                                Icons.bug_report,
                                color: KColor.accent.color,
                                size: 20.w,
                              ),
                              tooltip: 'Test widget with sample data',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
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
