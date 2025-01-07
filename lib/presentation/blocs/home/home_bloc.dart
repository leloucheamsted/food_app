// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_app/config/app_locator.dart';
import 'package:food_app/core/entities/restaurant_entity.dart';
import 'package:food_app/core/use_cases/restaurants/get_restaurants_use_case.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeInitial()) {
    on<InitHomeEvent>(_init);
    on<FiltersRestaurantEvent>(_filters);

    _getRestaurantsUseCase = locator<GetRestaurantsUseCase>();
  }

  late final GetRestaurantsUseCase _getRestaurantsUseCase;

  Future<void> _init(InitHomeEvent event, Emitter<HomeState> emitter) async {
    final results = await _getRestaurantsUseCase(null);
    if (results.isErr) {
      log('Error initializing home page: ${results.err}', error: results.err);
      if (state is HomeLoadedState) {
        if ((state as HomeLoadedState).restaurants.isNotEmpty) {
          return;
        }
      }
      emitter(HomeExceptionState(HomeLoadedState(
        restaurants: const [],
      )));

      return;
    }
    final restaurants = results.ok!.toList();
    emitter(HomeLoadedState(
      restaurants: restaurants,
    ));
  }

  Future<void> _filters(
      FiltersRestaurantEvent event, Emitter<HomeState> emitter) async {
    emitter(loadingState(state as HomeLoadedState));
    final results = await _getRestaurantsUseCase(event.type);
    if (results.isErr) {
      log('Error initializing home page: ${results.err}', error: results.err);
      if (state is HomeLoadedState) {
        if ((state as HomeLoadedState).restaurants.isNotEmpty) {
          return;
        }
      }
      emitter(HomeExceptionState(HomeLoadedState(
        restaurants: const [],
      )));

      return;
    }
    final restaurants = results.ok!.toList();
    emitter(HomeLoadedState(
      restaurants: restaurants,
    ));
  }
}
