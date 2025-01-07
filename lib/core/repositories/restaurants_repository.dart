import 'dart:async';

import 'package:food_app/core/entities/restaurant_entity.dart';
import 'package:wyatt_architecture/wyatt_architecture.dart';

abstract class RestaurantsRepository extends BaseRepository {
  FutureOr<List<RestaurantEntity>> getRestaurants(String type);
}
