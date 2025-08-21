import 'package:ai_movie_suggestion/app/app_prefs.dart';
import 'package:ai_movie_suggestion/app/extensions.dart';
import 'package:ai_movie_suggestion/data/data_souce/remote_data_source.dart';
import 'package:ai_movie_suggestion/data/data_souce/local_data_source.dart';
import 'package:ai_movie_suggestion/data/data_souce/user_profile_local_data_source.dart';
import 'package:ai_movie_suggestion/data/mapper/mapper.dart';
import 'package:ai_movie_suggestion/data/network/error_handler.dart';
import 'package:ai_movie_suggestion/data/network/failure.dart';
import 'package:ai_movie_suggestion/data/network/network_info.dart';
import 'package:ai_movie_suggestion/data/network/requests.dart';
import 'package:ai_movie_suggestion/domain/model/models.dart';
import 'package:ai_movie_suggestion/domain/repository/repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

class RepositoryImpl extends Repository {
  final RemoteDataSource _remoteDataSource;
  final LocalDataSource _localDataSource;
  final UserProfileLocalDataSource _userProfileLocalDataSource;
  final NetworkInfo _networkInfo;
  final AppPreferences _appPreferences;

  RepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._networkInfo,
    this._appPreferences,
    this._userProfileLocalDataSource,
  );

  @override
  Future<Either<Failure, Auth>> login(LoginRequest loginRequest) async {
    if (await _networkInfo.isConnected) {
      try {
        final response = await _remoteDataSource.login(loginRequest);
        if (response.token != null) {
          await _appPreferences.saveAccessToken(response.token!);
          if (kDebugMode) {
            print("Token is saved successfully");
          }
        } else {
          if (kDebugMode) {
            print("Access Token is null");
          }
        }
        return response.toDomain();
      } catch (error) {
        if (kDebugMode) {
          print("Exception caught during login: $error");
        }
        return Left(ErrorHandler.handle(error).failure);
      }
    } else {
      return Left(DataSource.NO_INTERNET_CONNECTION.getFailure());
    }
  }

  @override
  Future<Either<Failure, RegisterModel>> register(
      RegisterRequest registerRequest) async {
    if (await _networkInfo.isConnected) {
      try {
        final response = await _remoteDataSource.register(registerRequest);
        return Right(response.toDomain());
      } catch (error) {
        if (kDebugMode) {
          print("Exception caught during register: $error");
        }
        return Left(ErrorHandler.handle(error).failure);
      }
    } else {
      return Left(DataSource.NO_INTERNET_CONNECTION.getFailure());
    }
  }

  @override
  Future<Either<Failure, VerifyEmailModel>> verifyEmail(
      VerifyEmailRequest verifyEmailRequest) async {
    if (await _networkInfo.isConnected) {
      try {
        final response =
            await _remoteDataSource.verifyEmail(verifyEmailRequest);
        return Right(response.toDomain());
      } catch (error) {
        if (kDebugMode) {
          print("Exception caught during verifying email: $error");
        }
        return Left(ErrorHandler.handle(error).failure);
      }
    } else {
      return Left(DataSource.NO_INTERNET_CONNECTION.getFailure());
    }
  }

  @override
  Future<Either<Failure, List<MovieEntity>>> movieRecommendations(int movieId,
      {int? page, String? language}) async {
    // Recommendations are typically not cached as they change frequently
    if (await _networkInfo.isConnected) {
      try {
        final response = await _remoteDataSource.movieRecommendations(movieId,
            page: page, language: language);
        return response.toDomain();
      } catch (error) {
        return Left(ErrorHandler.handle(error).failure);
      }
    } else {
      return Left(DataSource.NO_INTERNET_CONNECTION.getFailure());
    }
  }

  @override
  Future<Either<Failure, List<MovieEntity>>> nowPlaying(
      {int? page, String? language}) async {
    try {
      // Try to get from cache first
      final cachedResponse =
          await _localDataSource.nowPlaying(page: page, language: language);
      if (kDebugMode) {
        print("Retrieved now playing movies from cache");
      }
      return cachedResponse.toDomain();
    } catch (cacheError) {
      // If cache fails, check network and get from remote
      if (await _networkInfo.isConnected) {
        try {
          final response = await _remoteDataSource.nowPlaying(
              page: page, language: language);
          // Save to cache for future use
          await _localDataSource.saveNowPlayingMovies(response,
              page: page, language: language);
          if (kDebugMode) {
            print(
                "Retrieved now playing movies from network and saved to cache");
          }
          return response.toDomain();
        } catch (error) {
          return Left(ErrorHandler.handle(error).failure);
        }
      } else {
        return Left(DataSource.NO_INTERNET_CONNECTION.getFailure());
      }
    }
  }

  @override
  Future<Either<Failure, List<MovieEntity>>> searchMovies(String query,
      {int? page, String? language}) async {
    // Search is typically not cached as it's dynamic
    if (await _networkInfo.isConnected) {
      try {
        final response = await _remoteDataSource.searchMovies(query,
            page: page, language: language);
        return response.toDomain();
      } catch (error) {
        return Left(ErrorHandler.handle(error).failure);
      }
    } else {
      return Left(DataSource.NO_INTERNET_CONNECTION.getFailure());
    }
  }

  @override
  Future<Either<Failure, List<MovieEntity>>> similarMovies(int movieId,
      {int? page, String? language}) async {
    try {
      // Try to get from cache first
      final cachedResponse = await _localDataSource.similarMovies(movieId,
          page: page, language: language);
      if (kDebugMode) {
        print("Retrieved similar movies from cache");
      }
      return cachedResponse.toDomain();
    } catch (cacheError) {
      // If cache fails, check network and get from remote
      if (await _networkInfo.isConnected) {
        try {
          final response = await _remoteDataSource.similarMovies(movieId,
              page: page, language: language);
          // Save to cache for future use
          await _localDataSource.saveSimilarMovies(movieId, response,
              page: page, language: language);
          if (kDebugMode) {
            print("Retrieved similar movies from network and saved to cache");
          }
          return response.toDomain();
        } catch (error) {
          return Left(ErrorHandler.handle(error).failure);
        }
      } else {
        return Left(DataSource.NO_INTERNET_CONNECTION.getFailure());
      }
    }
  }

  @override
  Future<Either<Failure, List<MovieEntity>>> topRatedMovies(
      {int? page, String? language}) async {
    debugPrint("🔍 Attempting to get top rated movies from cache");
    debugPrint("📋 Parameters: page=$page, language=$language");

    try {
      final cachedResponse =
          await _localDataSource.topRatedMovies(page: page, language: language);
      debugPrint("✅ Retrieved from cache successfully");
      return cachedResponse.toDomain();
    } catch (cacheError) {
      debugPrint("❌ Cache miss: $cacheError");

      if (await _networkInfo.isConnected) {
        try {
          debugPrint("🌐 Fetching from network...");
          final response = await _remoteDataSource.topRatedMovies(
              page: page, language: language);
          await _localDataSource.saveTopRatedMovies(response,
              page: page, language: language);
          debugPrint("✅ Network fetch successful, saved to cache");
          return response.toDomain();
        } catch (error) {
          debugPrint("❌ Network error: $error");
          return Left(ErrorHandler.handle(error).failure);
        }
      } else {
        debugPrint("❌ No internet connection");
        return Left(DataSource.NO_INTERNET_CONNECTION.getFailure());
      }
    }
  }

  @override
  Future<Either<Failure, List<MovieEntity>>> popularMovies(
      {int? page, String? language}) async {
    try {
      // Try to get from cache first
      final cachedResponse =
          await _localDataSource.popularMovies(page: page, language: language);
      if (kDebugMode) {
        print("Retrieved popular movies from cache");
      }
      return cachedResponse.toDomain();
    } catch (cacheError) {
      // If cache fails, check network and get from remote
      if (await _networkInfo.isConnected) {
        try {
          final response = await _remoteDataSource.popularMovies(
              page: page, language: language);
          // Save to cache for future use
          await _localDataSource.savePopularMovies(response,
              page: page, language: language);
          if (kDebugMode) {
            print("Retrieved popular movies from network and saved to cache");
          }
          return response.toDomain();
        } catch (error) {
          return Left(ErrorHandler.handle(error).failure);
        }
      } else {
        return Left(DataSource.NO_INTERNET_CONNECTION.getFailure());
      }
    }
  }

  @override
  Future<Either<Failure, List<MovieEntity>>> upcomingMovies(
      {int? page, String? language}) async {
    try {
      // Try to get from cache first
      final cachedResponse =
          await _localDataSource.upcomingMovies(page: page, language: language);
      if (kDebugMode) {
        print("Retrieved upcoming movies from cache");
      }
      return cachedResponse.toDomain();
    } catch (cacheError) {
      // If cache fails, check network and get from remote
      if (await _networkInfo.isConnected) {
        try {
          final response = await _remoteDataSource.upcomingMovies(
              page: page, language: language);
          // Save to cache for future use
          await _localDataSource.saveUpcomingMovies(response,
              page: page, language: language);
          if (kDebugMode) {
            print("Retrieved upcoming movies from network and saved to cache");
          }
          return response.toDomain();
        } catch (error) {
          return Left(ErrorHandler.handle(error).failure);
        }
      } else {
        return Left(DataSource.NO_INTERNET_CONNECTION.getFailure());
      }
    }
  }

  @override
  Future<Either<Failure, MovieDetail>> movieDetails(int movieId,
      {String? language}) async {
    try {
      // Try to get from cache first
      final cachedResponse =
          await _localDataSource.movieDetails(movieId, language: language);
      if (kDebugMode) {
        print("Retrieved movie details from cache");
      }
      return cachedResponse.toDomain();
    } catch (cacheError) {
      // If cache fails, check network and get from remote
      if (await _networkInfo.isConnected) {
        try {
          final response =
              await _remoteDataSource.movieDetails(movieId, language: language);
          // Save to cache for future use
          await _localDataSource.saveMovieDetails(movieId, response,
              language: language);
          if (kDebugMode) {
            print("Retrieved movie details from network and saved to cache");
          }
          return response.toDomain();
        } catch (error) {
          if (kDebugMode) {
            print("Exception caught during movie details: $error");
          }
          return Left(ErrorHandler.handle(error).failure);
        }
      } else {
        return Left(DataSource.NO_INTERNET_CONNECTION.getFailure());
      }
    }
  }

  @override
  Future<Either<Failure, AddLikeModel>> addLike(

      /// Adds a like to a movie using the remote data source.
      ///
      /// If the network is connected, attempts to add the like to the remote data source.
      /// If the network is not connected, returns a [Left] value with a
      /// [DataSource.NO_INTERNET_CONNECTION] failure.
      ///
      /// If the remote data source throws an exception, catches the exception and
      /// returns a [Left] value with a failure.
      ///
      AddLikeRequest addLIkeRequest) async {
    if (await _networkInfo.isConnected) {
      try {
        final response = await _remoteDataSource.addLike(addLIkeRequest);
        return response.toDomain();
      } catch (error) {
        if (kDebugMode) {
          print("Exception caught during add like: $error");
        }
        return Left(ErrorHandler.handle(error).failure);
      }
    } else {
      return Left(DataSource.NO_INTERNET_CONNECTION.getFailure());
    }
  }

  @override
  Future<Either<Failure, SendNotificationEntity>> sendNotifications(
      SendNotificationsRequest sendNotificationsRequest) async {
    if (await _networkInfo.isConnected) {
      try {
        final response =
            await _remoteDataSource.sendNotifications(sendNotificationsRequest);
        return response.toDomain();
      } catch (error) {
        if (kDebugMode) {
          print("Exception caught during send notifications: $error");
        }
        return Left(ErrorHandler.handle(error).failure);
      }
    } else {
      return Left(DataSource.NO_INTERNET_CONNECTION.getFailure());
    }
  }

  // Additional helper methods for cache management
  void clearMovieCache() {
    _localDataSource.clearCache();
    if (kDebugMode) {
      print("Movie cache cleared");
    }
  }

  void removeExpiredCacheItems() {
    if (_localDataSource is LocalDataSourceImpl) {
      (_localDataSource as LocalDataSourceImpl).removeExpiredItems();
      if (kDebugMode) {
        print("Expired cache items removed");
      }
    }
  }

  int getCacheSize() {
    if (_localDataSource is LocalDataSourceImpl) {
      return (_localDataSource as LocalDataSourceImpl).getCacheSize();
    }
    return 0;
  }

  @override
  Future<Either<Failure, MovieDetail>> sendPrompt(
      SendPromptRequest sendPrompt) async {
    if (await _networkInfo.isConnected) {
      try {
        final response = await _remoteDataSource.sendPrompt(sendPrompt);

        if (kDebugMode) {
          print("Promt sent succesfully");
        }
        return response.toDomain();
      } catch (error) {
        if (kDebugMode) {
          print("Exception caught during sending prompt: $error");
        }
        return Left(ErrorHandler.handle(error).failure);
      }
    } else {
      return Left(DataSource.NO_INTERNET_CONNECTION.getFailure());
    }
  }

  @override
  Future<Either<Failure, UserProfileModel>> getUserData() async {
    final String? token = await _appPreferences.getAccessToken();
    if (token == null) {
      if (kDebugMode) {
        print("❌ No access token found");
      }
      return Left(DataSource.UNAUTHORIZED.getFailure());
    }
    String userId = token;
    debugPrint(
        "🔍 Attempting to get user profile from cache for user: $userId");
    try {
      final cachedResponse =
          await _userProfileLocalDataSource.getUserProfile(userId);
      debugPrint("✅ Retrieved user profile from cache");
      return cachedResponse.toDomain();
    } catch (cacheError) {
      debugPrint("❌ User profile cache miss: $cacheError");

      // If cache fails, check network and get from remote
      if (await _networkInfo.isConnected) {
        try {
          debugPrint("🌐 Fetching user profile from network...");
          final response = await _remoteDataSource.getUserData();
          await _userProfileLocalDataSource.saveUserProfile(userId, response);
          debugPrint("✅ Network fetch successful, saved user profile to cache");
          if (kDebugMode) {
            print("User profile data retrieved successfully");
          }
          return response.toDomain();
        } catch (error) {
          debugPrint("❌ Network error: $error");
          if (kDebugMode) {
            print("Exception caught during getting user data: $error");
          }
          return Left(ErrorHandler.handle(error).failure);
        }
      } else {
        debugPrint("❌ No internet connection");
        return Left(DataSource.NO_INTERNET_CONNECTION.getFailure());
      }
    }
  }
}
