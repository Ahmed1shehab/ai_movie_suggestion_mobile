import 'package:ai_movie_suggestion/app/app_prefs.dart';
import 'package:ai_movie_suggestion/app/constants.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

const String applicationJson = "application/json";
const String accept = "accept";
const String authorization = "authorization";
const String defaultLanguage = "language";

class DioFactory {
  final AppPreferences _appPreferences;

  DioFactory(this._appPreferences);

  Future<Dio> getDio() async {
    Dio dio = Dio();

    String language = await _appPreferences.getAppLanguage();
    String? token = await _appPreferences.getAccessToken();

    // Set base options without content-type
    dio.options = BaseOptions(
      baseUrl: Constants.baseUrl,
      headers: {
        accept: applicationJson,
        if (token != null) authorization: 'Bearer $token',
        defaultLanguage: language,
      },
      receiveTimeout: Constants.apiTimeOut,
      sendTimeout: Constants.apiTimeOut,
    );

    if (kDebugMode) {
      dio.interceptors.add(PrettyDioLogger(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
      ));
    }

    return dio;
  }

// New method for movie API (TMDB)
  Future<Dio> getMovieDio() async {
    Dio dio = Dio();

    String language = await _appPreferences.getAppLanguage();

    dio.options = BaseOptions(
      baseUrl: Constants.movieBaseUrl,
      headers: {
        accept: applicationJson,
        defaultLanguage: language,
      },
      receiveTimeout: Constants.apiTimeOut,
      sendTimeout: Constants.apiTimeOut,
    );

    if (kDebugMode) {
      dio.interceptors.add(PrettyDioLogger(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
      ));
    }

    return dio;
  }
}
