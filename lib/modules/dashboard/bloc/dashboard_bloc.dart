import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_widgets/utils/enum.dart';
import 'package:home_widgets/utils/service/hadith_widget_service.dart';

import '/modules/dashboard/bloc/dashboard_event.dart';
import '/modules/dashboard/bloc/dashboard_state.dart';
import '../repository/dashboard_interface.dart';
import '../repository/dashboard_repository.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final IDashboardRepository _dashboardRepository = DashboardRepository();
  DashboardBloc() : super(DashboardState()) {
    on<FetchDailyHadith>(_onFetchDailyHadith);
  }

  Future<void> _onFetchDailyHadith(
    FetchDailyHadith event,
    Emitter<DashboardState> emit,
  ) async {
    emit(state.copyWith(dailyHadithStatus: AppStatus.loading));

    try {
      final result = await _dashboardRepository.getDailyHadith();
      emit(
        state.copyWith(
          dailyHadith: result,
          dailyHadithStatus: AppStatus.success,
        ),
      );

      // Save daily hadith for widget
      if (result != null) {
        await HadithWidgetService.saveDailyHadithForWidget(result);
      }
    } catch (e) {
      emit(
        state.copyWith(
          dailyHadithStatus: AppStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
