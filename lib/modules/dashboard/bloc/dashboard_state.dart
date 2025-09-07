import 'package:flutter/material.dart';
import 'package:home_widgets/modules/dashboard/model/hadith_model.dart';
import '/utils/enum.dart';

@immutable
class DashboardState {
  final HadithModel? dailyHadith;
  final AppStatus dailyHadithStatus;
  final String errorMessage;

  const DashboardState({
    this.dailyHadith,
    this.dailyHadithStatus = AppStatus.initial,
    this.errorMessage = '',
  });

  DashboardState copyWith({
    HadithModel? dailyHadith,
    AppStatus? dailyHadithStatus,
    String? errorMessage,
  }) {
    return DashboardState(
      dailyHadith: dailyHadith ?? this.dailyHadith,
      dailyHadithStatus: dailyHadithStatus ?? this.dailyHadithStatus,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
