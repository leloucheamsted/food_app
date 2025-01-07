import 'dart:async';

import 'package:food_app/core/entities/restaurant_entity.dart';

abstract class RestaurantsRemoteDataSource {
  FutureOr<List<RestaurantEntity>> getRestaurants(String type);
}
