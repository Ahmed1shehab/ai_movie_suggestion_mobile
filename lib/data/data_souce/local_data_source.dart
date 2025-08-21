import 'package:ai_movie_suggestion/data/network/error_handler.dart';
import 'package:ai_movie_suggestion/data/response/movie_list_response.dart';
import 'package:flutter/foundation.dart';

const CACHE_TOP_RATED_MOVIES = 'CACHE_TOP_RATED_MOVIES';
const CACHE_POPULAR_MOVIES = 'CACHE_POPULAR_MOVIES';
const CACHE_UPCOMING_MOVIES = 'CACHE_UPCOMING_MOVIES';
const CACHE_NOW_PLAYING_MOVIES = 'CACHE_NOW_PLAYING_MOVIES';
const CACHE_SIMILAR_MOVIES = 'CACHE_SIMILAR_MOVIES';
const CACHE_MOVIE_DETAILS = 'CACHE_MOVIE_DETAILS';
// Cache time interval: 24 hours in milliseconds
const CACHE_TIME_INTERVAL = 24 * 60 * 60 * 1000; // 24 hours in milliseconds

abstract class LocalDataSource {
  Future<MovieListResponse> topRatedMovies({int? page, String? language});
  Future<MovieListResponse> popularMovies({int? page, String? language});
  Future<MovieListResponse> upcomingMovies({int? page, String? language});
  Future<MovieDetailsResponse> movieDetails(int movieId, {String? language});
  Future<MovieListResponse> nowPlaying({int? page, String? language});
  Future<MovieListResponse> similarMovies(int movieId, {int? page, String? language});
  
  // Save methods for caching with language parameter
  Future<void> saveTopRatedMovies(MovieListResponse movieListResponse, {int? page, String? language});
  Future<void> savePopularMovies(MovieListResponse movieListResponse, {int? page, String? language});
  Future<void> saveUpcomingMovies(MovieListResponse movieListResponse, {int? page, String? language});
  Future<void> saveNowPlayingMovies(MovieListResponse movieListResponse, {int? page, String? language});
  Future<void> saveSimilarMovies(int movieId, MovieListResponse movieListResponse, {int? page, String? language});
  Future<void> saveMovieDetails(int movieId, MovieDetailsResponse movieDetailsResponse, {String? language});
  
  void clearCache();
  void removeFromCache(String cacheKey);
}

class LocalDataSourceImpl implements LocalDataSource {
  Map<String, CachedItem> cacheMap = Map();

  // FIXED: Generate consistent cache keys with proper null handling
  String _generateCacheKey(String baseKey, {int? movieId, int? page, String? language}) {
    String key = baseKey;
    if (movieId != null) key += '_$movieId';
    
    // Use consistent default values for page and language
    int pageToUse = page ?? 1;
    String languageToUse = language ?? 'en';
    
    key += '_page_$pageToUse';
    key += '_lang_$languageToUse';
    
    return key;
  }

  @override
  Future<MovieListResponse> topRatedMovies({int? page, String? language}) async {
    String cacheKey = _generateCacheKey(CACHE_TOP_RATED_MOVIES, page: page, language: language);
    CachedItem? cachedItem = cacheMap[cacheKey];
    
    if (kDebugMode) {
      print("🔍 Looking for cache key: $cacheKey");
      print("🗂️ Available cache keys: ${cacheMap.keys.toList()}");
      print("📦 Cache item found: ${cachedItem != null}");
      if (cachedItem != null) {
        print("⏰ Cache valid: ${cachedItem.isValid(CACHE_TIME_INTERVAL)}");
      }
    }
    
    if (cachedItem != null && cachedItem.isValid(CACHE_TIME_INTERVAL)) {
      if (kDebugMode) {
        print("✅ Cache hit for top rated movies");
      }
      return cachedItem.data as MovieListResponse;
    } else {
      if (kDebugMode) {
        print("❌ Cache miss for top rated movies");
      }
      throw ErrorHandler.handle(DataSource.CACHE_ERROR);
    }
  }

  @override
  Future<MovieListResponse> popularMovies({int? page, String? language}) async {
    String cacheKey = _generateCacheKey(CACHE_POPULAR_MOVIES, page: page, language: language);
    CachedItem? cachedItem = cacheMap[cacheKey];
    
    if (cachedItem != null && cachedItem.isValid(CACHE_TIME_INTERVAL)) {
      return cachedItem.data as MovieListResponse;
    } else {
      throw ErrorHandler.handle(DataSource.CACHE_ERROR);
    }
  }

  @override
  Future<MovieListResponse> upcomingMovies({int? page, String? language}) async {
    String cacheKey = _generateCacheKey(CACHE_UPCOMING_MOVIES, page: page, language: language);
    CachedItem? cachedItem = cacheMap[cacheKey];
    
    if (cachedItem != null && cachedItem.isValid(CACHE_TIME_INTERVAL)) {
      return cachedItem.data as MovieListResponse;
    } else {
      throw ErrorHandler.handle(DataSource.CACHE_ERROR);
    }
  }

  @override
  Future<MovieListResponse> nowPlaying({int? page, String? language}) async {
    String cacheKey = _generateCacheKey(CACHE_NOW_PLAYING_MOVIES, page: page, language: language);
    CachedItem? cachedItem = cacheMap[cacheKey];
    
    if (cachedItem != null && cachedItem.isValid(CACHE_TIME_INTERVAL)) {
      return cachedItem.data as MovieListResponse;
    } else {
      throw ErrorHandler.handle(DataSource.CACHE_ERROR);
    }
  }

