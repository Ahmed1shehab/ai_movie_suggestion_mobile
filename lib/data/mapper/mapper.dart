// ignore_for_file: unnecessary_this

import 'package:ai_movie_suggestion/app/constants.dart';
import 'package:ai_movie_suggestion/data/network/failure.dart';
import 'package:ai_movie_suggestion/data/response/movie_list_response.dart';
import 'package:ai_movie_suggestion/data/response/response.dart';
import 'package:ai_movie_suggestion/domain/model/models.dart';
import 'package:ai_movie_suggestion/app/extensions.dart';
import 'package:ai_movie_suggestion/presentation/resources/string_manager.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

extension UserLoginMapper on UserLogin {
  ///////////////////////////////// login request mapper /////////////////////////////////
  User toDomain() {
    return User(
      id: this.id.orEmpty(),
      name: this.name.orEmpty(),
      email: this.email.orEmpty(),
    );
  }
}

extension LoginResponseMapper on LoginResponse {
  Either<Failure, Auth> toDomain() {
    if (token == null || user == null) {
      return Left(Failure(ApiInternalStatus.failure, AppStrings.dataFieldFail));
    }
    try {
      final authenticationSignIn = Auth(
        token: token ?? Constants.empty,
        user: user!.toDomain(),
      );

      return Right(authenticationSignIn);
    } catch (error) {
      return Left(Failure(ApiInternalStatus.failure, error.toString()));
    }
  }

  String? statusMessage() {
    switch (statusCode) {
      case 201:
        return AppStrings.loginSuccessful;
      default:
        return message ?? Constants.empty;
    }
  }
}
///////////////////////////////// register request mapper /////////////////////////////////

extension RegisterResponseMapper on RegisterResponse {
  RegisterModel toDomain() {
    return RegisterModel(message ?? '');
  }
}

///////////////////////////////// verify Email  mapper /////////////////////////////////

extension VerifyEmailResponseMapper on VerifyEmailResponse {
  VerifyEmailModel toDomain() {
    return VerifyEmailModel(message ?? '');
  }
}

///////////////////////////////// movie mapper /////////////////////////////////
extension MovieListResponseMapper on MovieListResponse {
  Either<Failure, List<MovieEntity>> toDomain() {
    try {
      final movieEntities = results
          .map((movie) => MovieEntity(
                id: movie.id,
                title: movie.displayTitle,
                overview: movie.overview ?? Constants.empty,
                posterUrl: movie.fullPosterUrl,
                backdropUrl: movie.fullBackdropUrl,
                voteAverage: movie.voteAverage ?? 0.0,
                releaseDate: movie.releaseDateParsed,
                year: movie.year,
                genres: movie.genreIds ?? [],
                popularity: movie.popularity ?? 0.0,
              ))
          .toList();

      return Right(movieEntities);
    } catch (error) {
      return Left(Failure(
        ApiInternalStatus.failure,
        error.toString(),
      ));
    }
  }
}

///////////////////////////////// movie details mapper /////////////////////////////////
extension MovieDetailsResponseMapper on MovieDetailsResponse {
  Either<Failure, MovieDetail> toDomain() {
    try {
      final movieDetail = MovieDetail(
        id: this.id ?? 0,
        title: displayTitle,
        originalTitle: originalTitle ?? Constants.empty,
        overview: overview ?? Constants.empty,
        posterUrl: fullPosterUrl,
        backdropUrl: fullBackdropUrl,
        voteAverage: voteAverage ?? 0.0,
        voteCount: voteCount ?? 0,
        releaseDate: releaseDateParsed,
        year: year,
        runtime: runtime ?? 0,
        runtimeFormatted: runtimeFormatted,
        budget: budget ?? 0,
        revenue: revenue ?? 0,
        popularity: popularity ?? 0.0,
        adult: adult ?? false,
        homepage: homepage ?? Constants.empty,
        imdbId: imdbId,
        originalLanguage: originalLanguage ?? Constants.empty,
        status: status ?? Constants.empty,
        tagline: tagline ?? Constants.empty,
        genres: genres?.map((genre) => genre.toDomain()).toList() ?? [],
        productionCompanies: productionCompanies
                ?.map((company) => company.toDomain())
                .toList() ??
            [],
        productionCountries: productionCountries
                ?.map((country) => country.toDomain())
                .toList() ??
            [],
        spokenLanguages:
            spokenLanguages?.map((language) => language.toDomain()).toList() ??
                [],
        collection: collection?.toDomain(),
      );

      return Right(movieDetail);
    } catch (error) {
      return Left(Failure(
        ApiInternalStatus.failure,
        error.toString(),
      ));
    }
  }
}

extension GenreResponseMapper on GenreResponse {
  Genre toDomain() {
    return Genre(
      id: this.id ?? 0,
      name: name ?? Constants.empty,
    );
  }
}

extension ProductionCompanyResponseMapper on ProductionCompanyResponse {
  ProductionCompany toDomain() {
    return ProductionCompany(
      id: this.id ?? 0,
      name: name ?? Constants.empty,
      logoUrl: fullLogoUrl,
      originCountry: originCountry ?? Constants.empty,
    );
  }
}

extension ProductionCountryResponseMapper on ProductionCountryResponse {
  ProductionCountry toDomain() {
    return ProductionCountry(
      iso31661: iso31661 ?? Constants.empty,
      name: name ?? Constants.empty,
    );
  }
}

extension SpokenLanguageResponseMapper on SpokenLanguageResponse {
  SpokenLanguage toDomain() {
    return SpokenLanguage(
      englishName: englishName ?? Constants.empty,
      iso6391: iso6391 ?? Constants.empty,
      name: name ?? Constants.empty,
    );
  }
}

