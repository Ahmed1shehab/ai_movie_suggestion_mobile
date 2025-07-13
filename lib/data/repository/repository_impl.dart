import 'package:ai_movie_suggestion/app/app_prefs.dart';
import 'package:ai_movie_suggestion/data/data_souce/remote_data_source.dart';
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
  final NetworkInfo _networkInfo;
  final AppPreferences _appPreferences;

  RepositoryImpl(
    this._remoteDataSource,
    this._networkInfo,
    this._appPreferences,
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

  // @override
  // Future<Either<Failure, MovieEntity>> movieDetails(int movieId,
  //     {String? language}) async {
  //   //todo implement
  //   return throw UnimplementedError();
  //   // if (await _networkInfo.isConnected) {
  //   //   try {
  //   //     final response =
  //   //         await _remoteDataSource.movieDetails(movieId, language: language);
  //   //     return Right(response.toDomain());
  //   //   } catch (error) {
  //   //     return Left(ErrorHandler.handle(error).failure);
  //   //   }
  //   // } else {
  //   //   return Left(DataSource.NO_INTERNET_CONNECTION.getFailure());
  //   // }
  // }

// Change the method signature to return List<MovieEntity>
  @override
  Future<Either<Failure, List<MovieEntity>>> movieRecommendations(int movieId,
      {int? page, String? language}) async {
    if (await _networkInfo.isConnected) {
      try {
        final response = await _remoteDataSource.movieRecommendations(movieId,
            page: page, language: language);
        return response.toDomain(); // This now matches the return type
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
    if (await _networkInfo.isConnected) {
      try {
        final response =
            await _remoteDataSource.nowPlaying(page: page, language: language);
        return response.toDomain(); // This now matches the return type
      } catch (error) {
        return Left(ErrorHandler.handle(error).failure);
      }
    } else {
      return Left(DataSource.NO_INTERNET_CONNECTION.getFailure());
    }
  }

  @override
  Future<Either<Failure, List<MovieEntity>>> searchMovies(String query,
      {int? page, String? language}) async {
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
    if (await _networkInfo.isConnected) {
      try {
        final response = await _remoteDataSource.similarMovies(movieId,
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
  Future<Either<Failure, List<MovieEntity>>> topRatedMovies(
      {int? page, String? language}) async {
    if (await _networkInfo.isConnected) {
      try {
        final response = await _remoteDataSource.topRatedMovies(
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
  Future<Either<Failure, List<MovieEntity>>> popularMovies(
      {int? page, String? language}) async {
    if (await _networkInfo.isConnected) {
      try {
        final response = await _remoteDataSource.popularMovies(
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
  Future<Either<Failure, List<MovieEntity>>> upcomingMovies(
      {int? page, String? language}) async {
    if (await _networkInfo.isConnected) {
      try {
        final response = await _remoteDataSource.upcomingMovies(
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
  Future<Either<Failure, List<MovieDetail>>> movieDetails(int movieId,
      {String? language}) {
    // TODO: implement movieDetails
    throw UnimplementedError();
  }
}
