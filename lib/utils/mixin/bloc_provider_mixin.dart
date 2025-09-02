import 'package:flutter_bloc/flutter_bloc.dart';
import '/modules/dashboard/bloc/dashboard_bloc.dart';

mixin BlocProviderMixin {
  blocProviders() {
    return [
       BlocProvider(
        create: (context) => DashboardBloc(),
      ),
      
    ];
  }
}



