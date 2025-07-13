// ignore_for_file: unnecessary_this

import 'package:ai_movie_suggestion/app/constants.dart';
import 'package:ai_movie_suggestion/data/network/failure.dart';
import 'package:ai_movie_suggestion/data/response/movie_list_response.dart';
import 'package:ai_movie_suggestion/data/response/response.dart';
import 'package:ai_movie_suggestion/domain/model/models.dart';
import 'package:ai_movie_suggestion/app/extensions.dart';
import 'package:ai_movie_suggestion/presentation/resources/string_manager.dart';
import 'package:dartz/dartz.dart';

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

// Mapper
class MovieMapper {
  static MovieDetail fromResponse(MovieDetailResponse response) {
    return MovieDetail(
      isAdult: response.adult,
      backdropPath: response.backdropPath,
      collection: response.belongsToCollection != null
          ? MovieCollection(
              id: response.belongsToCollection!.id,
              name: response.belongsToCollection!.name,
              posterPath: response.belongsToCollection!.posterPath,
              backdropPath: response.belongsToCollection!.backdropPath,
            )
          : null,
      budget: response.budget,
      genres: response.genres
          .map((genre) => Genre(
                id: genre.id,
                name: genre.name,
              ))
          .toList(),
      homepage: response.homepage?.isEmpty == true ? null : response.homepage,
      id: response.id,
      imdbId: response.imdbId,
      originCountries: response.originCountry,
      originalLanguage: response.originalLanguage,
      originalTitle: response.originalTitle,
      overview: response.overview,
      popularity: response.popularity,
      posterPath: response.posterPath,
      productionCompanies: response.productionCompanies
          .map((company) => ProductionCompany(
                id: company.id,
                logoPath: company.logoPath,
                name: company.name,
                originCountry: company.originCountry,
              ))
          .toList(),
      productionCountries: response.productionCountries
          .map((country) => ProductionCountry(
                countryCode: country.iso31661,
                name: country.name,
              ))
          .toList(),
      releaseDate: _parseDate(response.releaseDate),
      revenue: response.revenue,
      runtime: response.runtime,
      spokenLanguages: response.spokenLanguages
          .map((language) => SpokenLanguage(
                englishName: language.englishName,
                languageCode: language.iso6391,
                name: language.name,
              ))
          .toList(),
      tagline: response.tagline?.isEmpty == true ? null : response.tagline,
      title: response.title,
      hasVideo: response.video,
      voteAverage: response.voteAverage,
      voteCount: response.voteCount,
    );
  }

  static DateTime? _parseDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }
}
