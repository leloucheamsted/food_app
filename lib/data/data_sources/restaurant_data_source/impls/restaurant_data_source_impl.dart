import 'dart:async';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:food_app/core/entities/restaurant_entity.dart';
import 'package:food_app/data/data_sources/base_remote_data_source.dart';
import 'package:food_app/data/data_sources/restaurant_data_source/restaurants_data_source.dart';
import 'package:wyatt_type_utils/wyatt_type_utils.dart';

class RestaurantsRemoteDataSourceImpl extends BaseRemoteDataSource
    implements RestaurantsRemoteDataSource {
  RestaurantsRemoteDataSourceImpl({
    required super.dio,
    required super.appSettings,
  });

  @override
  FutureOr<List<RestaurantEntity>> getRestaurants(String type) async {
    final response = await dio.get(
      type.isNullOrEmpty
          ? appSettings.apiUrl
          : 'https://travel-advisor.p.rapidapi.com/restaurants/list?location_id=293919&combined_food=${type}&currency=USD&lunit=km&limit=30&lang=en_US',
      options: Options(headers: await getHeaders()),
    );
    final List<dynamic> data = response.data['data'] as List<dynamic>;
    log(data.toString());
    return data.map((json) => RestaurantEntity.fromJson(json)).toList();
  }
}
