import 'package:flutter/material.dart';
import 'package:home_widgets/modules/dashboard/model/hadith_model.dart';

@immutable
abstract class IDashboardRepository {
  Future<HadithModel?> getDailyHadith();
}
