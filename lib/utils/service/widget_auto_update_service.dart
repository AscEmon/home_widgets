import 'dart:async';
import 'package:home_widgets/modules/dashboard/repository/dashboard_repository.dart';
import 'package:home_widgets/utils/extension.dart';
import 'package:home_widgets/utils/service/hadith_widget_service.dart';

/// Service to automatically update the widget with new hadith data every 5 minutes
class WidgetAutoUpdateService {
  static WidgetAutoUpdateService? _instance;
  static WidgetAutoUpdateService get instance =>
      _instance ??= WidgetAutoUpdateService._();

  Timer? _timer;
  final DashboardRepository _repository = DashboardRepository();
  bool _isUpdating = false;

  WidgetAutoUpdateService._();

  /// Start the automatic widget update service
  void startAutoUpdate() {
    if (_timer != null) {
      _timer!.cancel();
      _timer = null;
    }

    // Update immediately when service starts
    _updateWidgetWithNewHadith();

    // Then schedule updates every 5 minutes
    _timer = Timer.periodic(const Duration(minutes: 5), (_) {
      _updateWidgetWithNewHadith();
    });

    'Widget auto-update service started. Updates will occur every 5 minutes.'
        .log();
  }

  /// Check if the auto-update service is running
  bool isAutoUpdateRunning() {
    return _timer != null;
  }

  /// Stop the automatic widget update service
  void stopAutoUpdate() {
    if (_timer != null) {
      _timer!.cancel();
      _timer = null;
      'Widget auto-update service stopped.'.log();
    }
  }

  /// Update the widget with new hadith data
  Future<void> _updateWidgetWithNewHadith() async {
    // Prevent multiple simultaneous updates
    if (_isUpdating) {
      'Widget update already in progress, skipping...'.log();
      return;
    }

    _isUpdating = true;
    try {
      'Fetching new hadith for widget update...'.log();
      final hadith = await _repository.getDailyHadith();

      if (hadith != null) {
        // Update the widget with the new hadith
        final result = await HadithWidgetService.saveDailyHadithForWidget(
          hadith,
        );
        'Widget auto-update ${result ? 'successful' : 'failed'} with hadith: ${hadith.narrator}'
            .log();
      } else {
        'Failed to fetch new hadith for widget update'.log();
      }
    } catch (e) {
      'Error updating widget with new hadith: $e'.log();
    } finally {
      _isUpdating = false;
    }
  }

  /// Force an immediate update of the widget
  Future<bool> forceUpdate() async {
    try {
      final hadith = await _repository.getDailyHadith();
      if (hadith != null) {
        final result = await HadithWidgetService.saveDailyHadithForWidget(
          hadith,
        );
        return result;
      }
      return false;
    } catch (e) {
      'Error forcing widget update: $e'.log();
      return false;
    }
  }
}
