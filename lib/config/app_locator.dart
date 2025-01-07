// ignore_for_file: lines_longer_than_80_chars

import 'dart:io';
import 'dart:isolate';

import 'package:dio/dio.dart';
import 'package:food_app/config/app_settings.dart';
import 'package:food_app/core/use_cases/use_case_locator_helper.dart';
import 'package:food_app/data/data_locator_helper.dart';
import 'package:get_it/get_it.dart';
import 'package:wyatt_type_utils/wyatt_type_utils.dart';

final locator = GetIt.instance;

Future<void> _initCommon(GetIt locator) async {
  // Inject Utils
  // locator
  locator
    ..registerRepositories()
    // Inject Datasources
    ..registerDataSources()

    // Inject Usecases
    ..registerUseCases()
    ..registerLazySingleton<Dio>(() {
      return Dio()..interceptors.add(LogInterceptor());
    });
}

Future<void> configureApp(GetIt? workerLocator) async {
  final AppSettings appSettings = AppSettings(
      appName: 'Food',
      apiUrl: 'https://travel-advisor.p.rapidapi.com/restaurants/list?location_id=293919&currency=USD&lunit=km&limit=30&lang=en_US',
      apiKey: '',
      xRapidapiHost: 'travel-advisor.p.rapidapi.com',
      xRapidapiKey: 'ecebd325f6mshacab5c76803c9dcp135720jsn290937731b6b');

  workerLocator.isNull
      ? locator.registerSingleton<AppSettings>(appSettings)
      : workerLocator?.registerSingleton<AppSettings>(appSettings);

  await _initCommon(workerLocator ?? locator);
  workerLocator.isNull
      ? await workerLocator?.allReady()
      : await locator.allReady();
}
