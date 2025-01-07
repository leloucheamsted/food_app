import 'dart:async';

import 'package:food_app/core/entities/restaurant_entity.dart';
import 'package:food_app/core/repositories/restaurants_repository.dart';
import 'package:food_app/data/data_sources/restaurant_data_source/restaurants_data_source.dart';

class RestaurantsRepositoryImpl implements RestaurantsRepository {
  RestaurantsRepositoryImpl({
    required RestaurantsRemoteDataSource restaurantsRemoteDataSource,
  }) : _restaurantsRemoteDataSource = restaurantsRemoteDataSource;

  final RestaurantsRemoteDataSource _restaurantsRemoteDataSource;

  @override
  FutureOr<List<RestaurantEntity>> getRestaurants(String type) {
    return _restaurantsRemoteDataSource.getRestaurants(type);
  }
}
