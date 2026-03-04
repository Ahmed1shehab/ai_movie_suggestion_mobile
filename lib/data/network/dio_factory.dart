import 'package:ai_movie_suggestion/app/app_prefs.dart';
import 'package:ai_movie_suggestion/app/constants.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

const String applicationJson = "application/json";
const String accept = "accept";
const String authorization = "authorization";
const String defaultLanguage = "language";

class AuthInterceptor extends Interceptor {
  final AppPreferences _appPreferences;

  AuthInterceptor(this._appPreferences);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Get fresh token for every request
    String? token = await _appPreferences.getAccessToken();
    
    if (token != null && token.isNotEmpty) {
      options.headers['authorization'] = 'Bearer $token';
      debugPrint('🔑 [AuthInterceptor] Added token to request');
    } else {
      debugPrint('⚠️ [AuthInterceptor] No token available');
    }
    
    super.onRequest(options, handler);
  }
}

class DioFactory {
  final AppPreferences _appPreferences;

  DioFactory(this._appPreferences);

  Future<Dio> getDio() async {
    Dio dio = Dio();

    String language = await _appPreferences.getAppLanguage();

    debugPrint('🔧 [DioFactory] Creating Dio instance');
    debugPrint('🔧 [DioFactory] Base URL: ${Constants.baseUrl}');
    debugPrint('🔧 [DioFactory] Language: $language');

    // Set base options WITHOUT static token
    dio.options = BaseOptions(
      baseUrl: Constants.baseUrl,
      headers: {
        accept: applicationJson,
        defaultLanguage: language,
      },
      receiveTimeout: Constants.apiTimeOut,
      sendTimeout: Constants.apiTimeOut,
      connectTimeout: Constants.apiTimeOut,
    );

    // Add auth interceptor FIRST to add token dynamically
    dio.interceptors.add(AuthInterceptor(_appPreferences));

    if (kDebugMode) {
      dio.interceptors.add(PrettyDioLogger(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
        compact: false,
        maxWidth: 90,
      ));
    }

    return dio;
  }

  // New method for movie API (TMDB)
  Future<Dio> getMovieDio() async {
    Dio dio = Dio();

    String language = await _appPreferences.getAppLanguage();

    debugPrint('🎬 [DioFactory] Creating Movie Dio instance');
    debugPrint('🎬 [DioFactory] Base URL: ${Constants.movieBaseUrl}');

    dio.options = BaseOptions(
      baseUrl: Constants.movieBaseUrl,
      headers: {
        accept: applicationJson,
        defaultLanguage: language,
      },
      receiveTimeout: Constants.apiTimeOut,
      sendTimeout: Constants.apiTimeOut,
      connectTimeout: Constants.apiTimeOut,
    );

    if (kDebugMode) {
      dio.interceptors.add(PrettyDioLogger(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
        compact: false,
        maxWidth: 90,
      ));
    }

    return dio;
  }
}