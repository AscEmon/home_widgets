import 'package:equatable/equatable.dart';
import '/utils/enum.dart';
import '../model/hadith_model.dart';

class HadithState extends Equatable {
  final List<HadithModel> hadithList;
  final HadithModel? selectedHadith;
  final HadithModel? dailyHadith;
  final AppStatus hadithListStatus;
  final AppStatus hadithDetailStatus;
  final AppStatus dailyHadithStatus;
  final String errorMessage;
  final int currentPage;
  final bool hasMoreData;

  const HadithState({
    this.hadithList = const [],
    this.selectedHadith,
    this.dailyHadith,
    this.hadithListStatus = AppStatus.initial,
    this.hadithDetailStatus = AppStatus.initial,
    this.dailyHadithStatus = AppStatus.initial,
    this.errorMessage = '',
    this.currentPage = 1,
    this.hasMoreData = true,
  });

  HadithState copyWith({
    List<HadithModel>? hadithList,
    HadithModel? selectedHadith,
    HadithModel? dailyHadith,
    AppStatus? hadithListStatus,
    AppStatus? hadithDetailStatus,
    AppStatus? dailyHadithStatus,
    String? errorMessage,
    int? currentPage,
    bool? hasMoreData,
  }) {
    return HadithState(
      hadithList: hadithList ?? this.hadithList,
      selectedHadith: selectedHadith ?? this.selectedHadith,
      dailyHadith: dailyHadith ?? this.dailyHadith,
      hadithListStatus: hadithListStatus ?? this.hadithListStatus,
      hadithDetailStatus: hadithDetailStatus ?? this.hadithDetailStatus,
      dailyHadithStatus: dailyHadithStatus ?? this.dailyHadithStatus,
      errorMessage: errorMessage ?? this.errorMessage,
      currentPage: currentPage ?? this.currentPage,
      hasMoreData: hasMoreData ?? this.hasMoreData,
    );
  }

  @override
  List<Object?> get props => [
        hadithList,
        selectedHadith,
        dailyHadith,
        hadithListStatus,
        hadithDetailStatus,
        dailyHadithStatus,
        errorMessage,
        currentPage,
        hasMoreData,
      ];
}