  @override
  Future<MovieListResponse> similarMovies(int movieId, {int? page, String? language}) async {
    String cacheKey = _generateCacheKey(CACHE_SIMILAR_MOVIES, movieId: movieId, page: page, language: language);
    CachedItem? cachedItem = cacheMap[cacheKey];
    
    if (cachedItem != null && cachedItem.isValid(CACHE_TIME_INTERVAL)) {
      return cachedItem.data as MovieListResponse;
    } else {
      throw ErrorHandler.handle(DataSource.CACHE_ERROR);
    }
  }

  @override
  Future<MovieDetailsResponse> movieDetails(int movieId, {String? language}) async {
    String cacheKey = _generateCacheKey(CACHE_MOVIE_DETAILS, movieId: movieId, language: language);
    CachedItem? cachedItem = cacheMap[cacheKey];
    
    if (cachedItem != null && cachedItem.isValid(CACHE_TIME_INTERVAL)) {
      return cachedItem.data as MovieDetailsResponse;
    } else {
      throw ErrorHandler.handle(DataSource.CACHE_ERROR);
    }
  }

  // FIXED: Consistent parameter handling in save methods
  @override
  Future<void> saveTopRatedMovies(MovieListResponse movieListResponse, {int? page, String? language}) async {
    // Use the same logic as _generateCacheKey for consistency
    int pageToUse = page ?? movieListResponse.page ?? 1;
    String languageToUse = language ?? 'en';
    
    String cacheKey = _generateCacheKey(CACHE_TOP_RATED_MOVIES, 
        page: pageToUse, 
        language: languageToUse);
    
    cacheMap[cacheKey] = CachedItem(movieListResponse);
    
    if (kDebugMode) {
      print("💾 Saved to cache with key: $cacheKey");
      print("📊 Cache size: ${cacheMap.length}");
    }
  }

  @override
  Future<void> savePopularMovies(MovieListResponse movieListResponse, {int? page, String? language}) async {
    int pageToUse = page ?? movieListResponse.page ?? 1;
    String languageToUse = language ?? 'en';
    
    String cacheKey = _generateCacheKey(CACHE_POPULAR_MOVIES, 
        page: pageToUse, 
        language: languageToUse);
    cacheMap[cacheKey] = CachedItem(movieListResponse);
  }

  @override
  Future<void> saveUpcomingMovies(MovieListResponse movieListResponse, {int? page, String? language}) async {
    int pageToUse = page ?? movieListResponse.page ?? 1;
    String languageToUse = language ?? 'en';
    
    String cacheKey = _generateCacheKey(CACHE_UPCOMING_MOVIES, 
        page: pageToUse, 
        language: languageToUse);
    cacheMap[cacheKey] = CachedItem(movieListResponse);
  }

  @override
  Future<void> saveNowPlayingMovies(MovieListResponse movieListResponse, {int? page, String? language}) async {
    int pageToUse = page ?? movieListResponse.page ?? 1;
    String languageToUse = language ?? 'en';
    
    String cacheKey = _generateCacheKey(CACHE_NOW_PLAYING_MOVIES, 
        page: pageToUse, 
        language: languageToUse);
    cacheMap[cacheKey] = CachedItem(movieListResponse);
  }

  @override
  Future<void> saveSimilarMovies(int movieId, MovieListResponse movieListResponse, {int? page, String? language}) async {
    int pageToUse = page ?? movieListResponse.page ?? 1;
    String languageToUse = language ?? 'en';
    
    String cacheKey = _generateCacheKey(CACHE_SIMILAR_MOVIES, 
        movieId: movieId,
        page: pageToUse, 
        language: languageToUse);
    cacheMap[cacheKey] = CachedItem(movieListResponse);
  }

  @override
  Future<void> saveMovieDetails(int movieId, MovieDetailsResponse movieDetailsResponse, {String? language}) async {
    String languageToUse = language ?? 'en';
    
    String cacheKey = _generateCacheKey(CACHE_MOVIE_DETAILS, 
        movieId: movieId, 
        language: languageToUse);
    cacheMap[cacheKey] = CachedItem(movieDetailsResponse);
  }

  @override
  void clearCache() {
    cacheMap.clear();
  }

  @override
  void removeFromCache(String cacheKey) {
    cacheMap.remove(cacheKey);
  }

  // Helper method to remove expired cache items
  void removeExpiredItems() {
    cacheMap.removeWhere((key, cachedItem) => 
        !cachedItem.isValid(CACHE_TIME_INTERVAL));
  }

  // Helper method to get cache size
  int getCacheSize() {
    return cacheMap.length;
  }

  // Helper method to check if specific item is cached and valid
  bool isCached(String cacheKey) {
    CachedItem? cachedItem = cacheMap[cacheKey];
    return cachedItem != null && cachedItem.isValid(CACHE_TIME_INTERVAL);
  }

  // Helper method to get all cache keys (useful for debugging)
  List<String> getAllCacheKeys() {
    return cacheMap.keys.toList();
  }

  // Helper method to get cache statistics
  Map<String, dynamic> getCacheStats() {
    int totalItems = cacheMap.length;
    int validItems = 0;
    int expiredItems = 0;

    cacheMap.forEach((key, cachedItem) {
      if (cachedItem.isValid(CACHE_TIME_INTERVAL)) {
        validItems++;
      } else {
        expiredItems++;
      }
    });

    return {
      'totalItems': totalItems,
      'validItems': validItems,
      'expiredItems': expiredItems,
    };
  }
}

class CachedItem {
  dynamic data;
  int cacheTime = DateTime.now().millisecondsSinceEpoch;

  CachedItem(this.data);
}

extension CachedItemExtension on CachedItem {
  bool isValid(int expirationTimeInMillis) {
    int currentTimeInMillis = DateTime.now().millisecondsSinceEpoch;
    bool isValid = currentTimeInMillis - cacheTime <= expirationTimeInMillis;
    return isValid;
  }
}