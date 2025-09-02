import 'package:flutter/material.dart';
import '../model/hadith_model.dart';

@immutable
abstract class IHadithRepository {
  Future<List<HadithModel>> getHadithList({required int page, required int limit});
  Future<HadithModel?> getHadithDetail({required int hadithId});
  Future<HadithModel?> getDailyHadith();
}
