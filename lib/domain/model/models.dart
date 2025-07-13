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

// Domain Model
//
class MovieDetail {
  final bool isAdult;
  final String? backdropPath;
  final MovieCollection? collection;
  final int budget;
  final List<Genre> genres;
  final String? homepage;
  final int id;
  final String? imdbId;
  final List<String> originCountries;
  final String originalLanguage;
  final String originalTitle;
  final String overview;
  final double popularity;
  final String? posterPath;
  final List<ProductionCompany> productionCompanies;
  final List<ProductionCountry> productionCountries;
  final DateTime? releaseDate;
  final int revenue;
  final int? runtime;
  final List<SpokenLanguage> spokenLanguages;

  final String? tagline;
  final String title;
  final bool hasVideo;
  final double voteAverage;
  final int voteCount;

  const MovieDetail({
    required this.isAdult,
    this.backdropPath,
    this.collection,
    required this.budget,
    required this.genres,
    this.homepage,
    required this.id,
    this.imdbId,
    required this.originCountries,
    required this.originalLanguage,
    required this.originalTitle,
    required this.overview,
    required this.popularity,
    this.posterPath,
    required this.productionCompanies,
    required this.productionCountries,
    this.releaseDate,
    required this.revenue,
    this.runtime,
    required this.spokenLanguages,
    this.tagline,
    required this.title,
    required this.hasVideo,
    required this.voteAverage,
    required this.voteCount,
  });
  factory MovieDetail.empty() {
    return const MovieDetail(
      isAdult: false,
      backdropPath: null,
      collection: null,
      budget: 0,
      genres: [],
      homepage: null,
      id: 0,
      imdbId: null,
      originCountries: [],
      originalLanguage: '',
      originalTitle: '',
      overview: '',
      popularity: 0,
      posterPath: null,
      productionCompanies: [],
      productionCountries: [],
      releaseDate: null,
      revenue: 0,
      runtime: null,
      spokenLanguages: [],
      tagline: null,
      title: '',
      hasVideo: false,
      voteAverage: 0,
      voteCount: 0,
    );
  }
}

class MovieCollection {
  final int id;
  final String name;
  final String? posterPath;
  final String? backdropPath;

  const MovieCollection({
    required this.id,
    required this.name,
    this.posterPath,
    this.backdropPath,
  });
}

class Genre {
  final int id;
  final String name;

  const Genre({
    required this.id,
    required this.name,
  });
}

class ProductionCompany {
  final int id;
  final String? logoPath;
  final String name;
  final String originCountry;

  const ProductionCompany({
    required this.id,
    this.logoPath,
    required this.name,
    required this.originCountry,
  });
}

class ProductionCountry {
  final String countryCode;
  final String name;

  const ProductionCountry({
    required this.countryCode,
    required this.name,
  });
}

class SpokenLanguage {
  final String englishName;
  final String languageCode;
  final String name;

  const SpokenLanguage({
    required this.englishName,
    required this.languageCode,
    required this.name,
  });
}
