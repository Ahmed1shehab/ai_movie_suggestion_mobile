import 'package:flutter_dotenv/flutter_dotenv.dart';

class Constants {
  // Base API URLs from .env
 static String get baseUrl => dotenv.env['BASE_URL'] ?? "";
  static String get movieBaseUrl => dotenv.env['MOVIE_BASE_URL'] ?? "";
  static String get apiKey => dotenv.env['API_MOVIE_KEY'] ?? "";

  // General constants
  static const String empty = "";
  static const int zero = 0;
  static const Duration apiTimeOut = Duration(seconds: 60);
  static const String token = "Send Token Here";
  static const String nullString = "null data";

  // TMDB URLs
  static String get nowPlayingUrl => '$movieBaseUrl/movie/now_playing?api_key=$apiKey';
  static String get topRatedUrl => '$movieBaseUrl/movie/top_rated?api_key=$apiKey';
  static String movieDetailUrl(int movieId) => '$movieBaseUrl/movie/$movieId?api_key=$apiKey';
  static String searchMovieUrl(String query) =>
      '$movieBaseUrl/search/movie?query=$query&api_key=$apiKey';
}
