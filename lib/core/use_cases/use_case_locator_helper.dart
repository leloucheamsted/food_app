import 'package:food_app/core/use_cases/restaurants/get_restaurants_use_case.dart';
import 'package:get_it/get_it.dart';

extension UseCaseLocatorHelper on GetIt {
  // Inject Usecases
  void registerUseCases() {
    registerLazySingleton<GetRestaurantsUseCase>(
      () => GetRestaurantsUseCase(
        restaurantsRepository: this(),
      ),
    );
  }
}
