import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import '../../modules/dashboard/model/hadith_model.dart';

class HadithWidgetService {
  static const String _dailyHadithKey = 'daily_hadith_widget_data';

  // Save daily hadith to shared preferences for widget
  static Future<bool> saveDailyHadithForWidget(HadithModel hadith) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final widgetModel = HadithModel(
        id: hadith.id,
        title: hadith.title,
        narrator: hadith.narrator,
        text: hadith.text,
        reference: hadith.reference,
        chapter: hadith.chapter,
        bookNumber: hadith.bookNumber,
        hadithNumber: hadith.hadithNumber,
        date: DateTime.now(),
      );

      final encodedData = widgetModel.toJson();
      return await prefs.setString(_dailyHadithKey, jsonEncode(encodedData));
    } catch (e) {
      return false;
    }
  }

  // Get daily hadith from shared preferences for widget
  static Future<HadithModel?> getDailyHadithForWidget() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hadithJson = prefs.getString(_dailyHadithKey);
      return HadithModel.fromJson(jsonDecode(hadithJson!));
    } catch (e) {
      return null;
    }
  }

  // Check if daily hadith needs to be updated (older than 24 hours)
  static Future<bool> shouldUpdateDailyHadith() async {
    try {
      final currentHadith = await getDailyHadithForWidget();
      if (currentHadith == null) return true;

      final now = DateTime.now();
      final difference = now.difference(currentHadith.date);

      // Update if more than 24 hours old
      return difference.inHours >= 24;
    } catch (e) {
      return true;
    }
  }
}
