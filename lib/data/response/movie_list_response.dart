import 'package:ai_movie_suggestion/data/convertor/num_convertor.dart';
import 'package:ai_movie_suggestion/data/response/response.dart';
import 'package:json_annotation/json_annotation.dart';

part 'movie_list_response.g.dart';

@JsonSerializable()
class MovieListResponse extends BaseResponse {
  final int? page;
  final List<Movie> results;
  @JsonKey(name: 'total_pages')
  final int? totalPages;
  @JsonKey(name: 'total_results')
  final int? totalResults;
  final DateRange? dates;

  MovieListResponse({
    this.page,
    required this.results,
    this.totalPages,
    this.totalResults,
    this.dates,
  });

  factory MovieListResponse.fromJson(Map<String, dynamic> json) =>
      _$MovieListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MovieListResponseToJson(this);
}

@JsonSerializable()
class DateRange {
  final String? maximum;
  final String? minimum;

  DateRange({this.maximum, this.minimum});

  factory DateRange.fromJson(Map<String, dynamic> json) =>
      _$DateRangeFromJson(json);

  Map<String, dynamic> toJson() => _$DateRangeToJson(this);

  DateTime? get maximumDate =>
      maximum != null ? DateTime.tryParse(maximum!) : null;
  DateTime? get minimumDate =>
      minimum != null ? DateTime.tryParse(minimum!) : null;
}

@JsonSerializable()
class Movie {
  final bool? adult;
  @JsonKey(name: 'backdrop_path')
  final String? backdropPath;
  @JsonKey(name: 'genre_ids')
  final List<int>? genreIds;
  final int id;
  @JsonKey(name: 'original_language')
  final String? originalLanguage;
  @JsonKey(name: 'original_title')
  final String? originalTitle;
  final String? overview;
  final double? popularity;
  @JsonKey(name: 'poster_path')
  final String? posterPath;
  @JsonKey(name: 'release_date')
  final String? releaseDate;
  final String? title;
  final bool? video;
  @JsonKey(name: 'vote_average')
  final double? voteAverage;
  @JsonKey(name: 'vote_count')
  final int? voteCount;

  Movie({
    this.adult,
    this.backdropPath,
    this.genreIds,
    required this.id,
    this.originalLanguage,
    this.originalTitle,
    this.overview,
    this.popularity,
    this.posterPath,
    this.releaseDate,
    this.title,
    this.video,
    this.voteAverage,
    this.voteCount,
  });

  factory Movie.fromJson(Map<String, dynamic> json) => _$MovieFromJson(json);

  Map<String, dynamic> toJson() => _$MovieToJson(this);

  // Helper methods
  String get fullPosterUrl =>
      posterPath != null ? 'https://image.tmdb.org/t/p/w500$posterPath' : '';

  String get fullBackdropUrl => backdropPath != null
      ? 'https://image.tmdb.org/t/p/w1280$backdropPath'
      : '';

  DateTime? get releaseDateParsed =>
      releaseDate != null ? DateTime.tryParse(releaseDate!) : null;

  String get displayTitle => title ?? originalTitle ?? 'Unknown Title';

  String get year => releaseDateParsed?.year.toString() ?? 'Unknown Year';
}

////////////////////////////////////////////////////////////////////////////////////////
// movie_details_response.dart

@JsonSerializable()
class MovieDetailsResponse {
  @JsonKey(name: 'id')
  final int? id;
  
  @JsonKey(name: 'title')
  final String? title;
  
  @JsonKey(name: 'original_title')
  final String? originalTitle;
  
  @JsonKey(name: 'overview')
  final String? overview;
  
  @JsonKey(name: 'poster_path')
  final String? posterPath;
  
  @JsonKey(name: 'backdrop_path')
  final String? backdropPath;
  
  @JsonKey(name: 'vote_average')
  final double? voteAverage;
  
  @JsonKey(name: 'vote_count')
  final int? voteCount;
  
  @JsonKey(name: 'release_date')
  final String? releaseDate;
  
  @JsonKey(name: 'runtime')
  final int? runtime;
  
  @JsonKey(name: 'budget')
  final int? budget;
  
  @JsonKey(name: 'revenue')
  final int? revenue;
  
  @JsonKey(name: 'popularity')
  final double? popularity;
  
  @JsonKey(name: 'adult')
  final bool? adult;
  
  @JsonKey(name: 'homepage')
  final String? homepage;
  
  @JsonKey(name: 'imdb_id')
  final String? imdbId;
  
  @JsonKey(name: 'original_language')
  final String? originalLanguage;
  
  @JsonKey(name: 'status')
  final String? status;
  
  @JsonKey(name: 'tagline')
  final String? tagline;
  
  @JsonKey(name: 'genres')
  final List<GenreResponse>? genres;
  
  @JsonKey(name: 'production_companies')
  final List<ProductionCompanyResponse>? productionCompanies;
  
