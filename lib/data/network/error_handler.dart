import 'package:ai_movie_suggestion/data/network/failure.dart';
import 'package:dio/dio.dart';

class ErrorHandler implements Exception {
  late Failure failure;

  ErrorHandler.handle(dynamic error) {
    if (error is DioException) {
      // Error from response of the API or from dio itself
      failure = _handleError(error);
    } else {
      // Default error
      failure = DataSource.DEFAULT.getFailure();
    }
  }

  Failure _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.connectionError:
        return DataSource.CONNECT_TIMEOUT.getFailure();

      case DioExceptionType.sendTimeout:
        return DataSource.SEND_TIMEOUT.getFailure();

      case DioExceptionType.receiveTimeout:
        return DataSource.RECEIVE_TIMEOUT.getFailure();

      case DioExceptionType.badCertificate:
        return DataSource.BAD_REQUEST.getFailure();

      case DioExceptionType.badResponse:
        if (error.response != null && error.response?.statusCode != null) {
          // ✅ Try to get real error message from the backend response
          String errorMessage = ResponseMessage.DEFAULT;

          try {
            final data = error.response?.data;
            if (data != null) {
              if (data is Map<String, dynamic> && data['message'] != null) {
                errorMessage = data['message'];
              } else if (data is String) {
                // Sometimes the server sends plain text
                errorMessage = data;
              }
            }
          } catch (_) {
            // Do nothing, fallback to default errorMessage
          }

          return Failure(ApiInternalStatus.failure, errorMessage);
        } else {
          return DataSource.DEFAULT.getFailure();
        }

      case DioExceptionType.cancel:
        return DataSource.CANCEL.getFailure();

      case DioExceptionType.unknown:
      default:
        return DataSource.DEFAULT.getFailure();
    }
  }
}

enum DataSource {
  SUCCESS,
  NO_CONTENT,
  BAD_REQUEST,
  FORBIDDEN,
  UNAUTHORIZED,
  NOT_FOUND,
  INTERNAL_SERVER_ERROR,
  CONNECT_TIMEOUT,
  CANCEL,
  RECEIVE_TIMEOUT,
  SEND_TIMEOUT,
  CACHE_ERROR,
  NO_INTERNET_CONNECTION,
  DEFAULT,
}

extension DataSourceExtension on DataSource {
  Failure getFailure() {
    switch (this) {
      case DataSource.SUCCESS:
        return Failure(ApiInternalStatus.success, ResponseMessage.SUCCESS);
      case DataSource.NO_CONTENT:
        return Failure(ApiInternalStatus.success, ResponseMessage.NO_CONTENT);
      case DataSource.BAD_REQUEST:
        return Failure(ApiInternalStatus.failure, ResponseMessage.BAD_REQUEST);
      case DataSource.FORBIDDEN:
        return Failure(ApiInternalStatus.failure, ResponseMessage.FORBIDDEN);
      case DataSource.UNAUTHORIZED:
        return Failure(ApiInternalStatus.failure, ResponseMessage.UNAUTHORIZED);
      case DataSource.NOT_FOUND:
        return Failure(ApiInternalStatus.failure, ResponseMessage.NOT_FOUND);
      case DataSource.INTERNAL_SERVER_ERROR:
        return Failure(
            ApiInternalStatus.failure, ResponseMessage.INTERNAL_SERVER_ERROR);
      case DataSource.CONNECT_TIMEOUT:
        return Failure(
            ApiInternalStatus.failure, ResponseMessage.CONNECT_TIMEOUT);
      case DataSource.CANCEL:
        return Failure(ApiInternalStatus.failure, ResponseMessage.CANCEL);
      case DataSource.RECEIVE_TIMEOUT:
        return Failure(
            ApiInternalStatus.failure, ResponseMessage.RECEIVE_TIMEOUT);
      case DataSource.SEND_TIMEOUT:
        return Failure(ApiInternalStatus.failure, ResponseMessage.SEND_TIMEOUT);
      case DataSource.CACHE_ERROR:
        return Failure(ApiInternalStatus.failure, ResponseMessage.CACHE_ERROR);
      case DataSource.NO_INTERNET_CONNECTION:
        return Failure(ApiInternalStatus.noInternetConnection,
            ResponseMessage.NO_INTERNET_CONNECTION);
      case DataSource.DEFAULT:
        return Failure(ApiInternalStatus.failure, ResponseMessage.DEFAULT);
    }
  }
}

class ResponseCode {
  static const int BAD_REQUEST = 400;
  static const int FORBIDDEN = 403;
  static const int UNAUTHORIZED = 401;
  static const int NOT_FOUND = 404;
  static const int INTERNAL_SERVER_ERROR = 500;
}

class ResponseMessage {
  static const String SUCCESS = "Success";
  static const String NO_CONTENT = "No content";
  static const String BAD_REQUEST = "Bad Request, Try again later";
  static const String FORBIDDEN = "Forbidden request, Try again later";
  static const String UNAUTHORIZED = "User not authorized, Try again later";
  static const String NOT_FOUND =
      "The requested resource was not found, Try again later.";
  static const String INTERNAL_SERVER_ERROR =
      "Something went wrong on our end. Please try again later.";

  static const String CONNECT_TIMEOUT = "Connection timeout, Try again later";
  static const String CANCEL = "Request was cancelled, Try again later";
  static const String RECEIVE_TIMEOUT = "Receive timeout, Try again later";
  static const String SEND_TIMEOUT = "Send timeout, Try again later";
  static const String CACHE_ERROR = "Cache error, Try again later";
  static const String NO_INTERNET_CONNECTION =
      "Please check your internet connection";
  static const String DEFAULT = "Something went wrong";
}
