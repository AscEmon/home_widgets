import '../repository/dashboard_interface.dart';
import '../repository/dashboard_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '/modules/dashboard/bloc/dashboard_event.dart';
import '/modules/dashboard/bloc/dashboard_state.dart';



class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final IDashboardRepository _dashboardRepository = DashboardRepository();
  DashboardBloc():super(DashboardState());
}

