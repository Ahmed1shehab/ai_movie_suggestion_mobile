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