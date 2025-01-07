// import 'package:background_downloader/background_downloader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_app/presentation/blocs/app/app_bloc_bloc.dart';
import 'package:food_app/presentation/blocs/home/home_bloc.dart';
import 'package:food_app/presentation/screens/home/home.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();

  // ignore: library_private_types_in_public_api
  static _AppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_AppState>();
}

class _AppState extends State<App> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext contextt) => MultiBlocProvider(
        providers: [
          BlocProvider(
              create: (context) => AppBloc()
                ..add(InitAppEvent())
                ..add(SendAppConfigEvent('', '', ''))),
          BlocProvider(
              create: (context) => HomeBloc()..add(const InitHomeEvent())),
        ],
        child: BlocBuilder<AppBloc, AppState>(builder: (context, state) {
          return MaterialApp(
              title: 'Food App',
              theme: ThemeData(
                primarySwatch: Colors.blue,
              ),
              home: const HomeScreen());
        }),
      );
}
