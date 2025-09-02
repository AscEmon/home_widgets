import 'package:flutter_bloc/flutter_bloc.dart';
import '/utils/extension.dart';

class AppBlocObserver extends BlocObserver {
  // Private constructor
  AppBlocObserver._privateConstructor();

  // Singleton instance
  static final AppBlocObserver _instance =
      AppBlocObserver._privateConstructor();

  // Factory constructor to return the singleton instance
  factory AppBlocObserver() => _instance;

  // Public getter to access the singleton instance
  static AppBlocObserver get instance => _instance;

  final List<BlocBase> _blocs = [];

  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    _blocs.add(bloc);
    'Bloc Created: ${bloc.runtimeType} ${bloc.hashCode}'.log();
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    _blocs.remove(bloc);
    'Bloc Closed: ${bloc.runtimeType}'.log();
  }

  Future<void> disposeAllBlocs() async {
    'Disposing all BLoCs...'.log();
    'Total BLoCs to dispose: ${_blocs.length}'.log();
    for (final bloc in _blocs) {
      'Disposing Bloc: ${bloc.runtimeType} ${bloc.hashCode}'.log();
      bloc.close(); // Trigger bloc's close logic
    }
    _blocs.clear(); // Clear the list once all blocs are closed
    'All blocs disposed'.log();
  }
}
