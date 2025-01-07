import 'package:food_app/core/repositories/restaurants_repository.dart';
import 'package:food_app/data/data_sources/restaurant_data_source/impls/restaurant_data_source_impl.dart';
import 'package:food_app/data/data_sources/restaurant_data_source/restaurants_data_source.dart';
import 'package:food_app/data/repositories/restaurants_repository_impl.dart';
import 'package:get_it/get_it.dart';

extension DataLocatorHelper on GetIt {
  void registerRepositories() {
    registerLazySingleton<RestaurantsRepository>(
        () => RestaurantsRepositoryImpl(
              restaurantsRemoteDataSource: this(),
            ));
  }

  void registerDataSources() {
    registerLazySingleton<RestaurantsRemoteDataSource>(
      () => RestaurantsRemoteDataSourceImpl(dio: this(), appSettings: this()),
    );
  }
}
