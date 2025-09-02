import 'package:flutter_bloc/flutter_bloc.dart';
import '/utils/enum.dart';
import '../repository/hadith_interface.dart';
import '../repository/hadith_repository.dart';
import '../service/hadith_widget_service.dart';
import 'hadith_event.dart';
import 'hadith_state.dart';

class HadithBloc extends Bloc<HadithEvent, HadithState> {
  final IHadithRepository _hadithRepository = HadithRepository();
  static const int _pageLimit = 10;

  HadithBloc() : super(const HadithState()) {
    on<FetchHadithList>(_onFetchHadithList);
    on<FetchMoreHadithList>(_onFetchMoreHadithList);
    on<FetchHadithDetail>(_onFetchHadithDetail);
    on<FetchDailyHadith>(_onFetchDailyHadith);
    on<ResetHadithState>(_onResetHadithState);
  }

  Future<void> _onFetchHadithList(
    FetchHadithList event,
    Emitter<HadithState> emit,
  ) async {
    try {
      if (event.isRefresh) {
        emit(state.copyWith(
          hadithListStatus: AppStatus.loading,
          currentPage: 1,
          hasMoreData: true,
        ));
      } else {
        emit(state.copyWith(hadithListStatus: AppStatus.loading));
      }

      final hadithList = await _hadithRepository.getHadithList(
        page: 1,
        limit: _pageLimit,
      );

      emit(state.copyWith(
        hadithList: hadithList,
        hadithListStatus: AppStatus.success,
        hasMoreData: hadithList.length >= _pageLimit,
      ));
    } catch (e) {
      emit(state.copyWith(
        hadithListStatus: AppStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onFetchMoreHadithList(
    FetchMoreHadithList event,
    Emitter<HadithState> emit,
  ) async {
    if (!state.hasMoreData || state.hadithListStatus == AppStatus.loading) {
      return;
    }

    try {
      final nextPage = state.currentPage + 1;
      
      final moreHadithList = await _hadithRepository.getHadithList(
        page: nextPage,
        limit: _pageLimit,
      );

      if (moreHadithList.isEmpty) {
        emit(state.copyWith(hasMoreData: false));
        return;
      }

      final updatedList = List.of(state.hadithList)..addAll(moreHadithList);

      emit(state.copyWith(
        hadithList: updatedList,
        currentPage: nextPage,
        hasMoreData: moreHadithList.length >= _pageLimit,
      ));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onFetchHadithDetail(
    FetchHadithDetail event,
    Emitter<HadithState> emit,
  ) async {
    try {
      emit(state.copyWith(hadithDetailStatus: AppStatus.loading));

      final hadithDetail = await _hadithRepository.getHadithDetail(
        hadithId: event.hadithId,
      );

      emit(state.copyWith(
        selectedHadith: hadithDetail,
        hadithDetailStatus: AppStatus.success,
      ));
    } catch (e) {
      emit(state.copyWith(
        hadithDetailStatus: AppStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onFetchDailyHadith(
    FetchDailyHadith event,
    Emitter<HadithState> emit,
  ) async {
    emit(state.copyWith(dailyHadithStatus: AppStatus.loading));

    try {
      final result = await _hadithRepository.getDailyHadith();
      emit(state.copyWith(
        dailyHadith: result,
        dailyHadithStatus: AppStatus.success,
      ));
      
      // Save daily hadith for widget
      if (result != null) {
        await HadithWidgetService.saveDailyHadithForWidget(result);
      }
    } catch (e) {
      emit(state.copyWith(
        dailyHadithStatus: AppStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onResetHadithState(
    ResetHadithState event,
    Emitter<HadithState> emit,
  ) {
    emit(const HadithState());
  }
}