  @JsonKey(name: 'production_countries')
  final List<ProductionCountryResponse>? productionCountries;
  
  @JsonKey(name: 'spoken_languages')
  final List<SpokenLanguageResponse>? spokenLanguages;
  
  @JsonKey(name: 'belongs_to_collection')
  final CollectionResponse? collection;

  const MovieDetailsResponse({
    this.id,
    this.title,
    this.originalTitle,
    this.overview,
    this.posterPath,
    this.backdropPath,
    this.voteAverage,
    this.voteCount,
    this.releaseDate,
    this.runtime,
    this.budget,
    this.revenue,
    this.popularity,
    this.adult,
    this.homepage,
    this.imdbId,
    this.originalLanguage,
    this.status,
    this.tagline,
    this.genres,
    this.productionCompanies,
    this.productionCountries,
    this.spokenLanguages,
    this.collection,
  });

  factory MovieDetailsResponse.fromJson(Map<String, dynamic> json) =>
      _$MovieDetailsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MovieDetailsResponseToJson(this);

  // Helper methods for full URLs
  String get fullPosterUrl => posterPath != null 
      ? 'https://image.tmdb.org/t/p/w500$posterPath' 
      : '';
  
  String get fullBackdropUrl => backdropPath != null 
      ? 'https://image.tmdb.org/t/p/w780$backdropPath' 
      : '';
  
  DateTime? get releaseDateParsed => releaseDate != null 
      ? DateTime.tryParse(releaseDate!) 
      : null;
  
  String get year => releaseDateParsed?.year.toString() ?? '';
  
  String get displayTitle => title ?? originalTitle ?? '';
  
  String get runtimeFormatted {
    if (runtime == null) return '';
    final hours = runtime! ~/ 60;
    final minutes = runtime! % 60;
    return hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';
  }
}

@JsonSerializable()
class GenreResponse {
  @JsonKey(name: 'id')
  final int? id;
  
  @JsonKey(name: 'name')
  final String? name;

  const GenreResponse({
    this.id,
    this.name,
  });

  factory GenreResponse.fromJson(Map<String, dynamic> json) =>
      _$GenreResponseFromJson(json);

  Map<String, dynamic> toJson() => _$GenreResponseToJson(this);
}

@JsonSerializable()
class ProductionCompanyResponse {
  @JsonKey(name: 'id')
  final int? id;
  
  @JsonKey(name: 'name')
  final String? name;
  
  @JsonKey(name: 'logo_path')
  final String? logoPath;
  
  @JsonKey(name: 'origin_country')
  final String? originCountry;

  const ProductionCompanyResponse({
    this.id,
    this.name,
    this.logoPath,
    this.originCountry,
  });

  factory ProductionCompanyResponse.fromJson(Map<String, dynamic> json) =>
      _$ProductionCompanyResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ProductionCompanyResponseToJson(this);
  
  String get fullLogoUrl => logoPath != null 
      ? 'https://image.tmdb.org/t/p/w154$logoPath' 
      : '';
}

@JsonSerializable()
class ProductionCountryResponse {
  @JsonKey(name: 'iso_3166_1')
  final String? iso31661;
  
  @JsonKey(name: 'name')
  final String? name;

  const ProductionCountryResponse({
    this.iso31661,
    this.name,
  });

  factory ProductionCountryResponse.fromJson(Map<String, dynamic> json) =>
      _$ProductionCountryResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ProductionCountryResponseToJson(this);
}

@JsonSerializable()
class SpokenLanguageResponse {
  @JsonKey(name: 'english_name')
  final String? englishName;
  
  @JsonKey(name: 'iso_639_1')
  final String? iso6391;
  
  @JsonKey(name: 'name')
  final String? name;

  const SpokenLanguageResponse({
    this.englishName,
    this.iso6391,
    this.name,
  });

  factory SpokenLanguageResponse.fromJson(Map<String, dynamic> json) =>
      _$SpokenLanguageResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SpokenLanguageResponseToJson(this);
}

@JsonSerializable()
class CollectionResponse {
  @JsonKey(name: 'id')
  final int? id;
  
  @JsonKey(name: 'name')
  final String? name;
  
  @JsonKey(name: 'poster_path')
  final String? posterPath;
  
  @JsonKey(name: 'backdrop_path')
  final String? backdropPath;

  const CollectionResponse({
    this.id,
    this.name,
    this.posterPath,
    this.backdropPath,
  });

  factory CollectionResponse.fromJson(Map<String, dynamic> json) =>
      _$CollectionResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CollectionResponseToJson(this);
  
  String get fullPosterUrl => posterPath != null 
      ? 'https://image.tmdb.org/t/p/w342$posterPath' 
      : '';
  
  String get fullBackdropUrl => backdropPath != null 
      ? 'https://image.tmdb.org/t/p/w780$backdropPath' 
      : '';
}