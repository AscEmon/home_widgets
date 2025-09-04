import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'package:home_widgets/modules/dashboard/model/hadith_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HadithWidgetProvider {
  static const String appGroupId = 'group.com.sslwireless.homewidget';
  static const String widgetKind = 'dailyhadiah';
  static const String dailyHadithKey = 'daily_hadith';
  static const String narratorKey = 'narrator';
  static const String textKey = 'text';
  static const String referenceKey = 'reference';
  static const String lastUpdatedKey = 'last_updated';

  // Initialize the widget service
  static Future<void> initializeWidget() async {
    await HomeWidget.setAppGroupId(appGroupId);
  }

  // Update the widget with daily hadith data
  static Future<bool> updateDailyHadithWidget(HadithModel hadith) async {
    try {
      // Initialize widget with app group ID first
      await initializeWidget();

      debugPrint('Updating widget with data:');
      debugPrint('Narrator: ${hadith.narrator}');
      debugPrint('Text: ${_truncateText(hadith.text)}');
      debugPrint('Reference: ${hadith.reference}');

      // IMPORTANT: For iOS, we need to ensure data is written directly to UserDefaults
      // with the exact same keys that the Swift code is looking for
      if (Platform.isIOS) {
        debugPrint('Running on iOS - using direct UserDefaults access');
        
        // First save the complete hadith as JSON for redundancy
        final jsonData = jsonEncode(hadith.toJson());
        await HomeWidget.saveWidgetData<String>(dailyHadithKey, jsonData);
        debugPrint('Saved complete hadith JSON data to UserDefaults');
        
        // Save individual fields with explicit types for direct access by the widget
        // These keys must match exactly what's used in the Swift code
        await HomeWidget.saveWidgetData<String>(narratorKey, hadith.narrator);
        await HomeWidget.saveWidgetData<String>(textKey, _truncateText(hadith.text));
        await HomeWidget.saveWidgetData<String>(referenceKey, hadith.reference);
        await HomeWidget.saveWidgetData<String>(lastUpdatedKey, DateTime.now().toIso8601String());
        
        // Force multiple update attempts with different methods
        debugPrint('Requesting iOS widget update with multiple methods...');
        
        // Method 1: Standard update
        await HomeWidget.updateWidget(
          name: widgetKind,
          iOSName: 'dailyhadiah',
        );
        
        // Method 2: Force update with delay
        await Future.delayed(const Duration(milliseconds: 500));
        await HomeWidget.updateWidget(
          name: widgetKind,
          iOSName: 'dailyhadiah',
        );
        
        // Method 3: Use a mock data update to force refresh
        await _forceiOSWidgetRefresh();
        
        // Verify data was saved by reading it back
        final savedNarrator = await HomeWidget.getWidgetData<String>(narratorKey);
        final savedText = await HomeWidget.getWidgetData<String>(textKey);
        debugPrint('Verification - saved narrator: $savedNarrator');
        if (savedText != null && savedText.isNotEmpty) {
          debugPrint('Verification - saved text: ${savedText.substring(0, savedText.length > 20 ? 20 : savedText.length)}...');
        } else {
          debugPrint('Verification - saved text is null or empty');
        }
      } else {
        // Android implementation
        final jsonData = jsonEncode(hadith.toJson());
        await HomeWidget.saveWidgetData<String>(dailyHadithKey, jsonData);
        
        await HomeWidget.updateWidget(
          name: widgetKind,
          androidName: 'hadith_widget',
        );
      }
      
      // Also save to SharedPreferences for redundancy
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(narratorKey, hadith.narrator);
      await prefs.setString(textKey, _truncateText(hadith.text));
      await prefs.setString(referenceKey, hadith.reference);
      await prefs.setString(lastUpdatedKey, DateTime.now().toIso8601String());
      
      return true;
    } catch (e) {
      debugPrint('Error updating widget: $e');
      return false;
    }
  }
  
  // Special method to force iOS widget refresh by updating a timestamp
  static Future<void> _forceiOSWidgetRefresh() async {
    try {
      // Save a timestamp to force widget refresh
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      await HomeWidget.saveWidgetData<String>('widget_refresh_timestamp', timestamp);
      
      // Request widget update
      await HomeWidget.updateWidget(
        name: widgetKind,
        iOSName: 'dailyhadiah',
      );
      
      debugPrint('Forced widget refresh with timestamp: $timestamp');
    } catch (e) {
      debugPrint('Error forcing widget refresh: $e');
    }
  }

  // Truncate text to fit in widget
  static String _truncateText(String text) {
    const int maxLength = 150;
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  // Handle widget clicked event
  static Future<void> handleWidgetClicked(
    Function(int) onHadithSelected,
  ) async {
    try {
      final widgetData = await HomeWidget.getWidgetData<String>(dailyHadithKey);
      if (widgetData != null) {
        final hadith = HadithModel.fromJson(jsonDecode(widgetData));
        onHadithSelected(hadith.id);
      }
    } catch (e) {
      // Handle error
    }
  }
}
