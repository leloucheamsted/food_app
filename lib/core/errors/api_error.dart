import 'package:dio/dio.dart';
import 'package:wyatt_architecture/wyatt_architecture.dart';

class ApiError extends ServerException {
  const ApiError({
    required String message,
    required this.statusCode,
  }) : super(message);

  final int statusCode;
}

extension ExceptionCatcher on Object? {
  AppException asAppException({bool fromServer = false}) {
    if (this is DioException) {
      final dioException = this! as DioException;
      if (dioException.response != null) {
        return ApiError(
          message: dioException.message ?? '',
          statusCode: dioException.response!.statusCode ?? 0,
        );
      }
    }

    if (this is AppException) {
      return this! as AppException;
    }

    if (fromServer) {
      return ServerException(toString());
    }

    return ClientException(toString());
  }
}
