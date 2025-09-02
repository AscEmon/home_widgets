import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import '../model/hadith_widget_model.dart';

class HadithWidgetProvider {
  static const String appGroupId = 'group.com.example.homeWidgets';
  static const String widgetKind = 'hadith_widget';
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
  static Future<bool> updateDailyHadithWidget(HadithWidgetModel hadith) async {
    try {
      // Initialize widget with app group ID first
      await initializeWidget();
      
      // Debug print to verify data being sent
      debugPrint('Updating widget with data:');
      debugPrint('Narrator: ${hadith.narrator}');
      debugPrint('Text: ${_truncateText(hadith.text)}');
      debugPrint('Reference: ${hadith.reference}');
      
      // Save data to shared UserDefaults
      await HomeWidget.saveWidgetData(narratorKey, hadith.narrator);
      await HomeWidget.saveWidgetData(textKey, _truncateText(hadith.text));
      await HomeWidget.saveWidgetData(referenceKey, hadith.reference);
      await HomeWidget.saveWidgetData(lastUpdatedKey, DateTime.now().toIso8601String());
      
      // Request widget update
      final result = await HomeWidget.updateWidget(
        name: widgetKind,
        iOSName: 'MyHomeWidget',
      );
      
      debugPrint('Widget update result: $result');
      return result ?? false;
    } catch (e) {
      debugPrint('Error updating widget: $e');
      return false;
    }
  }

  // Truncate text to fit in widget
  static String _truncateText(String text) {
    const int maxLength = 150;
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  // Handle widget clicked event
  static Future<void> handleWidgetClicked(Function(int) onHadithSelected) async {
    try {
      final widgetData = await HomeWidget.getWidgetData<String>(dailyHadithKey);
      if (widgetData != null) {
        final hadith = HadithWidgetModel.decode(widgetData);
        if (hadith != null) {
          onHadithSelected(hadith.id);
        }
      }
    } catch (e) {
      // Handle error
    }
  }
}
