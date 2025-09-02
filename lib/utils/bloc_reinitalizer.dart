import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '/utils/app_bloc_observer.dart';
import 'mixin/bloc_provider_mixin.dart';

class BlocReinitializer extends StatefulWidget {
  final Widget child;

  const BlocReinitializer({super.key, required this.child});

  static void reinitialize(BuildContext context) async {
    await AppBlocObserver.instance.disposeAllBlocs();
    final _BlocReinitializerState? state =
        // ignore: use_build_context_synchronously
        context.findAncestorStateOfType<_BlocReinitializerState>();
    state?.reinitialize();
  }

  @override
  // ignore: library_private_types_in_public_api
  _BlocReinitializerState createState() => _BlocReinitializerState();
}

class _BlocReinitializerState extends State<BlocReinitializer>
    with BlocProviderMixin {
  Key key = UniqueKey();

  void reinitialize() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: MultiBlocProvider(
        providers: blocProviders(),
        child: widget.child,
      ),
    );
  }
}
