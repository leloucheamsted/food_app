import 'package:food_app/core/entities/restaurant_entity.dart';
import 'package:food_app/core/repositories/restaurants_repository.dart';
import 'package:wyatt_architecture/wyatt_architecture.dart';
import 'package:wyatt_type_utils/wyatt_type_utils.dart';

class GetRestaurantsUseCase
    extends AsyncUseCase<String, List<RestaurantEntity>?> {
  GetRestaurantsUseCase({required RestaurantsRepository restaurantsRepository})
      : _restaurantsRepository = restaurantsRepository;

  final RestaurantsRepository _restaurantsRepository;
  @override
  FutureOrResult<List<RestaurantEntity>?> execute(String? params) =>
      Result.tryCatchAsync(
          () async => await _restaurantsRepository.getRestaurants(params??''),
          (error) => error is AppException
              ? error
              : ClientException(error.toString()));
}
