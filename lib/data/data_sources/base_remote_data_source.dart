import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:food_app/config/app_settings.dart';
import 'package:food_app/core/helpers/Exceptions/api_request_exceptions.dart';
import 'package:food_app/core/repositories/repository_constants.dart';

abstract class BaseRemoteDataSource {
  BaseRemoteDataSource({
    required this.dio,
    required this.appSettings,
  });

  final Dio dio;
  final AppSettings appSettings;

  Future<Map<String, String>> getHeaders() async {
    var headers = {
      'x-rapidapi-host': 'travel-advisor.p.rapidapi.com',
      'x-rapidapi-key': 'ecebd325f6mshacab5c76803c9dcp135720jsn290937731b6b',
    };

    return headers;
  }

  bool _isSuccessStatusCode(int statusCode) {
    return statusCode >= 200 && statusCode < 300;
  }

  Future<Response<T>> getWithType<T>(String url,
      {Map<String, String>? queryParameters,
      Map<String, dynamic>? headers}) async {
    try {
      final result = await dio.get<T>(url,
          queryParameters: queryParameters ?? {},
          options: Options(headers: await getHeaders()));

      if (!_isSuccessStatusCode(result.statusCode ?? 0)) {
        throw APIRequestException(result.statusCode ?? 0,
            result.statusMessage ?? '', result.data.toString());
      }

      return result;
    } catch (e) {
      handleException(e);
      rethrow;
    }
  }

  Future<Response<dynamic>> get(String url,
      {Map<String, String>? queryParameters,
      Map<String, dynamic>? headers}) async {
    try {
      final result = await dio.get<Map<String, dynamic>>(url,
          queryParameters: queryParameters ?? {},
          options: Options(headers: await getHeaders()));

      if (!_isSuccessStatusCode(result.statusCode ?? 0)) {
        throw APIRequestException(result.statusCode ?? 0,
            result.statusMessage ?? '', result.data.toString());
      }

      return result;
    } catch (e) {
      handleException(e);
      rethrow;
    }
  }

  Future<void> delete(String url, {Map<String, dynamic>? headers}) async {
    final result = await dio.delete<Map<String, dynamic>>(url,
        options: Options(headers: await getHeaders()));
    try {
      if (!_isSuccessStatusCode(result.statusCode ?? 0)) {
        throw APIRequestException(result.statusCode ?? 0,
            result.statusMessage ?? '', result.data.toString());
      }
    } catch (e) {
      handleException(e);
      rethrow;
    }
  }

  void handleException(Object e) {
    if (e is DioException) {
      throw APIRequestException(e.response?.statusCode ?? 0,
          e.response?.statusMessage, e.response?.data?.toString() ?? "");
    } else if (e is SocketException) {
      throw APIRequestException(0, '', e.message + e.toString(), true);
    }
  }

  Future<Response<Map<String, dynamic>>> post(
      String url, Map<String, dynamic> body,
      {Map<String, String>? headers}) async {
    try {
      // final json = jsonEncode(body);
      // print("POST JSON: $json");
      final result = await dio.post<Map<String, Object?>>(url,
          data: jsonEncode(body),
          options: Options(headers: await getHeaders()));

      if (!_isSuccessStatusCode(result.statusCode ?? 0)) {
        throw APIRequestException(result.statusCode ?? 0,
            result.statusMessage ?? '', result.data.toString());
      }

      return result;
    } catch (e) {
      handleException(e);
      rethrow;
    }
  }

  Future<Response<Map<String, dynamic>>> postStringBody(String url, String body,
      {Map<String, dynamic>? headers}) async {
    final result = await dio.post<Map<String, Object?>>(url,
        data: body, options: Options(headers: await getHeaders()));
    try {
      if (!_isSuccessStatusCode(result.statusCode ?? 0)) {
        throw APIRequestException(result.statusCode ?? 0,
            result.statusMessage ?? '', result.data.toString());
      }

      return result;
    } catch (e) {
      handleException(e);
      rethrow;
    }
  }

  Future<Response<Map<String, dynamic>>> put(
      String url, Map<String, dynamic> body,
      {Map<String, String>? headers}) async {
    try {
      final result = await dio.put<Map<String, Object?>>(url,
          data: jsonEncode(body),
          options: Options(headers: await getHeaders()));

      if (!_isSuccessStatusCode(result.statusCode ?? 0)) {
        throw APIRequestException(result.statusCode ?? 0,
            result.statusMessage ?? '', result.data.toString());
      }

      return result;
    } catch (e) {
      handleException(e);
      rethrow;
    }
  }
}