extension CollectionResponseMapper on CollectionResponse {
  Collection toDomain() {
    return Collection(
      id: this.id ?? 0,
      name: name ?? Constants.empty,
      posterUrl: fullPosterUrl,
      backdropUrl: fullBackdropUrl,
    );
  }
}

extension AddLikeResponseMapper on AddLikeResponse {
  Either<Failure, AddLikeModel> toDomain() {
    if (this.message == null) {
      return Left(
          Failure(ApiInternalStatus.failure, AppStrings.noDataReceived));
    }

    try {
      final addLikeModel =
          AddLikeModel(message: message ?? AppStrings.likeAddedSuccessfully);

      return Right(addLikeModel);
    } catch (error) {
      return Left(Failure(ApiInternalStatus.failure, error.toString()));
    }
  }

  String? statusMessage() {
    switch (statusCode) {
      case 200:
      case 201:
        return message ?? AppStrings.likeAddedSuccessfully;
      default:
        return message ?? Constants.empty;
    }
  }
}

extension MovieRecommendationMapper on MovieRecommendation {
  MovieRecommendationModel toDomain() {
    DateTime? parsedReleaseDate;
    String year = '';

    try {
      parsedReleaseDate = DateTime.parse(releaseDate);
      year = parsedReleaseDate.year.toString();
    } catch (e) {
      // Handle parsing error
    }

    return MovieRecommendationModel(
      title: title,
      overview: overview,
      posterUrl: posterUrl,
      imdbLink: imdbLink,
      trailer: trailer,
      genres: genres.map((genre) => genre.toDomain()).toList(),
      releaseDate: parsedReleaseDate,
      spokenLanguages: spokenLanguages.map((lang) => lang.toDomain()).toList(),
      voteAverage: voteAverage,
      year: year,
    );
  }
}

extension GenreItemMapper on GenreItem {
  Genre toDomain() {
    return Genre(
      id: this.id,
      name: name,
    );
  }
}

extension SpokenLanguageItemMapper on SpokenLanguageItem {
  SpokenLanguage toDomain() {
    return SpokenLanguage(
      englishName: englishName,
      iso6391: iso6391,
      name: name,
    );
  }
}

/////////////////////////Send Notification Mapper/////////////////////////////////////////

extension SendNotificationResponseMapper on SendNotificationResponse {
  Either<Failure, SendNotificationEntity> toDomain() {
    if (notifications.isEmpty) {
      return Left(
          Failure(ApiInternalStatus.failure, AppStrings.noNotifications));
    }
    try {
      final notificationEntities = notifications
          .map((notification) => NotificationEntity(
                message: notification.message,
                date: notification.date,
                isRead: notification.isRead,
                id: notification.id,
              ))
          .toList();

      final entity = SendNotificationEntity(
        message: message ??
            AppStrings
                .notificationAdded, // Assuming message exists in BaseResponse
        notifications: notificationEntities,
      );

      return Right(entity);
    } catch (error) {
      return Left(Failure(ApiInternalStatus.failure, error.toString()));
    }
  }

  String? statusMessage() {
    switch (statusCode) {
      case 200:
        return message ?? AppStrings.notificationAdded;
      default:
        return message ?? Constants.empty;
    }
  }
}

extension NotificationResponseMapper on NotificationResponse {
  NotificationEntity toDomain() {
    return NotificationEntity(
      message: message,
      date: date,
      isRead: isRead,
      id: this.id,
    );
  }
}

////////////////////////// user Data model mapper //////////////////////////////
extension UserResponseMapper on UserProfileResponse {
  Either<Failure, UserProfileModel> toDomain() {
    try {
      final userProfileModel = UserProfileModel(
        user: user.toDomain(),
        likes: likes,
        notifications: notifications
            .map((notification) => notification.toDomain())
            .toList(),
        credits: credits,
        chatHistory: chatHistory.map((chat) => chat.toDomain()).toList(),
      );

      return Right(userProfileModel);
    } catch (error) {
      return Left(Failure(
        ApiInternalStatus.failure,
        error.toString(),
      ));
    }
  }

  String? statusMessage() {
    switch (statusCode) {
      case 200:
        return message ?? AppStrings.profileLoadedSuccessfully;
      default:
        return message ?? Constants.empty;
    }
  }
}

extension UserProfileDataMapper on UserProfileData {
  UserModel toDomain() {
    DateTime? createdAtParsed;
    DateTime? updatedAtParsed;

    try {
      createdAtParsed = DateTime.parse(createdAt);
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing createdAt: $createdAt - ${e.toString()}');
      }
      createdAtParsed = null;
    }

    try {
      updatedAtParsed = DateTime.parse(updatedAt);
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing updatedAt: $updatedAt - ${e.toString()}');
      }
      updatedAtParsed = null;
    }

    return UserModel(
      id: this.id,
      isVerified: isVerified,
      fullName: fullName,
      email: email,
      createdAt: createdAtParsed,
      updatedAt: updatedAtParsed,
      version: version,
    );
  }
}

extension ChatHistoryItemMapper on ChatHistoryItem {
  ChatHistoryModel toDomain() {
    DateTime parsedTimestamp;
    try {
      parsedTimestamp = DateTime.parse(timestamp);
    } catch (e) {
      parsedTimestamp = DateTime.now();
    }

    dynamic domainMessage = message;

    if (message is Map<String, dynamic>) {
      try {
        final movieRec = MovieRecommendation.fromJson(message);
        domainMessage = movieRec.toDomain();
      } catch (e) {
        domainMessage = message;
      }
    }

    return ChatHistoryModel(
      role: role,
      message: domainMessage,
      id: this.id,
      timestamp: parsedTimestamp,
    );
  }
}
