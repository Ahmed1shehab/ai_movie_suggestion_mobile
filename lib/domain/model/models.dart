import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const String _imageBaseUrl = "https://image.tmdb.org/t/p/w500";
const String _nullImage =
    "https://www.themoviedb.org/assets/2/v4/glyphicons/basic/glyphicons-basic-4-user-grey-d8fe957375c323f0334f07928e208921782cd6746bc2ceb9ad4bbcd6ab320bb7.svg";

////////////////////////////////// Onboarding ////////////////////////////////////
class SliderObject {
  String image;
  String title;
  String subTitle;

  SliderObject(
    this.image,
    this.title,
    this.subTitle,
  );
}

class SliderViewObject {
  SliderObject sliderObject;
  int numberOfSlides;
  int currentIndex;

  SliderViewObject(this.sliderObject, this.currentIndex, this.numberOfSlides);
}

////////////////////////////////// Login ////////////////////////////////////

class User {
  final String id;
  final String name;
  final String email;

  User({
    required this.id,
    required this.name,
    required this.email,
  });
}

class Auth {
  final String token;
  final User user;

  Auth({
    required this.token,
    required this.user,
  });
}

////////////////////////////////// register ////////////////////////////////////
class RegisterModel {
  final String message;

  RegisterModel(this.message);
}

////////////////////////////////// Verify Email ////////////////////////////////////
class VerifyEmailModel {
  final String message;

  VerifyEmailModel(this.message);
}

////////////////////////////////// Movie List //////////////////////////////////
class MovieEntity {
  final int id;
  final String title;
  final String overview;
  final String posterUrl;
  final String backdropUrl;
  final double voteAverage;
  final DateTime? releaseDate;
  final String year;
  final List<int> genres;
  final double popularity;

  MovieEntity({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterUrl,
    required this.backdropUrl,
    required this.voteAverage,
    required this.releaseDate,
    required this.year,
    required this.genres,
    required this.popularity,
  });
}

class MovieDetail {
  final int id;
  final String title;
  final String originalTitle;
  final String overview;
  final String posterUrl;
  final String backdropUrl;
  final double voteAverage;
  final int voteCount;
  final DateTime? releaseDate;
  final String year;
  final int runtime;
  final String runtimeFormatted;
  final int budget;
  final int revenue;
  final double popularity;
  final bool adult;
  final String homepage;
  final String? imdbId;
  final String originalLanguage;
  final String status;
  final String tagline;
  final List<Genre> genres;
  final List<ProductionCompany> productionCompanies;
  final List<ProductionCountry> productionCountries;
  final List<SpokenLanguage> spokenLanguages;
  final Collection? collection;

  MovieDetail({
    required this.id,
    required this.title,
    required this.originalTitle,
    required this.overview,
    required this.posterUrl,
    required this.backdropUrl,
    required this.voteAverage,
    required this.voteCount,
    required this.releaseDate,
    required this.year,
    required this.runtime,
    required this.runtimeFormatted,
    required this.budget,
    required this.revenue,
    required this.popularity,
    required this.adult,
    required this.homepage,
    required this.imdbId,
    required this.originalLanguage,
    required this.status,
    required this.tagline,
    required this.genres,
    required this.productionCompanies,
    required this.productionCountries,
    required this.spokenLanguages,
    required this.collection,
  });

