import 'package:ai_movie_suggestion/app/app_prefs.dart';
import 'package:ai_movie_suggestion/app/constants.dart';
import 'package:ai_movie_suggestion/data/data_souce/remote_data_source.dart';
import 'package:ai_movie_suggestion/data/network/app_api.dart';
import 'package:ai_movie_suggestion/data/network/dio_factory.dart';
import 'package:ai_movie_suggestion/data/network/movieServiceClient.dart';
import 'package:ai_movie_suggestion/data/network/network_info.dart';
import 'package:ai_movie_suggestion/data/repository/repository_impl.dart';
import 'package:ai_movie_suggestion/domain/repository/repository.dart';
import 'package:ai_movie_suggestion/domain/usecase/login_usecase.dart';
import 'package:ai_movie_suggestion/domain/usecase/movies/get_now_playing_usecase.dart';
import 'package:ai_movie_suggestion/domain/usecase/movies/get_popular_usecase.dart';
import 'package:ai_movie_suggestion/domain/usecase/movies/get_top_rated_movies_usecase.dart';
import 'package:ai_movie_suggestion/domain/usecase/movies/get_upcoming_usecase.dart';
import 'package:ai_movie_suggestion/domain/usecase/movies/movie_details_usecase.dart';
import 'package:ai_movie_suggestion/domain/usecase/register_usecase.dart';
import 'package:ai_movie_suggestion/domain/usecase/verify_email_usecase.dart';
import 'package:ai_movie_suggestion/presentation/auth/login/viewmodel/login_viewmodel.dart';
import 'package:ai_movie_suggestion/presentation/auth/register/viewmodel/register_viewmodel.dart';
import 'package:ai_movie_suggestion/presentation/auth/verify_email/viewmodel/verify_email_viewmodel.dart';
import 'package:ai_movie_suggestion/presentation/main/pages/discover/pages/new_releases/viewmodel/new_releases_viewmodel.dart';
import 'package:ai_movie_suggestion/presentation/main/pages/discover/pages/now_playing/viewmodel/now_playing_viewmodel.dart';
import 'package:ai_movie_suggestion/presentation/main/pages/discover/pages/trending/viewmodel/trending_viewmodel.dart';
import 'package:ai_movie_suggestion/presentation/main/pages/home/viewmodel/home_viewmodel.dart';
import 'package:ai_movie_suggestion/presentation/main/pages/movie_detail/viewmodel/movie_detail_viewmodel.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';

final instance = GetIt.instance;
Future<void> initAppModule() async {
  final sharedPrefs = await SharedPreferences.getInstance();
  instance.registerLazySingleton<SharedPreferences>(() => sharedPrefs);

  // App preferences
  instance
      .registerLazySingleton<AppPreferences>(() => AppPreferences(instance()));

  // Network info
  instance.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(InternetConnectionChecker.createInstance()),
  );

  // Dio factory
  instance.registerLazySingleton<DioFactory>(() => DioFactory(instance()));

  // Dio instance + AppServiceClient
  Dio dio = await instance<DioFactory>().getDio();
  instance.registerLazySingleton<AppServiceClient>(
    () => AppServiceClient(dio, baseUrl: Constants.baseUrl),
  );

  // Movie API Dio instance + MovieServiceClient
  Dio movieDio = await instance<DioFactory>().getMovieDio();
  instance.registerLazySingleton<MovieServiceClient>(
    () => MovieServiceClient(movieDio, baseUrl: Constants.movieBaseUrl),
  );

  // Remote data source
  instance.registerLazySingleton<RemoteDataSource>(
    () => RemoteDataSourceImpl(instance(), instance(), Constants.apiKey),
  );

  // Repository
  instance.registerLazySingleton<Repository>(
    () => RepositoryImpl(instance(), instance(), instance()),
  );
}

initLoginModule() {
  if (!GetIt.I.isRegistered<LoginUsecase>()) {
    instance.registerFactory<LoginUsecase>(() => LoginUsecase(instance()));
    instance.registerFactory<LoginViewmodel>(
        () => LoginViewmodel(instance(), instance()));
  }
}

initRegisterModule() {
  if (!GetIt.I.isRegistered<RegisterUsecase>()) {
    instance
        .registerFactory<RegisterUsecase>(() => RegisterUsecase(instance()));
    instance.registerFactory<RegisterViewmodel>(
        () => RegisterViewmodel(instance(), instance()));
  }
}

initVerifyEmailModule() {
  if (!GetIt.I.isRegistered<VerifyEmailUsecase>()) {
    instance.registerFactory<VerifyEmailUsecase>(
        () => VerifyEmailUsecase(instance()));
    instance.registerFactory<VerifyEmailViewmodel>(
        () => VerifyEmailViewmodel(instance(), instance()));
  }
}

initTopRatedModule() {
  if (!GetIt.I.isRegistered<GetTopRatedMoviesUseCase>()) {
    instance.registerFactory<GetTopRatedMoviesUseCase>(
        () => GetTopRatedMoviesUseCase(instance()));
    instance.registerFactory<TopRatedViewModel>(
        () => TopRatedViewModel(instance()));
  }
}

initPopularModule() {
  if (!GetIt.I.isRegistered<GetPopularUsecase>()) {
    instance.registerFactory<GetPopularUsecase>(
        () => GetPopularUsecase(instance()));
    instance.registerFactory<TrendingViewmodel>(
        () => TrendingViewmodel(instance()));
  }
}

initNowPlayingModule() {
  if (!GetIt.I.isRegistered<GetNowPlayingMoviesUseCase>()) {
    instance.registerFactory<GetNowPlayingMoviesUseCase>(
        () => GetNowPlayingMoviesUseCase(instance()));
    instance.registerFactory<NowPlayingViewmodel>(
        () => NowPlayingViewmodel(instance()));
  }
}

initNewReleaseModule() {
  if (!GetIt.I.isRegistered<GetUpcomingUsecase>()) {
    instance.registerFactory<GetUpcomingUsecase>(
        () => GetUpcomingUsecase(instance()));
    instance.registerFactory<NewReleasesViewmodel>(
        () => NewReleasesViewmodel(instance()));
  }
}

initMovieDetailsModule() {
  if (!GetIt.I.isRegistered<MovieDetailsUseCase>()) {
    instance.registerFactory<MovieDetailsUseCase>(
        () => MovieDetailsUseCase(instance()));
    instance.registerFactory<MovieDetailsViewModel>(
        () => MovieDetailsViewModel(instance()));
  }
}
