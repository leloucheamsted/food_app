import 'package:wyatt_architecture/wyatt_architecture.dart';

class APIRequestException extends AppException {
  APIRequestException(this.statusCode, super.message, this.apiResponse,
      [this.isSocketException = false])
      : super();

  int statusCode;
  String apiResponse;
  bool isSocketException;

  @override
  String toString() {
    // ignore: lines_longer_than_80_chars
    return 'APIRequestException{statusCode: $statusCode, apiResponse: $apiResponse, isSocketException: $isSocketException}';
  }
}
