import 'package:shared_preferences/shared_preferences.dart';
import '../model/hadith_model.dart';
import '../model/hadith_widget_model.dart';

class HadithWidgetService {
  static const String _dailyHadithKey = 'daily_hadith_widget_data';

  // Save daily hadith to shared preferences for widget
  static Future<bool> saveDailyHadithForWidget(HadithModel hadith) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final widgetModel = HadithWidgetModel(
        id: hadith.id,
        narrator: hadith.narrator,
        text: hadith.text,
        reference: hadith.reference,
        updatedAt: DateTime.now(),
      );
      
      final encodedData = HadithWidgetModel.encode(widgetModel);
      return await prefs.setString(_dailyHadithKey, encodedData);
    } catch (e) {
      return false;
    }
  }

  // Get daily hadith from shared preferences for widget
  static Future<HadithWidgetModel?> getDailyHadithForWidget() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hadithJson = prefs.getString(_dailyHadithKey);
      return HadithWidgetModel.decode(hadithJson);
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
      final difference = now.difference(currentHadith.updatedAt);
      
      // Update if more than 24 hours old
      return difference.inHours >= 24;
    } catch (e) {
      return true;
    }
  }
}