  factory MovieDetail.fromJson(Map<String, dynamic> json) {
    final posterPath = json['poster_path'] as String?;
    final backdropPath = json['backdrop_path'] as String?;
    final releaseDateString = json['release_date'] as String?;
    DateTime? parsedReleaseDate;
    String year = '';
    if (releaseDateString != null && releaseDateString.isNotEmpty) {
      try {
        parsedReleaseDate = DateTime.parse(releaseDateString);
        year = DateFormat('yyyy').format(parsedReleaseDate);
      } catch (e) {
        // Handle parsing error if necessary
      }
    }

    final int runtime = json['runtime'] ?? 0;
    String runtimeFormatted = '';
    if (runtime > 0) {
      final int hours = runtime ~/ 60;
      final int minutes = runtime % 60;
      runtimeFormatted = '${hours}h ${minutes}m';
    }

    return MovieDetail(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      originalTitle: json['original_title'] as String? ?? '',
      overview: json['overview'] as String? ?? '',
      posterUrl: posterPath != null ? '$_imageBaseUrl$posterPath' : _nullImage,
      backdropUrl:
          backdropPath != null ? '$_imageBaseUrl$backdropPath' : _nullImage,
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      voteCount: json['vote_count'] as int? ?? 0,
      releaseDate: parsedReleaseDate,
      year: year,
      runtime: runtime,
      runtimeFormatted: runtimeFormatted,
      budget: json['budget'] as int? ?? 0,
      revenue: json['revenue'] as int? ?? 0,
      popularity: (json['popularity'] as num?)?.toDouble() ?? 0.0,
      adult: json['adult'] as bool? ?? false,
      homepage: json['homepage'] as String? ?? '',
      imdbId: json['imdb_id'] as String?,
      originalLanguage: json['original_language'] as String? ?? '',
      status: json['status'] as String? ?? '',
      tagline: json['tagline'] as String? ?? '',
      genres: (json['genres'] as List<dynamic>?)
              ?.map((e) => Genre.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      productionCompanies: (json['production_companies'] as List<dynamic>?)
              ?.map(
                  (e) => ProductionCompany.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      productionCountries: (json['production_countries'] as List<dynamic>?)
              ?.map(
                  (e) => ProductionCountry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      spokenLanguages: (json['spoken_languages'] as List<dynamic>?)
              ?.map((e) => SpokenLanguage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      collection: json['belongs_to_collection'] != null
          ? Collection.fromJson(
              json['belongs_to_collection'] as Map<String, dynamic>)
          : null,
    );
  }
}

class Genre {
  final int id;
  final String name;

  Genre({
    required this.id,
    required this.name,
  });

  factory Genre.fromJson(Map<String, dynamic> json) {
    return Genre(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
    );
  }
}

class ProductionCompany {
  final int id;
  final String name;
  final String logoUrl;
  final String originCountry;

  ProductionCompany({
    required this.id,
    required this.name,
    required this.logoUrl,
    required this.originCountry,
  });

  factory ProductionCompany.fromJson(Map<String, dynamic> json) {
    final logoPath = json['logo_path'] as String?;
    return ProductionCompany(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      logoUrl: logoPath != null ? '$_imageBaseUrl$logoPath' : _nullImage,
      originCountry: json['origin_country'] as String? ?? '',
    );
  }
}

class ProductionCountry {
  final String iso31661;
  final String name;

  ProductionCountry({
    required this.iso31661,
    required this.name,
  });

  factory ProductionCountry.fromJson(Map<String, dynamic> json) {
    return ProductionCountry(
      iso31661: json['iso_3166_1'] as String? ?? '',
      name: json['name'] as String? ?? '',
    );
  }
}

class SpokenLanguage {
  final String englishName;
  final String iso6391;
  final String name;

  SpokenLanguage({
    required this.englishName,
    required this.iso6391,
    required this.name,
  });

  factory SpokenLanguage.fromJson(Map<String, dynamic> json) {
    return SpokenLanguage(
      englishName: json['english_name'] as String? ?? '',
      iso6391: json['iso_639_1'] as String? ?? '',
      name: json['name'] as String? ?? '',
    );
  }
}

class Collection {
  final int id;
  final String name;
  final String posterUrl;
  final String backdropUrl;

  Collection({
    required this.id,
    required this.name,
    required this.posterUrl,
    required this.backdropUrl,
  });

  factory Collection.fromJson(Map<String, dynamic> json) {
    final posterPath = json['poster_path'] as String?;
    final backdropPath = json['backdrop_path'] as String?;
    return Collection(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      posterUrl: posterPath != null ? '$_imageBaseUrl$posterPath' : _nullImage,
      backdropUrl:
          backdropPath != null ? '$_imageBaseUrl$backdropPath' : _nullImage,
    );
  }
}

class NotificationData {
  final DateTime? selectedDate;
  final TimeOfDay? selectedTime;
  final bool isEnabled;

  NotificationData({
    this.selectedDate,
    this.selectedTime,
    this.isEnabled = false,
  });

  String get formattedDate {
    if (selectedDate == null) return 'Select Date';
    return '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}';
  }

  String get formattedTime {
    if (selectedTime == null) return 'Select Time';
    final hour = selectedTime!.hour.toString().padLeft(2, '0');
    final minute = selectedTime!.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  NotificationData copyWith({
    DateTime? selectedDate,
    TimeOfDay? selectedTime,
    bool? isEnabled,
  }) {
    return NotificationData(
      selectedDate: selectedDate ?? this.selectedDate,
      selectedTime: selectedTime ?? this.selectedTime,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}

/////////////////////////////////
///
class AddLikeModel {
  final String message;

  AddLikeModel({
    required this.message,
  });
}

class ChatHistoryModel {
  final String role;
  final dynamic message; // Can be String or MovieRecommendationModel
  final String id;
  final DateTime timestamp;

  ChatHistoryModel({
    required this.role,
    required this.message,
    required this.id,
    required this.timestamp,
  });
}

class MovieRecommendationModel {
  final String title;
  final String overview;
  final String posterUrl;
  final String imdbLink;
  final String trailer;
  final List<Genre> genres;
  final DateTime? releaseDate;
  final List<SpokenLanguage> spokenLanguages;
  final double voteAverage;
  final String year;

  MovieRecommendationModel({
    required this.title,
    required this.overview,
    required this.posterUrl,
    required this.imdbLink,
    required this.trailer,
    required this.genres,
    required this.releaseDate,
    required this.spokenLanguages,
    required this.voteAverage,
    required this.year,
  });
}

//////////////////////Send Notification Model////////////////////////////
class NotificationEntity {
  final String message;
  final DateTime date;
  final bool isRead;
  final String id;

  NotificationEntity({
    required this.message,
    required this.date,
    required this.isRead,
    required this.id,
  });
}

class SendNotificationEntity {
  final String message;
  final List<NotificationEntity> notifications;

  SendNotificationEntity({
    required this.message,
    required this.notifications,
  });
}

////////////////////////User Profile Model////////////////////////////
class UserProfileModel {
  final UserModel user;
  final List<String> likes;
  final List<NotificationEntity> notifications;
  final int credits;
  final List<ChatHistoryModel> chatHistory;

  UserProfileModel({
    required this.user,
    required this.likes,
    required this.notifications,
    required this.credits,
    required this.chatHistory,
  });
}

class UserModel {
  final String id;
  final bool isVerified;
  final String fullName;
  final String email;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int version;

  UserModel({
    required this.id,
    required this.isVerified,
    required this.fullName,
    required this.email,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
  });
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final MovieDetail? movieDetail;
  final bool? isError;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.movieDetail,
    this.isError,
  });
}
