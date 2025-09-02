import 'package:equatable/equatable.dart';

abstract class HadithEvent extends Equatable {
  const HadithEvent();

  @override
  List<Object?> get props => [];
}

class FetchHadithList extends HadithEvent {
  final bool isRefresh;

  const FetchHadithList({this.isRefresh = false});

  @override
  List<Object?> get props => [isRefresh];
}

class FetchMoreHadithList extends HadithEvent {
  const FetchMoreHadithList();
}

class FetchHadithDetail extends HadithEvent {
  final int hadithId;

  const FetchHadithDetail({required this.hadithId});

  @override
  List<Object?> get props => [hadithId];
}

class FetchDailyHadith extends HadithEvent {
  const FetchDailyHadith();
}

class ResetHadithState extends HadithEvent {
  const ResetHadithState();
}
